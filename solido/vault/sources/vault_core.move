module vault::vault_core {
    use std::signer;
    use std::string::String;
    use std::vector;
    use aptos_std::table::{Self, Table};
    use aptos_std::type_info::{type_of, TypeInfo};
    use supra_framework::coin::{Self, MintCapability, BurnCapability};
    use supra_framework::account;
    use supra_framework::event;
    use supra_framework::timestamp;
    use supra_framework::error;
    use supra_framework::block;
    use vault::strategy_core;
    use vault::strategy_delegation;
    // FA Support imports
    use supra_framework::fungible_asset::{Self, Metadata};
    use supra_framework::primary_fungible_store;
    use supra_framework::object::{Self, Object};
    use std::option;

    /// Withdrawal request tracking
    struct WithdrawRequest has store, drop {
        assets: u64,          
        request_time: u64,
        processed: bool,
        request_id: u64  ,
        delay_at_request: u64
    }

    // Add a new struct to store all requests for a user (without drop ability)
    struct UserWithdrawRequests has key, store {
        requests: Table<u64, WithdrawRequest>,  // request_id -> WithdrawRequest
        request_ids: vector<u64>,               // List of request IDs for iteration
        next_request_id: u64,
        total_pending_assets: u64
    }

    struct DelayedWithdrawalCapability has key {
        cap: account::SignerCapability
    }

     /// Extended vault configuration
    struct VaultInfo has key {
        name: String,
        symbol: String,
        decimals: u8,
        total_assets: u64,
        total_shares: u64,
        paused: bool,
        withdraw_requests: Table<address, UserWithdrawRequests>,
        tvl_limit: u64,
        performance_fee: u64,
        withdraw_delay: u64,
        asset_type: TypeInfo,
        fee_recipient: address,
        withdrawal_fee: u64,  
        min_withdrawal_amount: u64,
    }

    /// Resource account capability
    struct VaultCapability has key {
        cap: account::SignerCapability
    }

    /// Stores mint/burn capabilities for the vault share token
    struct ShareTokenCapability has key {
        mint_cap: MintCapability<VaultShare>,
        burn_cap: BurnCapability<VaultShare>
    }

    /// The vault share token type
    struct VaultShare has key { }


    struct FundManagerInfo has key {
        fund_manager: address,
    }

     /// Events
    #[event]
    struct DepositEvent has drop, store {
        depositor: address,
        receiver: address,
        assets: u64,
        shares: u64,
        timestamp: u64,
        block_height: u64
    }

    #[event]
    struct WithdrawEvent has drop, store {
        withdrawer: address,
        receiver: address,
        owner: address,
        assets: u64,
        shares: u64,
        timestamp: u64,
        block_height: u64
    }


    #[event]
    struct InitializeEvent has drop, store {
        vault_address: address,
        asset_type: TypeInfo,
        name: String,
        symbol: String
    }

    #[event]
    struct PausedEvent has drop, store { }
    
    #[event]
    struct UnpausedEvent has drop, store {}

    #[event]
    struct WithdrawRequestEvent has drop, store {
        user: address,
        assets: u64,
        request_time: u64,
        timestamp: u64,
        block_height: u64
    }
 
    #[event]
    struct YieldGeneratedEvent has drop, store {
        yield_amount: u64,
        fee_amount: u64,
        remaining_yield: u64,
        fee_recipient: address
    }

    #[event]
    struct PerformanceFeeUpdatedEvent has drop, store {
        old_fee: u64,
        new_fee: u64
    }

    #[event]
    struct FeeRecipientUpdatedEvent has drop, store {
        old_recipient: address,
        new_recipient: address
    }

    #[event]
    struct TvlLimitUpdatedEvent has drop, store {
        old_limit: u64,
        new_limit: u64
    }

    #[event]
    struct WithdrawDelayUpdatedEvent has drop, store {
        old_delay: u64,
        new_delay: u64
    }

    #[event]
    struct WithdrawalFeeUpdatedEvent has drop, store {
        old_fee: u64,
        new_fee: u64
    }

    #[event]
    struct WithdrawalFeeCollectedEvent has drop, store {
        user: address,
        fee_amount: u64,
        withdrawal_amount: u64,
        fee_recipient: address
    }

    // Add a new event for tracking min withdrawal amount updates
    #[event]
    struct MinWithdrawalAmountUpdatedEvent has drop, store {
        old_amount: u64,
        new_amount: u64
    }

    // Add this event
    #[event]
    struct AssetsSyncedEvent has drop, store {
        old_total: u64,
        new_total: u64,
        difference: u64
    }

    #[event]
    struct FundManagerUpdatedEvent has drop, store {
        old_manager: address,
        new_manager: address
    }

    // V2 Events for FA Support (emit alongside V1 events for backward compatibility)
    #[event]
    struct DepositEventV2 has drop, store {
        depositor: address,
        receiver: address,
        assets: u64,
        shares: u64,
        timestamp: u64,
        block_height: u64,
        is_fa_deposit: bool,
        metadata_addr: address
    }

    #[event]
    struct WithdrawEventV2 has drop, store {
        withdrawer: address,
        receiver: address,
        owner: address,
        assets: u64,
        shares: u64,
        timestamp: u64,
        block_height: u64,
        is_fa_output: bool,
        fa_shares_burned: u64,
        coin_shares_burned: u64
    }

    #[event]
    struct VaultAssetConversionEvent has drop, store {
        vault_converted: u64,
        strategy_converted: u64,
        delayed_withdrawal_converted: u64,
        buffer_converted: u64,
        total_converted: u64,
        timestamp: u64
    }

    const PRECISION: u64 = 1000000; // 6 decimals for share calculation
    const FEE_PRECISION: u64 = 100000;
    const MAX_U64: u64 = 18446744073709551615;

    // Error codes
    const ERR_ALREADY_INITIALIZED: u64 = 1;
    const ERR_ZERO_DEPOSIT: u64 = 2;
    const ERR_VAULT_PAUSED: u64 = 3;
    const ERR_NOT_ADMIN: u64 = 4;
    const ERR_INSUFFICIENT_SHARES: u64 = 5;
    const ERR_INVALID_ASSET_TYPE: u64 = 6;
    const ERR_NOT_AUTHORIZED: u64 = 7;
    const ERR_MATH_OVERFLOW: u64 = 8;
    const ERR_TVL_LIMIT_EXCEEDED: u64 = 9;
    const ERR_EXCESSIVE_SLIPPAGE: u64 = 10;
    const ERR_WITHDRAWAL_TOO_SMALL: u64 = 11;
    const ERR_NO_FUNDS_TO_CLAIM: u64 = 12;
    const ERR_NOT_FUND_MANAGER: u64 = 13;
    // FA Support error codes
    const ERR_INSUFFICIENT_FA_BALANCE: u64 = 14;
    const ERR_FA_NOT_INITIALIZED: u64 = 15;
    const ERR_CONVERSION_FAILED: u64 = 16;
    const ERR_FA_TRANSFER_FAILED: u64 = 17;

    /// Stores the freeze capability
    struct FreezeCapabilityStore has key {
        cap: coin::FreezeCapability<VaultShare>
    }

    // ============ FA Helper Functions ============

    /// Check if AssetType has FA support (paired metadata exists)
    fun has_fa_support<AssetType>(): bool {
        option::is_some(&coin::paired_metadata<AssetType>())
    }

    /// Get FA metadata for AssetType
    fun get_fa_metadata<AssetType>(): Object<Metadata> {
        let metadata_opt = coin::paired_metadata<AssetType>();
        assert!(option::is_some(&metadata_opt), ERR_FA_NOT_INITIALIZED);
        *option::borrow(&metadata_opt)
    }

    /// Get user's FA balance for AssetType (returns 0 if no FA or no store)
    fun get_user_fa_balance<AssetType>(user_addr: address): u64 {
        let metadata_opt = coin::paired_metadata<AssetType>();
        if (option::is_none(&metadata_opt)) {
            return 0
        };
        let metadata = *option::borrow(&metadata_opt);
        // Check if user has a primary store and has balance
        if (!primary_fungible_store::is_balance_at_least(user_addr, metadata, 1)) {
            return 0
        };
        primary_fungible_store::balance(user_addr, metadata)
    }

    /// Get user's Coin balance for AssetType (returns 0 if not registered)
    fun get_user_coin_balance<AssetType>(user_addr: address): u64 {
        if (!coin::is_account_registered<AssetType>(user_addr)) {
            return 0
        };
        coin::balance<AssetType>(user_addr)
    }

    /// Get user's total balance for AssetType
    /// NOTE: In Supra, coin::balance() already returns Coin + FA when pairing is enabled
    /// So we just use coin::balance() to get the true total, no need to add FA separately
    fun get_user_total_balance<AssetType>(user_addr: address): u64 {
        get_user_coin_balance<AssetType>(user_addr)
    }

    /// Ensure user has enough FA balance (convert Coin to FA if needed)
    fun ensure_fa_balance<AssetType>(user: &signer, required: u64) {
        let user_addr = signer::address_of(user);
        let fa_balance = get_user_fa_balance<AssetType>(user_addr);
        
        if (fa_balance >= required) {
            return // Already have enough FA
        };
        
        let coin_needed = required - fa_balance;
        let coin_balance = get_user_coin_balance<AssetType>(user_addr);
        assert!(coin_balance >= coin_needed, ERR_INSUFFICIENT_FA_BALANCE);
        
        // Convert coin to FA
        let coins = coin::withdraw<AssetType>(user, coin_needed);
        let fa = coin::coin_to_fungible_asset(coins);
        primary_fungible_store::deposit(user_addr, fa);
    }

    /// Convert all Coin to FA for a signer's address
    fun convert_all_coin_to_fa<AssetType>(signer_ref: &signer) {
        let addr = signer::address_of(signer_ref);
        let coin_balance = get_user_coin_balance<AssetType>(addr);
        if (coin_balance == 0) {
            return
        };
        let coins = coin::withdraw<AssetType>(signer_ref, coin_balance);
        let fa = coin::coin_to_fungible_asset(coins);
        primary_fungible_store::deposit(addr, fa);
    }

    /// Get VaultShare FA balance (returns 0 if VaultShare has no FA or user has no store)
    fun get_vaultshare_fa_balance(user_addr: address): u64 {
        let metadata_opt = coin::paired_metadata<VaultShare>();
        if (option::is_none(&metadata_opt)) {
            return 0
        };
        let metadata = *option::borrow(&metadata_opt);
        if (!primary_fungible_store::is_balance_at_least(user_addr, metadata, 1)) {
            return 0
        };
        primary_fungible_store::balance(user_addr, metadata)
    }

    /// Get user's total VaultShare balance
    /// NOTE: In Supra, coin::balance() already returns Coin + FA when pairing is enabled
    fun get_user_total_vaultshare_balance(user_addr: address): u64 {
        if (coin::is_account_registered<VaultShare>(user_addr)) {
            coin::balance<VaultShare>(user_addr)
        } else { 0 }
    }

    /// Burn VaultShare - FA first, then Coin (returns tuple: fa_burned, coin_burned)
    fun burn_shares_with_fa_priority(
        user: &signer,
        shares_to_burn: u64
    ): (u64, u64) acquires ShareTokenCapability {
        let user_addr = signer::address_of(user);
        
        // Get total balance using coin::balance (which includes both Coin + FA)
        let total = if (coin::is_account_registered<VaultShare>(user_addr)) {
            coin::balance<VaultShare>(user_addr)
        } else { 0 };
        
        // Get FA-only balance
        let fa_balance = get_vaultshare_fa_balance(user_addr);
        
        // Pure Coin balance = total - FA (since coin::balance includes FA)
        let pure_coin_balance = if (total > fa_balance) { total - fa_balance } else { 0 };
        
        assert!(total >= shares_to_burn, ERR_INSUFFICIENT_SHARES);
        
        let remaining = shares_to_burn;
        let share_cap = borrow_global<ShareTokenCapability>(@vault);
        let fa_burned: u64 = 0;
        let coin_burned: u64 = 0;
        
        // Burn FA first (if user has FA shares and VaultShare has FA support)
        if (fa_balance > 0 && remaining > 0 && option::is_some(&coin::paired_metadata<VaultShare>())) {
            let fa_to_burn = if (remaining <= fa_balance) { remaining } else { fa_balance };
            let metadata = *option::borrow(&coin::paired_metadata<VaultShare>());
            let fa = primary_fungible_store::withdraw(user, metadata, fa_to_burn);
            
            // Burn FA directly using get_paired_burn_ref (FA to Coin conversion not allowed)
            // get_paired_burn_ref returns (BurnRef, BurnRefReceipt) - must return receipt after use
            let (burn_ref, burn_ref_receipt) = coin::get_paired_burn_ref<VaultShare>(&share_cap.burn_cap);
            fungible_asset::burn(&burn_ref, fa);
            coin::return_paired_burn_ref(burn_ref, burn_ref_receipt);
            
            remaining = remaining - fa_to_burn;
            fa_burned = fa_to_burn;
        };
        
        // Burn remaining from pure Coin balance
        if (remaining > 0 && pure_coin_balance > 0) {
            let coin_to_burn = if (remaining <= pure_coin_balance) { remaining } else { pure_coin_balance };
            let coins = coin::withdraw<VaultShare>(user, coin_to_burn);
            coin::burn(coins, &share_cap.burn_cap);
            coin_burned = coin_to_burn;
        };
        
        (fa_burned, coin_burned)
    }

    /// Mint VaultShare as FA to user (if FA support exists, otherwise mint as Coin)
    fun mint_vaultshare_to_user(
        receiver: address,
        shares: u64
    ) acquires ShareTokenCapability {
        let share_cap = borrow_global<ShareTokenCapability>(@vault);
        let share_tokens = coin::mint(shares, &share_cap.mint_cap);
        
        // If VaultShare has FA support, convert to FA and deposit
        if (option::is_some(&coin::paired_metadata<VaultShare>())) {
            let metadata = *option::borrow(&coin::paired_metadata<VaultShare>());
            // Ensure receiver has primary store
            primary_fungible_store::ensure_primary_store_exists(receiver, metadata);
            // Convert to FA and deposit
            let fa = coin::coin_to_fungible_asset(share_tokens);
            primary_fungible_store::deposit(receiver, fa);
        } else {
            // Legacy: just deposit as Coin
            coin::deposit<VaultShare>(receiver, share_tokens);
        };
    }

    public entry fun initialize<AssetType>(
        admin: &signer,
        name: String,
        symbol: String,
        decimals: u8,
        fee_recipient: address,
        initial_deposit: u64
    ) acquires ShareTokenCapability{
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        assert!(!exists<VaultInfo>(admin_addr), ERR_ALREADY_INITIALIZED);
        assert!(initial_deposit > 0, ERR_ZERO_DEPOSIT);

        // Initialize share token
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<VaultShare>(
            admin,
            name,
            symbol,
            decimals,
            true
        );

        // Store freeze capability
        move_to(admin, FreezeCapabilityStore { cap: freeze_cap });

        // Store mint/burn capabilities - must be done before using mint_cap
        move_to(admin, ShareTokenCapability {
            mint_cap,
            burn_cap
        });

        // Create resource accounts
        let (vault_signer, vault_cap) = account::create_resource_account(admin, b"vault_pool");
        let vault_addr = signer::address_of(&vault_signer);
        let (delayed_withdrawal_signer, delayed_withdrawal_cap) = 
            account::create_resource_account(admin, b"delayed_withdrawals");
        let delayed_withdrawal_addr = signer::address_of(&delayed_withdrawal_signer);

        // Register accounts for assets
        if (!coin::is_account_registered<AssetType>(vault_addr)) {
            coin::register<AssetType>(&vault_signer);
        };
        if (!coin::is_account_registered<AssetType>(signer::address_of(&delayed_withdrawal_signer))) {
            coin::register<AssetType>(&delayed_withdrawal_signer);
        };

        // Register admin for VaultShare if needed
        if (!coin::is_account_registered<VaultShare>(admin_addr)) {
            coin::register<VaultShare>(admin);
        };

        // Get the stored mint capability to use
        let share_cap = borrow_global<ShareTokenCapability>(admin_addr);
        
        // Mint initial shares to admin
        let share_tokens = coin::mint(initial_deposit, &share_cap.mint_cap);
        coin::deposit<VaultShare>(admin_addr, share_tokens);

        // Transfer initial deposit to vault
        coin::transfer<AssetType>(admin, vault_addr, initial_deposit);


        // Initialize vault storage with min_withdrawal_amount
        move_to(admin, VaultInfo {
            name,
            symbol,
            decimals,
            total_assets: initial_deposit,
            total_shares: initial_deposit,
            paused: false,
            withdraw_requests: table::new(),
            tvl_limit: 0,
            performance_fee: 0,
            withdraw_delay: 0,
            asset_type: type_of<AssetType>(),
            fee_recipient,
            withdrawal_fee: 0,
            // min_withdrawal_amount: 100000,  // Default: 100,000 units
            min_withdrawal_amount: 1000,  // Default: 100,000 units
        });

        // Store capabilities
        move_to(admin, VaultCapability { cap: vault_cap });
        move_to(admin, DelayedWithdrawalCapability { cap: delayed_withdrawal_cap });

        // Initialize strategy
        strategy_core::initialize<AssetType>(admin, vault_addr, delayed_withdrawal_addr);
        // earn<AssetType>();

        // Emit initialization event
        event::emit(InitializeEvent {
            vault_address: vault_addr,
            asset_type: type_of<AssetType>(),
            name,
            symbol
        });

        event::emit(DepositEvent {
            depositor: admin_addr,
            receiver: vault_addr,
            assets: initial_deposit,
            shares: initial_deposit,
            timestamp: timestamp::now_seconds(),
            block_height: block::get_current_block_height()
        });
    }


    public entry fun deposit<AssetType>(
        user: &signer,
        assets: u64
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability {
        deposit_internal<AssetType>(user, assets, signer::address_of(user), 0);
    }

    public entry fun deposit_for<AssetType>(
        user: &signer,
        assets: u64,
        receiver: address
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability {
        deposit_internal<AssetType>(user, assets, receiver, 0);
    }

    public entry fun deposit_with_slippage<AssetType>(
        user: &signer,
        assets: u64,
        min_shares: u64
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability {
        deposit_internal<AssetType>(user, assets, signer::address_of(user), min_shares);
    }


    fun deposit_internal<AssetType>(
        user: &signer,
        assets: u64,
        receiver: address,
        min_shares: u64
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability  {
        let user_addr = signer::address_of(user);
        
        // Validate deposit
        assert!(assets > 0, ERR_ZERO_DEPOSIT);
        assert!(assets <= max_deposit<AssetType>(user_addr), ERR_TVL_LIMIT_EXCEEDED);
        
        let vault = borrow_global_mut<VaultInfo>(@vault);
        assert!(!vault.paused, ERR_VAULT_PAUSED);

        // Assert that AssetType matches the vault's asset type
        assert!(type_of<AssetType>() == vault.asset_type, ERR_INVALID_ASSET_TYPE);

        let shares = convert_to_shares<AssetType>(assets);
        if (min_shares > 0) {
            assert!(shares >= min_shares, ERR_EXCESSIVE_SLIPPAGE);
        };

        // Register user for VaultShare if needed (for legacy compatibility)
        if (!coin::is_account_registered<VaultShare>(user_addr)) {
            coin::register<VaultShare>(user);
        };
        
        // Transfer assets to vault
        let vault_signer = get_vault_signer();
        let vault_resource_addr = signer::address_of(&vault_signer);
        
        // FA Support: Check if AssetType has FA support
        let is_fa_deposit = has_fa_support<AssetType>();
        let metadata_addr: address = @0x0;
        
        if (is_fa_deposit) {
            // Get FA metadata
            let metadata = get_fa_metadata<AssetType>();
            metadata_addr = object::object_address(&metadata);
            
            // Ensure user has enough FA (convert Coin to FA if needed)
            ensure_fa_balance<AssetType>(user, assets);
            
            // Ensure vault can receive FA
            primary_fungible_store::ensure_primary_store_exists(vault_resource_addr, metadata);
            
            // Transfer FA to vault
            let fa = primary_fungible_store::withdraw(user, metadata, assets);
            primary_fungible_store::deposit(vault_resource_addr, fa);
        } else {
            // Legacy Coin transfer
            coin::transfer<AssetType>(user, vault_resource_addr, assets);
        };

        // Deploy to strategy
        strategy_core::deposit<AssetType>(receiver, assets);

        // Mint share tokens to user (as FA if VaultShare has FA support)
        mint_vaultshare_to_user(receiver, shares);

        // Update vault accounting
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.total_assets = vault.total_assets + assets;
        vault.total_shares = vault.total_shares + shares;

        // Emit V1 deposit event (backward compatibility)
        event::emit(DepositEvent {
            depositor: user_addr,
            receiver,
            assets,
            shares,
            timestamp: timestamp::now_seconds(),
            block_height: block::get_current_block_height()
        });
        
        // Emit V2 deposit event with FA details
        event::emit(DepositEventV2 {
            depositor: user_addr,
            receiver,
            assets,
            shares,
            timestamp: timestamp::now_seconds(),
            block_height: block::get_current_block_height(),
            is_fa_deposit,
            metadata_addr
        });
    }


    // fun earn<AssetType>() acquires VaultCapability {
    //     // Get vault signer and strategy address
    //     let vault_signer = get_vault_signer();
    //     let vault_addr = signer::address_of(&vault_signer);
        
    //     // Get strategy address
    //     let strategy_signer = strategy_core::get_strategy_signer();
    //     let strategy_addr = signer::address_of(&strategy_signer);
        
    //     // Get current balance in vault's resource account
    //     let available_assets = coin::balance<AssetType>(vault_addr);
        

    //     // if (available_assets > 0) {
    //     //     // First transfer assets to strategy's resource account
    //     //     coin::transfer<AssetType>(
    //     //         &vault_signer,
    //     //         strategy_addr,
    //     //         available_assets
    //     //     );
            
    //     //     // Then call strategy deposit to update accounting 
    //     //     strategy_core::deposit<AssetType>();
    //     // };
    // }


    public entry fun withdraw<AssetType>(
        user: &signer,
        assets: u64
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability, DelayedWithdrawalCapability {
        withdraw_internal<AssetType>(
            user,
            assets,
            signer::address_of(user),
            signer::address_of(user)
        );
    }

    public entry fun withdraw_to<AssetType>(
        user: &signer,
        assets: u64,
        receiver: address
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability, DelayedWithdrawalCapability {
        withdraw_internal<AssetType>(
            user,
            assets,
            receiver,
            signer::address_of(user)
        );
    }

    fun withdraw_internal<AssetType>(
        user: &signer,
        assets: u64,
        _receiver: address,
        owner: address
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability, DelayedWithdrawalCapability {
        let user_addr = signer::address_of(user);
        assert!(user_addr == owner, ERR_NOT_AUTHORIZED);
        
        // Get necessary information in a scope that will be closed
        let delay: u64;
        let matches_asset_type: bool;
        let is_paused: bool;
        let withdrawal_fee: u64;
        let min_withdrawal_amount: u64;
        {
            let vault = borrow_global<VaultInfo>(@vault);
            is_paused = vault.paused;
            matches_asset_type = type_of<AssetType>() == vault.asset_type;
            delay = vault.withdraw_delay;
            withdrawal_fee = vault.withdrawal_fee;
            min_withdrawal_amount = vault.min_withdrawal_amount;
        }; // Scope ends, borrow released
        
        // Check assertions
        assert!(!is_paused, ERR_VAULT_PAUSED);
        assert!(matches_asset_type, ERR_INVALID_ASSET_TYPE);

        if (withdrawal_fee > 0) {
            assert!(assets >= min_withdrawal_amount, ERR_WITHDRAWAL_TOO_SMALL);
        };

        // Calculate and burn shares immediately regardless of delay
        let shares_to_burn = preview_withdraw<AssetType>(assets);
        
        // FA Support: Check total VaultShare balance (Coin + FA)
        let user_share_balance = get_user_total_vaultshare_balance(user_addr);
        assert!(shares_to_burn <= user_share_balance, ERR_INSUFFICIENT_SHARES);
        
        // Burn shares immediately in all cases (FA first, then Coin)
        let (_fa_burned, _coin_burned) = burn_shares_with_fa_priority(user, shares_to_burn);
        
        // Update vault accounting
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.total_shares = vault.total_shares - shares_to_burn;
        // vault.total_assets = vault.total_assets - assets;
            
        // If no delay, process immediately
        if (delay == 0) {
            // Process withdrawal immediately
            assert!(false, ERR_NOT_AUTHORIZED);
            // let withdrawal_fee = vault.withdrawal_fee;
            // let fee_recipient = vault.fee_recipient;
            // process_withdrawal<AssetType>(user, receiver, assets, shares_to_burn, false, withdrawal_fee, fee_recipient);
            // vault.total_assets = vault.total_assets - assets;
            // // Emit withdrawal event
            // event::emit(WithdrawEvent {
            //     withdrawer: user_addr,
            //     receiver,
            //     owner,
            //     assets,
            //     shares: shares_to_burn,
            //     timestamp: timestamp::now_seconds(),
            //     block_height: block::get_current_block_height()
            // });
        } else {
            // Create withdrawal request
            let vault_signer = get_vault_signer();
            let delayed_withdrawal_signer = get_delayed_withdrawal_signer();
            
            // Process withdrawal to delayed withdrawal account
            let withdrawal_fee = vault.withdrawal_fee;
            let fee_recipient = vault.fee_recipient;
            // process_withdrawal<AssetType>(
            //     &vault_signer, 
            //     signer::address_of(&delayed_withdrawal_signer),
            //     assets,
            //     shares_to_burn,
            //     true,
            //     withdrawal_fee,
            //     fee_recipient
            // );
            strategy_core::withdraw<AssetType>(user_addr, assets);
            let request_time = timestamp::now_seconds();
            
            // Initialize user's withdraw requests if not exists
            if (!table::contains(&vault.withdraw_requests, user_addr)) {
                table::add(&mut vault.withdraw_requests, user_addr, UserWithdrawRequests {
                    requests: table::new(),
                    request_ids: vector::empty(),
                    next_request_id: 0,
                    total_pending_assets: 0
                });
            };

            // Add new request rather than replacing old one
            let user_requests = table::borrow_mut(&mut vault.withdraw_requests, user_addr);
            let request_id = user_requests.next_request_id;
            user_requests.next_request_id = request_id + 1;
            user_requests.total_pending_assets = user_requests.total_pending_assets + assets;

            // Add request ID to the vector for tracking
            vector::push_back(&mut user_requests.request_ids, request_id);
            let request_delay = vault.withdraw_delay;
            table::add(&mut user_requests.requests, request_id, WithdrawRequest {
                assets,
                request_time,
                processed: false,
                request_id,
                delay_at_request: request_delay
            });

            // Emit withdrawal request event
            event::emit(WithdrawRequestEvent {
                user: user_addr,
                assets,              
                request_time: request_time,
                timestamp: timestamp::now_seconds(),
                block_height: block::get_current_block_height()
            });
        }
    }

    public entry fun claim_withdrawal<AssetType>(
        user: &signer,
        receiver: address
    ) acquires VaultInfo, DelayedWithdrawalCapability {
        let user_addr = signer::address_of(user);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        assert!(table::contains(&vault.withdraw_requests, user_addr), ERR_NOT_AUTHORIZED);
        
        let user_requests = table::borrow_mut(&mut vault.withdraw_requests, user_addr);
        let current_time = timestamp::now_seconds();
        let delay = vault.withdraw_delay;
        let total_claimable = 0;
        
        // Get withdrawal fee and fee recipient
        let withdrawal_fee = vault.withdrawal_fee;
        let fee_recipient = vault.fee_recipient;
        
        // Track which request IDs to remove after processing
        let processed_request_ids = vector::empty<u64>();
        
        // Iterate using the request_ids vector
        let i = 0;
        let request_ids_len = vector::length(&user_requests.request_ids);
        
        while (i < request_ids_len) {
            let request_id = *vector::borrow(&user_requests.request_ids, i);
            if (table::contains(&user_requests.requests, request_id)) {
                let request = table::borrow_mut(&mut user_requests.requests, request_id);
                if (!request.processed && current_time >= request.request_time + request.delay_at_request) {
                    total_claimable = total_claimable + request.assets;
                    request.processed = true;
                    // Mark this request for removal
                    vector::push_back(&mut processed_request_ids, request_id);
                };
            };
            i = i + 1;
        };
        
        // Assert that there are actually funds to claim
        assert!(total_claimable > 0, ERR_NO_FUNDS_TO_CLAIM);
        
        if (total_claimable > 0) {
            // Calculate fee
            let fee_amount = if (withdrawal_fee > 0) {
                let fee_u128 = (total_claimable as u128) * (withdrawal_fee as u128) / (FEE_PRECISION as u128);
                (fee_u128 as u64)
            } else {
                0
            };
            
            // Calculate net withdrawal amount after fee
            let withdrawal_amount = total_claimable - fee_amount;
            
            // Transfer assets from delayed withdrawal account to receiver
            let delayed_withdrawal_signer = get_delayed_withdrawal_signer();
            
            // FA Support: Check if AssetType has FA support
            let has_fa = has_fa_support<AssetType>();
            
            if (has_fa) {
                // Convert any Coin in delayed withdrawal account to FA
                convert_all_coin_to_fa<AssetType>(&delayed_withdrawal_signer);
                
                // Get FA metadata and ensure receiver can receive FA
                let metadata = get_fa_metadata<AssetType>();
                primary_fungible_store::ensure_primary_store_exists(receiver, metadata);
                
                // Transfer FA to receiver
                let fa = primary_fungible_store::withdraw(&delayed_withdrawal_signer, metadata, withdrawal_amount);
                primary_fungible_store::deposit(receiver, fa);
            } else {
                // Legacy: Register receiver if needed
                if (!coin::is_account_registered<AssetType>(receiver)) {
                    if (receiver == user_addr) {
                        coin::register<AssetType>(user);
                    } else {
                        assert!(false, ERR_NOT_AUTHORIZED);
                    };
                };
                
                // Transfer Coin to receiver
                coin::transfer<AssetType>(
                    &delayed_withdrawal_signer,
                    receiver,
                    withdrawal_amount
                );
            };
            
            // Transfer fee to fee recipient if non-zero
            if (fee_amount > 0) {
                if (has_fa) {
                    // Transfer FA fee to fee recipient
                    let metadata = get_fa_metadata<AssetType>();
                    primary_fungible_store::ensure_primary_store_exists(fee_recipient, metadata);
                    let fa_fee = primary_fungible_store::withdraw(&delayed_withdrawal_signer, metadata, fee_amount);
                    primary_fungible_store::deposit(fee_recipient, fa_fee);
                    
                    // Emit fee collected event
                    event::emit(WithdrawalFeeCollectedEvent {
                        user: user_addr,
                        fee_amount,
                        withdrawal_amount,
                        fee_recipient
                    });
                } else {
                    // Legacy: Coin fee transfer
                    if (coin::is_account_registered<AssetType>(fee_recipient)) {
                        coin::transfer<AssetType>(
                            &delayed_withdrawal_signer,
                            fee_recipient,
                            fee_amount
                        );
                        
                        // Emit fee collected event
                        event::emit(WithdrawalFeeCollectedEvent {
                            user: user_addr,
                            fee_amount,
                            withdrawal_amount,
                            fee_recipient
                        });
                    } else {
                        // If recipient not registered, add fee amount back to withdrawal
                        coin::transfer<AssetType>(
                            &delayed_withdrawal_signer,
                            receiver,
                            fee_amount
                        );
                    };
                };
            };
            
            // Update total pending assets
            user_requests.total_pending_assets = user_requests.total_pending_assets - total_claimable;
            
            // Remove processed requests from both the table and the request_ids vector
            let j = 0;
            let processed_len = vector::length(&processed_request_ids);
            while (j < processed_len) {
                let request_id_to_remove = *vector::borrow(&processed_request_ids, j);
                
                // Remove from requests table
                table::remove(&mut user_requests.requests, request_id_to_remove);
                
                // Find and remove from request_ids vector
                let k = 0;
                let ids_len = vector::length(&user_requests.request_ids);
                while (k < ids_len) {
                    if (*vector::borrow(&user_requests.request_ids, k) == request_id_to_remove) {
                        vector::remove(&mut user_requests.request_ids, k);
                        break
                    };
                    k = k + 1;
                };
                
                j = j + 1;
            };
            
            // Emit withdrawal event
            event::emit(WithdrawEvent {
                withdrawer: user_addr,
                receiver,
                owner: user_addr,
                assets: withdrawal_amount, // Report the amount after fee
                shares: 0,
                timestamp: timestamp::now_seconds(),
                block_height: block::get_current_block_height()
            });
        };
    }

    // // Helper function to process actual withdrawal
    // fun process_withdrawal<AssetType>(
    //     user: &signer,
    //     receiver: address,
    //     assets: u64,
    //     _shares: u64,
    //     is_delayed_withdrawal: bool,
    //     withdrawal_fee: u64,
    //     fee_recipient: address
    // ) acquires VaultCapability {
    //     let user_addr = signer::address_of(user);
        
    //     // Get vault signer
    //     let vault_signer = get_vault_signer();
        
    //     // Registration if needed
    //     if (!coin::is_account_registered<AssetType>(receiver)) {
    //         if (receiver == user_addr) {
    //             coin::register<AssetType>(user);
    //         } else {
    //             assert!(false, ERR_NOT_AUTHORIZED);
    //         };
    //     };
        
    //     // For immediate withdrawals, apply the fee now
    //     // For delayed withdrawals, transfer full amount to the holding account
    //     if (!is_delayed_withdrawal) {
    //         // Calculate fee amount
    //         let fee_amount = if (withdrawal_fee > 0) {
    //             let fee_u128 = (assets as u128) * (withdrawal_fee as u128) / (FEE_PRECISION as u128);
    //             (fee_u128 as u64)
    //         } else {
    //             0
    //         };
            
    //         // Calculate final withdrawal amount after fee
    //         let withdrawal_amount = assets - fee_amount;
            
    //         // Transfer withdrawal amount to receiver
    //         coin::transfer<AssetType>(&vault_signer, receiver, withdrawal_amount);
            
    //         // Transfer fee to fee recipient if non-zero
    //         if (fee_amount > 0) {
    //             // Ensure fee recipient is registered for this asset type
    //             if (coin::is_account_registered<AssetType>(fee_recipient)) {
    //                 coin::transfer<AssetType>(
    //                     &vault_signer,
    //                     fee_recipient,
    //                     fee_amount
    //                 );
                    
    //                 // Emit fee collected event
    //                 event::emit(WithdrawalFeeCollectedEvent {
    //                     user: user_addr,
    //                     fee_amount,
    //                     withdrawal_amount,
    //                     fee_recipient
    //                 });
    //             } else {
    //                 // If recipient not registered, add fee amount back to withdrawal
    //                 coin::transfer<AssetType>(&vault_signer, receiver, fee_amount);
    //             };
    //         };
    //     } else {
    //         // For delayed withdrawals, just transfer the full amount to the holding account
    //         coin::transfer<AssetType>(&vault_signer, receiver, assets);
    //     }
    // }

    public entry fun redeem<AssetType>(
        user: &signer,
        shares: u64
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability, DelayedWithdrawalCapability {
        redeem_internal<AssetType>(
            user,
            shares,
            signer::address_of(user),
            signer::address_of(user)
        );
    }

    public entry fun redeem_to<AssetType>(
        user: &signer,
        shares: u64,
        receiver: address
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability, DelayedWithdrawalCapability {
        redeem_internal<AssetType>(
            user,
            shares,
            receiver,
            signer::address_of(user)
        );
    }

    fun redeem_internal<AssetType>(
        user: &signer,
        shares: u64,
        receiver: address,
        owner: address
    ) acquires VaultInfo, VaultCapability, ShareTokenCapability, DelayedWithdrawalCapability {
        let user_addr = signer::address_of(user);
        assert!(user_addr == owner, ERR_NOT_AUTHORIZED);
        
        // Get necessary information in a scope that will be closed
        let delay: u64;
        let matches_asset_type: bool;
        let is_paused: bool;
        let withdrawal_fee: u64;
        let min_withdrawal_amount: u64;
        {
            let vault = borrow_global<VaultInfo>(@vault);
            is_paused = vault.paused;
            matches_asset_type = type_of<AssetType>() == vault.asset_type;
            delay = vault.withdraw_delay;
            withdrawal_fee = vault.withdrawal_fee;
            min_withdrawal_amount = vault.min_withdrawal_amount;
        }; // Scope ends, borrow released
        
        // Check assertions
        assert!(!is_paused, ERR_VAULT_PAUSED);
        assert!(matches_asset_type, ERR_INVALID_ASSET_TYPE);
        
        // Calculate assets based on shares
        let assets = preview_redeem<AssetType>(shares);
        
        // FA Support: Check total VaultShare balance (Coin + FA)
        let user_share_balance = get_user_total_vaultshare_balance(user_addr);
        assert!(shares <= user_share_balance, ERR_INSUFFICIENT_SHARES);

        if (withdrawal_fee > 0) {
            assert!(assets >= min_withdrawal_amount, ERR_WITHDRAWAL_TOO_SMALL);
        };

        // FA Support: Burn shares with FA priority (FA first, then Coin)
        let (_fa_burned, _coin_burned) = burn_shares_with_fa_priority(user, shares);
        
        // Update vault accounting
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.total_shares = vault.total_shares - shares;
        // vault.total_assets = vault.total_assets - assets;
            
        // If no delay, process immediately
        if (delay == 0) {
            // Process withdrawal immediately
            assert!(false, ERR_NOT_AUTHORIZED);
            // let withdrawal_fee = vault.withdrawal_fee;
            // let fee_recipient = vault.fee_recipient;
            // process_withdrawal<AssetType>(user, receiver, assets, shares, false, withdrawal_fee, fee_recipient);
            // vault.total_assets = vault.total_assets - assets;
            // // Emit withdrawal event
            // event::emit(WithdrawEvent {
            //     withdrawer: user_addr,
            //     receiver,
            //     owner,
            //     assets,
            //     shares,
            //     timestamp: timestamp::now_seconds(),
            //     block_height: block::get_current_block_height()
            // });
        } else {
            // Create withdrawal request
            let vault_signer = get_vault_signer();
            let delayed_withdrawal_signer = get_delayed_withdrawal_signer();
            
            // Process withdrawal to delayed withdrawal account
            let withdrawal_fee = vault.withdrawal_fee;
            let fee_recipient = vault.fee_recipient;
            // process_withdrawal<AssetType>(
            //     &vault_signer,
            //     signer::address_of(&delayed_withdrawal_signer),
            //     assets,
            //     shares,
            //     true,
            //     withdrawal_fee,
            //     fee_recipient
            // );
            strategy_core::withdraw<AssetType>(user_addr, assets);
            let request_time = timestamp::now_seconds();
            
            // Initialize user's withdraw requests if not exists
            if (!table::contains(&vault.withdraw_requests, user_addr)) {
                table::add(&mut vault.withdraw_requests, user_addr, UserWithdrawRequests {
                    requests: table::new(),
                    request_ids: vector::empty(),
                    next_request_id: 0,
                    total_pending_assets: 0
                });
            };

            let user_requests = table::borrow_mut(&mut vault.withdraw_requests, user_addr);
            let request_id = user_requests.next_request_id;
            user_requests.next_request_id = request_id + 1;
            user_requests.total_pending_assets = user_requests.total_pending_assets + assets;

            // Add request ID to the vector for tracking
            vector::push_back(&mut user_requests.request_ids, request_id);
            let request_delay = vault.withdraw_delay;
            table::add(&mut user_requests.requests, request_id, WithdrawRequest {
                assets,
                request_time,
                processed: false,
                request_id,
                delay_at_request: request_delay
            });

            // Emit withdrawal request event
            event::emit(WithdrawRequestEvent {
                user: user_addr,
                assets,
                request_time: request_time,
                timestamp: timestamp::now_seconds(),
                block_height: block::get_current_block_height()
            });
        }
    }


    
    // Helper function to get vault signer
    fun get_vault_signer(): signer acquires VaultCapability {
        account::create_signer_with_capability(&borrow_global<VaultCapability>(@vault).cap)
    }

    #[view]
    public fun get_vault_resource_address(): address acquires VaultCapability {
        let vault_signer = get_vault_signer();
        signer::address_of(&vault_signer)
    }

    public fun get_delayed_withdrawal_address_internal(): address acquires DelayedWithdrawalCapability {
        let delayed_withdrawal_signer = get_delayed_withdrawal_signer();
        signer::address_of(&delayed_withdrawal_signer)
    }

    fun get_delayed_withdrawal_signer(): signer acquires DelayedWithdrawalCapability {
        account::create_signer_with_capability(
            &borrow_global<DelayedWithdrawalCapability>(@vault).cap
        )
    }
   

    #[view]
    public fun convert_to_shares<AssetType>(assets: u64): u64 acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        let supply = vault.total_shares;
        let total = total_assets<AssetType>();
        
        // Handle initial conversion case
        if (assets == 0 || supply == 0) {
            return assets // Initial conversion rate of 1:1
        };
        
        // Prevent overflow by using a two-step approach with high precision
        let assets_with_precision = (assets as u128) * (PRECISION as u128);
        let shares_precise = (assets_with_precision * (supply as u128)) / (total as u128);
        
        // Divide by PRECISION to get back to normal scale
        let shares_precise = shares_precise / (PRECISION as u128);
        
        // Convert back to u64 with safety check
        assert!(shares_precise <= (MAX_U64 as u128), ERR_MATH_OVERFLOW);
        (shares_precise as u64)
    }

    #[view]
    public fun convert_to_assets<AssetType>(shares: u64): u64 acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        let supply = vault.total_shares;
        let total = total_assets<AssetType>();
        
        if (supply == 0) {
            return shares
        };
        
        // Use u128 for intermediate calculations to prevent overflow
        let shares_with_precision = (shares as u128) * (PRECISION as u128);
        let assets_precise = (shares_with_precision * (total as u128)) / (supply as u128);
        
        // Divide by PRECISION to get back to normal scale
        let assets_precise = assets_precise / (PRECISION as u128);
        
        // Convert back to u64 with safety check
        assert!(assets_precise <= (MAX_U64 as u128), ERR_MATH_OVERFLOW);
        (assets_precise as u64)
    }

    /// Preview functions to simulate operations
    #[view]
    public fun preview_deposit<AssetType>(assets: u64): u64 acquires VaultInfo {
        convert_to_shares<AssetType>(assets)
    }

    #[view] 
    public fun preview_mint<AssetType>(shares: u64): u64 acquires VaultInfo {
        convert_to_assets<AssetType>(shares)
    }

    #[view]
    public fun preview_redeem<AssetType>(shares: u64): u64 acquires VaultInfo {
        convert_to_assets<AssetType>(shares)
    }


    #[view]
    public fun preview_withdraw<AssetType>(assets: u64): u64 acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        let shares_supply = vault.total_shares;
        let total_assets_amount = total_assets<AssetType>();
        
        if (total_assets_amount == 0 || shares_supply == 0) {
             assets // Initial conversion rate of 1:1
        } else {
            // Use u128 for intermediate calculations to prevent overflow
            let shares_precise = ((assets as u128) * (shares_supply as u128)) / (total_assets_amount as u128);
            
            // Round up by checking remainder
            let remainder = ((assets as u128) * (shares_supply as u128)) % (total_assets_amount as u128);
            let shares = if (remainder > 0) { shares_precise + 1 } else { shares_precise };
            
            // Safety check
            assert!(shares <= (MAX_U64 as u128), ERR_MATH_OVERFLOW);
            (shares as u64)

            // assert!(shares_precise <= (MAX_U64 as u128), ERR_MATH_OVERFLOW);
            // (shares_precise as u64)
        }
    }

    public entry fun pause(admin: &signer) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.paused = true;
        event::emit(PausedEvent {});
    }
    public entry fun unpause(admin: &signer) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.paused = false;
        event::emit(UnpausedEvent {});
    }

    public entry fun set_tvl_limit<AssetType>(admin: &signer, new_limit: u64) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_limit = vault.tvl_limit;
        vault.tvl_limit = new_limit;
        event::emit(TvlLimitUpdatedEvent { old_limit, new_limit });
    }

    public entry fun set_performance_fee(admin: &signer, new_fee: u64) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_fee = vault.performance_fee;
        vault.performance_fee = new_fee;
        event::emit(PerformanceFeeUpdatedEvent { old_fee, new_fee });
    }

    public entry fun harvest<AssetType>(
        admin: &signer, 
        validators_stake: vector<address>, 
        stake_amounts: vector<u64>, 
        validators_unstake: vector<address>, 
        unstake_amounts: vector<u64>,
        delay_transfer_amount: u64
    ) acquires VaultInfo, VaultCapability {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);

        let vault_signer = get_vault_signer();
        let vault_addr = signer::address_of(&vault_signer);
        
        // Get strategy address
        let strategy_signer = strategy_core::get_strategy_signer();
        let strategy_addr = signer::address_of(&strategy_signer);
        
        // FA Support: Get total balance (Coin + FA) and transfer to strategy
        let available_assets = get_user_total_balance<AssetType>(vault_addr);
        if (available_assets > 0) {
            // Convert Coin to FA first if FA is available, then transfer FA
            if (has_fa_support<AssetType>()) {
                // First convert any Coin to FA
                convert_all_coin_to_fa<AssetType>(&vault_signer);
                
                // Now get the ACTUAL FA balance (after conversion)
                let metadata = get_fa_metadata<AssetType>();
                let actual_fa_balance = get_user_fa_balance<AssetType>(vault_addr);
                
                // Only proceed if we have FA to transfer
                if (actual_fa_balance > 0) {
                    primary_fungible_store::ensure_primary_store_exists(strategy_addr, metadata);
                    let fa = primary_fungible_store::withdraw(&vault_signer, metadata, actual_fa_balance);
                    primary_fungible_store::deposit(strategy_addr, fa);
                };
            } else {
                coin::transfer<AssetType>(&vault_signer, strategy_addr, available_assets);
            };
        };
        
        // Call strategy to rebalance assets across validators
        strategy_core::rebalance<AssetType>(
            &vault_signer,
            validators_stake,
            stake_amounts,
            validators_unstake,
            unstake_amounts,
            delay_transfer_amount
        );
        
        // FA Support: Get actual vault balance (Coin + FA) after rebalancing
        let actual_vault_balance = get_user_total_balance<AssetType>(vault_addr);
        
        // Update vault accounting (buffer is included in strategy_core::balance_of automatically)
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.total_assets = actual_vault_balance;
    }

    public entry fun harvest_fund_manager<AssetType>(
        fund_manager: &signer, 
        validators_stake: vector<address>, 
        stake_amounts: vector<u64>, 
        validators_unstake: vector<address>, 
        unstake_amounts: vector<u64>,
        delay_transfer_amount: u64
    ) acquires VaultInfo, VaultCapability, FundManagerInfo {
        let caller_addr = signer::address_of(fund_manager);
        assert!(is_fund_manager(caller_addr), ERR_NOT_FUND_MANAGER);

        let vault_signer = get_vault_signer();
        let vault_addr = signer::address_of(&vault_signer);
        
        // Get strategy address
        let strategy_signer = strategy_core::get_strategy_signer();
        let strategy_addr = signer::address_of(&strategy_signer);
        
        // FA Support: Get total balance (Coin + FA) and transfer to strategy
        let available_assets = get_user_total_balance<AssetType>(vault_addr);
        if (available_assets > 0) {
            if (has_fa_support<AssetType>()) {
                // First convert any Coin to FA
                convert_all_coin_to_fa<AssetType>(&vault_signer);
                
                // Now get the ACTUAL FA balance (after conversion)
                let metadata = get_fa_metadata<AssetType>();
                let actual_fa_balance = get_user_fa_balance<AssetType>(vault_addr);
                
                // Only proceed if we have FA to transfer
                if (actual_fa_balance > 0) {
                    primary_fungible_store::ensure_primary_store_exists(strategy_addr, metadata);
                    let fa = primary_fungible_store::withdraw(&vault_signer, metadata, actual_fa_balance);
                    primary_fungible_store::deposit(strategy_addr, fa);
                };
            } else {
                coin::transfer<AssetType>(&vault_signer, strategy_addr, available_assets);
            };
        };
        
        // Call strategy to rebalance assets across validators
        strategy_core::rebalance<AssetType>(
            &vault_signer,
            validators_stake,
            stake_amounts,
            validators_unstake,
            unstake_amounts,
            delay_transfer_amount
        );
        
        // FA Support: Get actual vault balance (Coin + FA) after rebalancing
        let actual_vault_balance = get_user_total_balance<AssetType>(vault_addr);
        
        // Update vault accounting to match the actual balance
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.total_assets = actual_vault_balance;
    }

    /// New harvest function with buffer support
    /// Priority: Fill buffer first, then stake remaining assets
    public entry fun harvest_fund_manager_with_buffer<AssetType>(
        fund_manager: &signer, 
        validators_stake: vector<address>, 
        stake_amounts: vector<u64>, 
        validators_unstake: vector<address>, 
        unstake_amounts: vector<u64>,
        delay_transfer_amount: u64,
        buffer_amount: u64
    ) acquires VaultInfo, VaultCapability, FundManagerInfo {
        let caller_addr = signer::address_of(fund_manager);
        assert!(is_fund_manager(caller_addr), ERR_NOT_FUND_MANAGER);

        let vault_signer = get_vault_signer();
        let vault_addr = signer::address_of(&vault_signer);
        
        // Get strategy address
        let strategy_signer = strategy_core::get_strategy_signer();
        let strategy_addr = signer::address_of(&strategy_signer);
        
        // FA Support: Get total balance (Coin + FA) and transfer to strategy
        let available_assets = get_user_total_balance<AssetType>(vault_addr);
        if (available_assets > 0) {
            if (has_fa_support<AssetType>()) {
                // First convert any Coin to FA
                convert_all_coin_to_fa<AssetType>(&vault_signer);
                
                // Now get the ACTUAL FA balance (after conversion)
                let metadata = get_fa_metadata<AssetType>();
                let actual_fa_balance = get_user_fa_balance<AssetType>(vault_addr);
                
                // Only proceed if we have FA to transfer
                if (actual_fa_balance > 0) {
                    primary_fungible_store::ensure_primary_store_exists(strategy_addr, metadata);
                    let fa = primary_fungible_store::withdraw(&vault_signer, metadata, actual_fa_balance);
                    primary_fungible_store::deposit(strategy_addr, fa);
                };
            } else {
                coin::transfer<AssetType>(&vault_signer, strategy_addr, available_assets);
            };
        };
        
        // Call strategy's rebalance_with_buffer which handles buffer transfer and rebalancing
        strategy_core::rebalance_with_buffer<AssetType>(
            &vault_signer,
            validators_stake,
            stake_amounts,
            validators_unstake,
            unstake_amounts,
            delay_transfer_amount,
            buffer_amount
        );
        
        // FA Support: Get actual vault balance (Coin + FA) after rebalancing
        let actual_vault_balance = get_user_total_balance<AssetType>(vault_addr);
        
        // Update vault accounting (buffer is included in strategy_core::balance_of automatically)
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.total_assets = actual_vault_balance;
    }

    /// Initialize buffer mechanism (delegates to strategy_core)
    public entry fun initialize_buffer(
        admin: &signer,
        buffer_bucket_max: u64
    ) {
        strategy_core::initialize_buffer(admin, buffer_bucket_max);
    }

    /// Initialize buffer resource account (delegates to strategy_core)
    public entry fun initialize_buffer_resource_account<AssetType>(
        admin: &signer
    ) {
        strategy_core::initialize_buffer_resource_account<AssetType>(admin);
    }

    /// Set buffer bucket max (delegates to strategy_core)
    public entry fun set_buffer_bucket_max(
        admin: &signer,
        new_max: u64
    ) {
        strategy_core::set_buffer_bucket_max(admin, new_max);
    }

    /// Instant withdrawal from buffer at current rate
    public entry fun instant_withdraw_from_buffer<AssetType>(
        admin: &signer,
        shares: u64,
        receiver: address
    ) acquires VaultInfo, ShareTokenCapability {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        
        // Validate shares > 0
        assert!(shares > 0, ERR_ZERO_DEPOSIT);
        
        // Calculate assets to withdraw at current rate
        let assets = convert_to_assets<AssetType>(shares);
        
        // FA Support: Burn shares from admin's account with FA priority
        let (_fa_burned, _coin_burned) = burn_shares_with_fa_priority(admin, shares);
        
        // Update vault accounting
        let vault = borrow_global_mut<VaultInfo>(@vault);
        vault.total_shares = vault.total_shares - shares;
        // Note: vault.total_assets only tracks vault liquid balance, not buffer
        // Buffer balance is tracked separately and included via balance_of_with_buffer()
        // No need to update vault.total_assets when withdrawing from buffer
        
        // FA Support: Ensure receiver can receive FA (if FA is available)
        if (has_fa_support<AssetType>()) {
            let metadata = get_fa_metadata<AssetType>();
            primary_fungible_store::ensure_primary_store_exists(receiver, metadata);
        } else {
            // Legacy: Register receiver if needed
            if (!coin::is_account_registered<AssetType>(receiver)) {
                if (receiver == signer::address_of(admin)) {
                    coin::register<AssetType>(admin);
                } else {
                    assert!(false, ERR_NOT_AUTHORIZED);
                };
            };
        };
        
        // Call strategy to handle buffer withdrawal (already FA-aware)
        strategy_core::instant_withdraw_from_buffer<AssetType>(admin, shares, assets, receiver);
        
        // Emit withdrawal event
        event::emit(WithdrawEvent {
            withdrawer: signer::address_of(admin),
            receiver,
            owner: signer::address_of(admin),
            assets,
            shares,
            timestamp: timestamp::now_seconds(),
            block_height: block::get_current_block_height()
        });
    }

    public entry fun sync_assets<AssetType>(admin: &signer) acquires VaultInfo, VaultCapability {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        
        // FA Support: Get vault signer and actual vault balance (Coin + FA)
        let vault_signer = get_vault_signer();
        let vault_addr = signer::address_of(&vault_signer);
        let actual_vault_balance = get_user_total_balance<AssetType>(vault_addr);
        
        // Update internal accounting
        // Note: Buffer balance is automatically included in strategy_core::balance_of()
        // So vault.total_assets should only track vault_liquid
        // Total assets = vault.total_assets + strategy_balance (which includes buffer)
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_total = vault.total_assets;
        vault.total_assets = actual_vault_balance;
        let new_total = actual_vault_balance;
        
        // Calculate difference and emit event
        let difference = if (new_total > old_total) {
            new_total - old_total
        } else {
            old_total - new_total
        };
        
        event::emit(AssetsSyncedEvent {
            old_total,
            new_total,
            difference
        });
    }

    // Set the withdrawal delay
    public entry fun set_withdraw_delay(admin: &signer, delay: u64) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_delay = vault.withdraw_delay;
        vault.withdraw_delay = delay;
        event::emit(WithdrawDelayUpdatedEvent { old_delay, new_delay: delay });
    }

    public entry fun set_fee_recipient(admin: &signer, new_fee_recipient: address) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_recipient = vault.fee_recipient;
        vault.fee_recipient = new_fee_recipient;
        event::emit(FeeRecipientUpdatedEvent { old_recipient, new_recipient: new_fee_recipient });
    }

    public entry fun set_withdrawal_fee(admin: &signer, new_fee: u64) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        // Optional: Add boundary check to ensure fee is reasonable
        assert!(new_fee <= FEE_PRECISION / 10, ERR_MATH_OVERFLOW); // Max 10%
        
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_fee = vault.withdrawal_fee;
        vault.withdrawal_fee = new_fee;
        event::emit(WithdrawalFeeUpdatedEvent { old_fee, new_fee });
    }

    public entry fun recover_orphaned_delayed_withdrawal_funds<AssetType>(admin: &signer, amount: u64) acquires VaultInfo, VaultCapability, DelayedWithdrawalCapability {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        assert!(amount > 0, ERR_ZERO_DEPOSIT);

        let delayed_withdrawal_signer = get_delayed_withdrawal_signer();
        let vault_addr = get_vault_resource_address();

        if (has_fa_support<AssetType>()) {
            convert_all_coin_to_fa<AssetType>(&delayed_withdrawal_signer);
            let metadata = get_fa_metadata<AssetType>();
            primary_fungible_store::ensure_primary_store_exists(vault_addr, metadata);
            let fa = primary_fungible_store::withdraw(&delayed_withdrawal_signer, metadata, amount);
            primary_fungible_store::deposit(vault_addr, fa);
        } else {
            coin::transfer<AssetType>(&delayed_withdrawal_signer, vault_addr, amount);
        };

        let actual_vault_balance = get_user_total_balance<AssetType>(vault_addr);
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_total = vault.total_assets;
        vault.total_assets = actual_vault_balance;
        let new_total = actual_vault_balance;
        let difference = if (new_total > old_total) {
            new_total - old_total
        } else {
            old_total - new_total
        };

        event::emit(AssetsSyncedEvent {
            old_total,
            new_total,
            difference
        });
    }

    public entry fun set_fund_manager(admin: &signer, fund_manager: address) acquires FundManagerInfo {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        
        let old_manager = if (exists<FundManagerInfo>(@vault)) {
            let fund_manager_info = borrow_global_mut<FundManagerInfo>(@vault);
            let old_addr = fund_manager_info.fund_manager;
            fund_manager_info.fund_manager = fund_manager;
            old_addr
        } else {
            // First time setting fund manager
            move_to(admin, FundManagerInfo {
                fund_manager
            });
            @0x0 // Use null address as "old" value for first setup
        };
        
        event::emit(FundManagerUpdatedEvent {
            old_manager,
            new_manager: fund_manager
        });
    }



    // ============ Admin Migration Function ============

    /// Initialize VaultShare FA pairing if it doesn't exist
    /// This triggers the internal pairing creation in the coin module
    fun initialize_share_fa() acquires ShareTokenCapability {
        // Check if VaultShare FA pairing exists
        let share_metadata_opt = coin::paired_metadata<VaultShare>();
        if (option::is_none(&share_metadata_opt)) {
            // Create the FA pairing by minting and converting 0 VaultShare
            // This triggers the internal pairing creation in the coin module
            let share_cap = borrow_global<ShareTokenCapability>(@vault);
            let zero_shares = coin::mint(0, &share_cap.mint_cap);
            let zero_fa = coin::coin_to_fungible_asset<VaultShare>(zero_shares);
            fungible_asset::destroy_zero(zero_fa);
        };
    }

    /// Convert all vault assets from Coin to FA format
    /// This should be called by admin after code upgrade to migrate existing assets
    /// All accounts (vault, delayed withdrawal, strategy, buffer) will have their Coin converted to FA
    /// Also initializes VaultShare FA pairing if not exists
    public entry fun convert_vault_assets_to_fa<AssetType>(
        admin: &signer
    ) acquires VaultInfo, VaultCapability, DelayedWithdrawalCapability, ShareTokenCapability {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        
        // Check FA is available for AssetType
        assert!(has_fa_support<AssetType>(), ERR_FA_NOT_INITIALIZED);
        
        // Verify asset type matches vault
        let vault = borrow_global<VaultInfo>(@vault);
        assert!(type_of<AssetType>() == vault.asset_type, ERR_INVALID_ASSET_TYPE);
        
        // Initialize VaultShare FA pairing if not exists
        // This ensures new VaultShares are minted as FA
        initialize_share_fa();
        
        // 1. Convert vault resource account assets
        let vault_signer = get_vault_signer();
        let vault_coin_balance = get_user_coin_balance<AssetType>(signer::address_of(&vault_signer));
        if (vault_coin_balance > 0) {
            convert_all_coin_to_fa<AssetType>(&vault_signer);
        };
        
        // 2. Convert delayed withdrawal account assets
        let delayed_signer = get_delayed_withdrawal_signer();
        let delayed_coin_balance = get_user_coin_balance<AssetType>(signer::address_of(&delayed_signer));
        if (delayed_coin_balance > 0) {
            convert_all_coin_to_fa<AssetType>(&delayed_signer);
        };
        
        // 3. Convert strategy resource account assets (delegated to strategy_core)
        let strategy_converted = strategy_core::convert_strategy_assets_to_fa<AssetType>();
        
        // 4. Convert buffer account assets (delegated to strategy_core)
        let buffer_converted = strategy_core::convert_buffer_assets_to_fa<AssetType>();
        
        // Emit migration event
        event::emit(VaultAssetConversionEvent {
            vault_converted: vault_coin_balance,
            strategy_converted,
            delayed_withdrawal_converted: delayed_coin_balance,
            buffer_converted,
            total_converted: vault_coin_balance + strategy_converted + delayed_coin_balance + buffer_converted,
            timestamp: timestamp::now_seconds()
        });
    }

    #[view]
    public fun total_assets<AssetType>(): u64 acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        // Use balance_of_with_buffer to include buffer balance
        // Note: This requires BufferInfo to be initialized (will abort if not initialized)
        let (strategy_balance, pending_withdrawals) = strategy_core::balance_of_with_buffer<AssetType>();
        // Combine internal accounting with strategy balance (which includes buffer)
        // vault.total_assets = vault_liquid only
        // Total = vault_liquid + (strategy_liquid + staked + buffer) - pending_withdrawals
        vault.total_assets + strategy_balance - pending_withdrawals
    }

     #[view]
    public fun total_assets_without_strategy<AssetType>(): u64 acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        
        // Combine internal accounting with strategy balance
        vault.total_assets
    }





    #[view]
    public fun is_account_ready<AssetType>(account_addr: address): bool {
        coin::is_account_registered<AssetType>(account_addr) && 
        coin::is_account_registered<VaultShare>(account_addr)
    }

    

    public entry fun initialize_account<AssetType>(account: &signer) {
        if (!coin::is_account_registered<AssetType>(signer::address_of(account))) {
            coin::register<AssetType>(account);
        };
        if (!coin::is_account_registered<VaultShare>(signer::address_of(account))) {
            coin::register<VaultShare>(account);
        };
    }




    #[test_only]
    public fun get_vault_signer_for_testing(): signer acquires VaultCapability {
        get_vault_signer()
    }

    fun is_fund_manager(signer_addr: address): bool acquires FundManagerInfo {
        if (!exists<FundManagerInfo>(@vault)) {
            false
        } else {
            let fund_manager_info = borrow_global<FundManagerInfo>(@vault);
            signer_addr == fund_manager_info.fund_manager
        }
    }

    /// Max operation limits
    #[view]
    public fun max_deposit<AssetType>(_user: address): u64 acquires VaultInfo {
        // Get the current total assets before borrowing VaultInfo
        let current_tvl = total_assets<AssetType>();
        
        // Now borrow VaultInfo
        let vault = borrow_global<VaultInfo>(@vault);
        
        if (vault.paused) {
            0
        } else if (vault.tvl_limit == 0) {
            MAX_U64
        } else {
            if (current_tvl >= vault.tvl_limit) {
                0
            } else {
                vault.tvl_limit - current_tvl
            }
        }
    }

    #[view]
    public fun max_mint<AssetType>(_user: address): u64 {
        MAX_U64
    }

    #[view]
    public fun max_withdraw<AssetType>(user: address): u64 acquires VaultInfo {
        // FA Support: Get total VaultShare balance (Coin + FA)
        let shares = get_user_total_vaultshare_balance(user);
        convert_to_assets<AssetType>(shares)
    }

    #[view]
    public fun max_redeem(user: address): u64 {
        // FA Support: Get total VaultShare balance (Coin + FA)
        get_user_total_vaultshare_balance(user)
    }

    #[view]
    public fun has_pending_withdrawal(user: address): bool acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        if (!table::contains(&vault.withdraw_requests, user)) {
            return false
        };
        
        let user_requests = table::borrow(&vault.withdraw_requests, user);
        let request_ids_len = vector::length(&user_requests.request_ids);
        
        let i = 0;
        while (i < request_ids_len) {
            let request_id = *vector::borrow(&user_requests.request_ids, i);
            if (table::contains(&user_requests.requests, request_id)) {
                let request = table::borrow(&user_requests.requests, request_id);
                if (!request.processed) {
                    return true
                };
            };
            i = i + 1;
        };
        
        false
    }
    
    #[view]
    public fun get_withdrawal_details(user: address): (u64, u64, bool) acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        assert!(table::contains(&vault.withdraw_requests, user), ERR_NOT_AUTHORIZED);
        
        let user_requests = table::borrow(&vault.withdraw_requests, user);
        let request_ids_len = vector::length(&user_requests.request_ids);
        
        // Return details of first unprocessed request, if any
        let i = 0;
        while (i < request_ids_len) {
            let request_id = *vector::borrow(&user_requests.request_ids, i);
            if (table::contains(&user_requests.requests, request_id)) {
                let request = table::borrow(&user_requests.requests, request_id);
                if (!request.processed) {
                    return (request.assets, request.request_time, request.processed)
                };
            };
            i = i + 1;
        };
        
        // If no pending requests, return zeros
        (0, 0, true)
    }

    // Add new view functions
    #[view]
    public fun get_claimable_amount<AssetType>(user: address): u64 acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        if (!table::contains(&vault.withdraw_requests, user)) {
            return 0
        };
        
        let user_requests = table::borrow(&vault.withdraw_requests, user);
        let current_time = timestamp::now_seconds();
        let delay = vault.withdraw_delay;
        let claimable_amount = 0;
        
        let request_ids_len = vector::length(&user_requests.request_ids);
        
        let i = 0;
        while (i < request_ids_len) {
            let request_id = *vector::borrow(&user_requests.request_ids, i);
            if (table::contains(&user_requests.requests, request_id)) {
                let request = table::borrow(&user_requests.requests, request_id);
                if (!request.processed && current_time >= request.request_time + delay) {
                    claimable_amount = claimable_amount + request.assets;
                };
            };
            i = i + 1;
        };
        
        claimable_amount
    }

    #[view]
    public fun get_all_pending_requests(user: address): (vector<u64>, vector<u64>, vector<bool>, vector<u64>) acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        assert!(table::contains(&vault.withdraw_requests, user), ERR_NOT_AUTHORIZED);
        
        let user_requests = table::borrow(&vault.withdraw_requests, user);
        let request_ids_len = vector::length(&user_requests.request_ids);
        
        // Create separate vectors for each field
        let assets_vec = vector::empty<u64>();
        let request_time_vec = vector::empty<u64>();
        let processed_vec = vector::empty<bool>();
        let request_id_vec = vector::empty<u64>();
        
        let i = 0;
        while (i < request_ids_len) {
            let request_id = *vector::borrow(&user_requests.request_ids, i);
            if (table::contains(&user_requests.requests, request_id)) {
                let request = table::borrow(&user_requests.requests, request_id);
                if (!request.processed) {
                    vector::push_back(&mut assets_vec, request.assets);
                    vector::push_back(&mut request_time_vec, request.request_time);
                    vector::push_back(&mut processed_vec, request.processed);
                    vector::push_back(&mut request_id_vec, request.request_id);
                };
            };
            i = i + 1;
        };
        
        (assets_vec, request_time_vec, processed_vec, request_id_vec)
    }

    #[view]
    public fun get_withdrawal_forensics<AssetType>(): (address, address, address, address, u64, u64, u64, u64, u64, u64, u64, u64, u64) acquires VaultInfo, VaultCapability, DelayedWithdrawalCapability {
        let computed_total_assets = total_assets<AssetType>();
        let vault = borrow_global<VaultInfo>(@vault);
        let recorded_total_assets = vault.total_assets;
        let total_shares = vault.total_shares;
        let vault_addr = get_vault_resource_address();
        let strategy_addr = strategy_core::get_strategy_resource_address();
        let delayed_withdrawal_addr = get_delayed_withdrawal_address_internal();
        let buffer_addr = strategy_core::get_buffer_resource_address();
        let vault_liquid_balance = get_user_total_balance<AssetType>(vault_addr);
        let strategy_liquid_balance = strategy_core::get_strategy_liquid_balance<AssetType>();
        let strategy_staked_balance = strategy_core::get_strategy_total_staked<AssetType>();
        let delayed_withdrawal_balance = get_user_total_balance<AssetType>(delayed_withdrawal_addr);
        let buffer_balance = strategy_core::get_buffer_balance<AssetType>();
        let pending_withdrawals = strategy_core::get_strategy_pending_withdrawals();

        (
            vault_addr,
            strategy_addr,
            delayed_withdrawal_addr,
            buffer_addr,
            recorded_total_assets,
            total_shares,
            vault_liquid_balance,
            strategy_liquid_balance,
            strategy_staked_balance,
            delayed_withdrawal_balance,
            buffer_balance,
            pending_withdrawals,
            computed_total_assets
        )
    }

     // Test-only version of harvest that doesn't rely on strategy_core
    #[test_only]
    public fun harvest_test<AssetType>(admin: &signer, user_addr: address) acquires VaultInfo, VaultCapability {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);

        let vault_signer = get_vault_signer_for_testing();
        let vault_addr = signer::address_of(&vault_signer);
        
        // Since we're testing, we don't need to call strategy_core functions
        // We've already simulated yield by transferring directly to vault
        
        // Get current balance (after we added simulated yield)
        let current_balance = coin::balance<AssetType>(vault_addr);
        
        // Get the vault info
        let vault = borrow_global_mut<VaultInfo>(@vault);
        
        // Calculate yield as the difference between current balance and recorded assets
        let yield_amount = current_balance - vault.total_assets;
        
        if (yield_amount > 0) {
            let fee_percentage = vault.performance_fee;
            let fee_recipient = vault.fee_recipient;
            
            // Calculate fee amount
            let fee_amount = if (fee_percentage > 0) {
                // Calculate fee amount with proper precision
                let fee_u128 = (yield_amount as u128) * (fee_percentage as u128) / (FEE_PRECISION as u128);
                (fee_u128 as u64)
            } else {
                0
            };
            
            // Transfer fee to fee recipient if non-zero
            if (fee_amount > 0) {
                if (coin::is_account_registered<AssetType>(fee_recipient)) {
                    coin::transfer<AssetType>(
                        &vault_signer,
                        fee_recipient,
                        fee_amount
                    );
                };
            };
            
            // Calculate remaining yield after fee
            let remaining_yield = yield_amount - fee_amount;
            
            // Update vault accounting with remaining yield
            vault.total_assets = vault.total_assets + remaining_yield;
            
            // Emit yield event with fee information
            event::emit(YieldGeneratedEvent { 
                yield_amount,
                fee_amount,
                remaining_yield,
                fee_recipient
            });
        };
    }

    // Add a function for admins to update the minimum withdrawal amount
    public entry fun set_min_withdrawal_amount(admin: &signer, new_amount: u64) acquires VaultInfo {
        assert!(signer::address_of(admin) == @vault, ERR_NOT_ADMIN);
        
        let vault = borrow_global_mut<VaultInfo>(@vault);
        let old_amount = vault.min_withdrawal_amount;
        vault.min_withdrawal_amount = new_amount;
        
        // Emit event for the update
        event::emit(MinWithdrawalAmountUpdatedEvent {
            old_amount,
            new_amount
        });
    }

    // Add a view function to get the current minimum withdrawal amount
    #[view]
    public fun get_min_withdrawal_amount(): u64 acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        vault.min_withdrawal_amount
    }

    #[view]
    public fun get_vault_info<AssetType>(): (
        String,     // name
        String,     // symbol
        u8,         // decimals
        u64,        // total_assets
        u64,        // total_shares
        bool,       // paused
        u64,        // tvl_limit
        u64,        // performance_fee
        u64,        // withdraw_delay
        address,    // fee_recipient
        u64,        // withdrawal_fee
        u64         // min_withdrawal_amount
    ) acquires VaultInfo {
        let vault = borrow_global<VaultInfo>(@vault);
        (
            vault.name,
            vault.symbol,
            vault.decimals,
            vault.total_assets,
            vault.total_shares,
            vault.paused,
            vault.tvl_limit,
            vault.performance_fee,
            vault.withdraw_delay,
            vault.fee_recipient,
            vault.withdrawal_fee,
            vault.min_withdrawal_amount
        )
    }

    #[view]
    public fun get_fund_manager(): address acquires FundManagerInfo {
        if (!exists<FundManagerInfo>(@vault)) {
            @0x0 // Return null address if not set
        } else {
            let fund_manager_info = borrow_global<FundManagerInfo>(@vault);
            fund_manager_info.fund_manager
        }
    }

    /// Get buffer resource account address (delegates to strategy_core)
    #[view]
    public fun get_buffer_resource_address(): address {
        strategy_core::get_buffer_resource_address()
    }

    /// Get buffer balance (delegates to strategy_core)
    #[view]
    public fun get_buffer_balance<AssetType>(): u64 {
        strategy_core::get_buffer_balance<AssetType>()
    }

    /// Get buffer info (delegates to strategy_core)
    #[view]
    public fun get_buffer_info<AssetType>(): (u64, u64) {
        strategy_core::get_buffer_info<AssetType>()
    }

    /// Check if buffer is full (delegates to strategy_core)
    #[view]
    public fun is_buffer_full<AssetType>(): bool {
        strategy_core::is_buffer_full<AssetType>()
    }

}