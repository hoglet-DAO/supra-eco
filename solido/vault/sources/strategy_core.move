module vault::strategy_core {
    use std::signer;
    use std::vector;
    use supra_framework::account;
    use supra_framework::coin::{Self};
    use supra_framework::event;
    use supra_framework::timestamp;
    use vault::vault_core;
    use vault::strategy_validator;
    use vault::strategy_staking;
    use vault::strategy_delegation;
    // FA Support imports
    use supra_framework::fungible_asset::{Self, FungibleAsset, Metadata};
    use supra_framework::primary_fungible_store;
    use supra_framework::object::{Self, Object};
    use std::option::{Self, Option};

    friend vault::vault_core;

    // Error codes
    const ERR_NOT_ADMIN: u64 = 1;
    const ERR_ALREADY_INITIALIZED: u64 = 2;
    const ERR_ZERO_AMOUNT: u64 = 3;
    const ERR_INSUFFICIENT_FUNDS: u64 = 4;
    const ERR_INSUFFICIENT_DELAY_TRANSFER: u64 = 5;
    const ERR_BUFFER_NOT_INITIALIZED: u64 = 6;
    const ERR_INVALID_BUFFER_AMOUNT: u64 = 7;
    const ERR_INSUFFICIENT_FUNDS_FOR_BUFFER: u64 = 8;
    const ERR_INSUFFICIENT_BUFFER_BALANCE: u64 = 9;
    const ERR_DELAY_EXCEEDS_PENDING: u64 = 12;

    // Core strategy information - simplified
    struct CoreInfo has key {
        initialized: bool,
        pending_withdrawals: u64,
        vault_addr: address,
        delayed_withdrawal_addr: address,
        resource_signer_cap: account::SignerCapability,
    }

    /// Buffer mechanism for instant withdrawals
    struct BufferInfo has key {
        buffer_bucket_max: u64,      // Maximum buffer amount
        buffer_address: address,      // Buffer resource account address
    }

    struct BufferCapability has key {
        cap: account::SignerCapability
    }

    // Events
    #[event]
    struct DepositEvent has drop, store {
        sender: address,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct WithdrawEvent has drop, store {
        sender: address,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct RebalanceEvent has drop, store {
        staked_amount: u64,
        pending_withdrawals: u64,
        timestamp: u64
    }

    #[event]
    struct BufferFilledEvent has drop, store {
        buffer_amount: u64,
        current_buffer_balance: u64,
        buffer_bucket_max: u64,
        timestamp: u64
    }

    #[event]
    struct BufferBucketMaxUpdatedEvent has drop, store {
        old_max: u64,
        new_max: u64
    }

    // FA Support error codes
    const ERR_FA_NOT_INITIALIZED: u64 = 10;
    const ERR_INSUFFICIENT_FA_BALANCE: u64 = 11;

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

    /// Get Coin balance for an address (returns 0 if not registered)
    fun get_coin_balance<AssetType>(addr: address): u64 {
        if (!coin::is_account_registered<AssetType>(addr)) {
            return 0
        };
        coin::balance<AssetType>(addr)
    }

    /// Get FA balance for an address (returns 0 if no FA support or no store)
    fun get_fa_balance<AssetType>(addr: address): u64 {
        let metadata_opt = coin::paired_metadata<AssetType>();
        if (option::is_none(&metadata_opt)) {
            return 0
        };
        let metadata = *option::borrow(&metadata_opt);
        if (!primary_fungible_store::is_balance_at_least(addr, metadata, 1)) {
            return 0
        };
        primary_fungible_store::balance(addr, metadata)
    }

    /// Get total balance for an address
    /// NOTE: In Supra, coin::balance() already returns Coin + FA when pairing is enabled
    fun get_total_balance<AssetType>(addr: address): u64 {
        get_coin_balance<AssetType>(addr)
    }

    /// Convert all Coin to FA for a signer's address
    fun convert_all_coin_to_fa<AssetType>(signer_ref: &signer) {
        let addr = signer::address_of(signer_ref);
        let coin_balance = get_coin_balance<AssetType>(addr);
        if (coin_balance == 0) {
            return
        };
        let coins = coin::withdraw<AssetType>(signer_ref, coin_balance);
        let fa = coin::coin_to_fungible_asset(coins);
        primary_fungible_store::deposit(addr, fa);
    }

    /// Transfer assets to destination using FA if available (converts Coin to FA first)
    /// Will abort if insufficient FA balance after conversion
    fun transfer_with_fa_support<AssetType>(
        signer_ref: &signer,
        destination: address,
        amount: u64
    ) {
        if (has_fa_support<AssetType>()) {
            // Convert any Coin to FA first
            convert_all_coin_to_fa<AssetType>(signer_ref);
            
            // Get actual FA balance after conversion and verify we have enough
            let sender_addr = signer::address_of(signer_ref);
            let actual_fa_balance = get_fa_balance<AssetType>(sender_addr);
            assert!(actual_fa_balance >= amount, ERR_INSUFFICIENT_FUNDS);
            
            // Get FA metadata and ensure destination can receive FA
            let metadata = get_fa_metadata<AssetType>();
            primary_fungible_store::ensure_primary_store_exists(destination, metadata);
            
            // Transfer FA
            let fa = primary_fungible_store::withdraw(signer_ref, metadata, amount);
            primary_fungible_store::deposit(destination, fa);
        } else {
            // Legacy Coin transfer
            coin::transfer<AssetType>(signer_ref, destination, amount);
        };
    }

    // Initialize the strategy
    public(friend) fun initialize<AssetType>(
        admin: &signer,
        vault_addr: address,
        delayed_withdrawal_addr: address
    ) {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault,ERR_NOT_ADMIN);
        assert!(!exists<CoreInfo>(@vault), ERR_ALREADY_INITIALIZED);

        // Create resource account
        let (resource_signer, resource_signer_cap) = account::create_resource_account(admin, b"vault_strategy");
        let resource_addr = signer::address_of(&resource_signer);

        // Register the resource account for AssetType
        if (!coin::is_account_registered<AssetType>(resource_addr)) {
            coin::register<AssetType>(&resource_signer);
        };

        // Initialize core info - simplified
        move_to(admin, CoreInfo {
            initialized: true,
            pending_withdrawals: 0,
            vault_addr,
            delayed_withdrawal_addr,
            resource_signer_cap,
        });

        // Initialize other modules
        strategy_validator::initialize<AssetType>(admin);
        strategy_staking::initialize<AssetType>(admin);
        strategy_delegation::initialize<AssetType>(admin);
    }

    /// Initialize buffer mechanism (sets max buffer amount)
    /// Must be called before initialize_buffer_resource_account
    public(friend) fun initialize_buffer(
        admin: &signer,
        buffer_bucket_max: u64
    ) {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        assert!(!exists<BufferInfo>(@vault), ERR_ALREADY_INITIALIZED);
        
        move_to(admin, BufferInfo {
            buffer_bucket_max,
            buffer_address: @0x0,  // Will be updated in initialize_buffer_resource_account
        });
    }

    /// Initialize buffer resource account (one-time setup after deployment)
    /// This must be called after initialize_buffer
    public(friend) fun initialize_buffer_resource_account<AssetType>(
        admin: &signer
    ) acquires BufferInfo {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        assert!(exists<BufferInfo>(@vault), ERR_BUFFER_NOT_INITIALIZED);
        
        // Check if already initialized
        if (exists<BufferCapability>(@vault)) {
            return  // Already initialized
        };
        
        // Create new buffer resource account
        let (buffer_signer, buffer_cap) = account::create_resource_account(admin, b"buffer_account");
        let buffer_addr = signer::address_of(&buffer_signer);
        
        // Register for asset type
        if (!coin::is_account_registered<AssetType>(buffer_addr)) {
            coin::register<AssetType>(&buffer_signer);
        };
        
        // Store capability
        move_to(admin, BufferCapability { cap: buffer_cap });
        
        // Update BufferInfo with address
        let buffer_info = borrow_global_mut<BufferInfo>(@vault);
        buffer_info.buffer_address = buffer_addr;
    }

    /// Get buffer signer
    fun get_buffer_signer(): signer acquires BufferCapability {
        let buffer_cap = borrow_global<BufferCapability>(@vault);
        account::create_signer_with_capability(&buffer_cap.cap)
    }

    /// Set buffer bucket max
    public(friend) fun set_buffer_bucket_max(
        admin: &signer,
        new_max: u64
    ) acquires BufferInfo {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        
        let buffer_info = borrow_global_mut<BufferInfo>(@vault);
        let old_max = buffer_info.buffer_bucket_max;
        buffer_info.buffer_bucket_max = new_max;
        
        event::emit(BufferBucketMaxUpdatedEvent {
            old_max,
            new_max
        });
    }

    // Deposit assets from the vault into the strategy
    public(friend) fun deposit<AssetType>(
        sender: address,
        amount: u64
    ): u64 {
        assert!(amount > 0,ERR_ZERO_AMOUNT);
        
        // No need to track unstaked_assets anymore
        
        // Emit deposit event
        event::emit(DepositEvent {
            sender,
            amount,
            timestamp: timestamp::now_seconds()
        });
        
        amount
    }

    // Withdraw assets from the strategy
    public(friend) fun withdraw<AssetType>(
        sender: address,
        amount: u64
    ) acquires CoreInfo {
        assert!(amount > 0,ERR_ZERO_AMOUNT);
        
        // Update pending withdrawals
        let core_info = borrow_global_mut<CoreInfo>(@vault);
        core_info.pending_withdrawals = core_info.pending_withdrawals + amount;
        
        // Emit withdraw event
        event::emit(WithdrawEvent {
            sender,
            amount,
            timestamp: timestamp::now_seconds()
        });
    }

    // Keep withdraw_unlocked simple - just collect funds, no transfers
    // FA Support: After PBO returns Coin, convert to FA
    fun withdraw_unlocked<AssetType>(): u64 acquires CoreInfo {
        // Get strategy signer
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        
        // Call withdraw_unlocked to get any available funds from validators
        // PBO returns funds as Coin to strategy resource account
        let withdrawn_amount = strategy_delegation::withdraw_unlocked<AssetType>(&resource_signer);
        
        // FA Support: Convert returned Coin to FA (if FA is available)
        // This is critical - PBO returns Coin, we need to convert to FA
        if (withdrawn_amount > 0 && has_fa_support<AssetType>()) {
            convert_all_coin_to_fa<AssetType>(&resource_signer);
        };
        
        // Return how much was collected (no transfers here)
        withdrawn_amount
    }

    // Enhanced rebalance function with delay transfer amount
    public(friend) fun rebalance<AssetType>(
        admin: &signer,
        validators_stake: vector<address>, 
        stake_amounts: vector<u64>,
        validators_unstake: vector<address>,
        unstake_amounts: vector<u64>,
        delay_transfer_amount: u64
    ) acquires CoreInfo {
        // Get strategy signer
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);
        
        // First handle staking
        let i = 0;
        let len = vector::length(&validators_stake);
        
        while (i < len) {
            let validator = *vector::borrow(&validators_stake, i);
            let amount = *vector::borrow(&stake_amounts, i);
            
            if (amount > 0) {
                // Stake directly using amount
                strategy_staking::stake_asset<AssetType>(&resource_signer, validator, amount);
            };
            
            i = i + 1;
        };
        
        // Then handle unstaking
        let i = 0;
        let len = vector::length(&validators_unstake);
        while (i < len) {
            let validator = *vector::borrow(&validators_unstake, i);
            let amount = *vector::borrow(&unstake_amounts, i);
            
            if (amount > 0) {
                // Unstake directly using amount
                strategy_staking::unstake_asset<AssetType>(&resource_signer, validator, amount);
            };
            
            i = i + 1;
        };
        
        // Now collect unlocked funds (no transfers, just collection)
        let unlocked_amount = withdraw_unlocked<AssetType>();

        // Handle delay transfer amount and update pending_withdrawals
        if (delay_transfer_amount > 0) {
            // Check that delay_transfer_amount >= unlocked_amount
            assert!(delay_transfer_amount >= unlocked_amount, ERR_INSUFFICIENT_DELAY_TRANSFER);
            // FA Support: Check total liquid balance (Coin + FA)
            let current_liquid_balance = get_total_balance<AssetType>(resource_addr);
            assert!(current_liquid_balance >= delay_transfer_amount, ERR_INSUFFICIENT_FUNDS);
            
            // Transfer the specified amount to delayed withdrawal account
            let delayed_withdrawal_addr = {
                let core_info = borrow_global<CoreInfo>(@vault);
                core_info.delayed_withdrawal_addr
            };
            
            transfer_with_fa_support<AssetType>(&resource_signer, delayed_withdrawal_addr, delay_transfer_amount);
            
            // Delay funding must not exceed recorded withdrawal obligations.
            let core_info = borrow_global_mut<CoreInfo>(@vault);
            assert!(core_info.pending_withdrawals >= delay_transfer_amount, ERR_DELAY_EXCEEDS_PENDING);
            core_info.pending_withdrawals = core_info.pending_withdrawals - delay_transfer_amount;
        };
        
        // Emit rebalance event
        let pending_withdrawals = {
            let core_info = borrow_global<CoreInfo>(@vault);
            core_info.pending_withdrawals
        };
        
        event::emit(RebalanceEvent {
            staked_amount: strategy_delegation::get_total_staked<AssetType>(resource_addr),
            pending_withdrawals,
            timestamp: timestamp::now_seconds()
        });

        // Transfer any remaining assets in strategy resource back to vault
        let vault_addr = {
            let core_info = borrow_global<CoreInfo>(@vault);
            core_info.vault_addr
        };
        let remaining_balance = get_total_balance<AssetType>(resource_addr);
        if (remaining_balance > 0) {
            transfer_with_fa_support<AssetType>(&resource_signer, vault_addr, remaining_balance);
        };
    }

    /// Rebalance function with buffer support
    /// Priority: Fill buffer first, then call regular rebalance with remaining assets
    public(friend) fun rebalance_with_buffer<AssetType>(
        admin: &signer,
        validators_stake: vector<address>, 
        stake_amounts: vector<u64>,
        validators_unstake: vector<address>,
        unstake_amounts: vector<u64>,
        delay_transfer_amount: u64,
        buffer_amount: u64
    ) acquires CoreInfo, BufferInfo, BufferCapability {
        // Get strategy signer
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);
        
        // Get buffer info and signer
        let buffer_info = borrow_global<BufferInfo>(@vault);
        let buffer_signer = get_buffer_signer();
        let buffer_addr = signer::address_of(&buffer_signer);
        
        // FA Support: Get current buffer and strategy balances (Coin + FA)
        let current_buffer_balance = get_total_balance<AssetType>(buffer_addr);
        let available_assets = get_total_balance<AssetType>(resource_addr);
        
        // Validate buffer_amount
        let buffer_needed = if (buffer_info.buffer_bucket_max > current_buffer_balance) {
            buffer_info.buffer_bucket_max - current_buffer_balance
        } else {
            0
        };
        
        // Ensure buffer_amount doesn't exceed what's needed
        assert!(buffer_amount <= buffer_needed, ERR_INVALID_BUFFER_AMOUNT);
        assert!(available_assets >= buffer_amount, ERR_INSUFFICIENT_FUNDS_FOR_BUFFER);
        
        // Step 1: Fill buffer first (priority)
        if (buffer_amount > 0) {
            transfer_with_fa_support<AssetType>(
                &resource_signer,
                buffer_addr,
                buffer_amount
            );
            
            // Emit buffer filled event
            event::emit(BufferFilledEvent {
                buffer_amount,
                current_buffer_balance: current_buffer_balance + buffer_amount,
                buffer_bucket_max: buffer_info.buffer_bucket_max,
                timestamp: timestamp::now_seconds()
            });
        };
        
        // Step 2: Call the regular rebalance function with remaining assets
        // The rebalance function will handle staking/unstaking/delay transfers
        rebalance<AssetType>(
            admin,
            validators_stake,
            stake_amounts,
            validators_unstake,
            unstake_amounts,
            delay_transfer_amount
        );
    }

   
    public(friend) fun instant_withdraw_from_buffer<AssetType>(
        admin: &signer,
        shares: u64,
        assets: u64,  // Assets calculated at vault level (at current share price)
        receiver: address
    ) acquires BufferCapability {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        assert!(exists<BufferCapability>(@vault), ERR_BUFFER_NOT_INITIALIZED);
        
        // Validate
        assert!(shares > 0, ERR_ZERO_AMOUNT);
        assert!(assets > 0, ERR_ZERO_AMOUNT);
        
        // Get buffer balance (Coin + FA)
        let buffer_signer = get_buffer_signer();
        let buffer_addr = signer::address_of(&buffer_signer);
        let buffer_balance = get_total_balance<AssetType>(buffer_addr);
        
        // Ensure buffer has enough funds
        assert!(buffer_balance >= assets, ERR_INSUFFICIENT_BUFFER_BALANCE);
        
        // Transfer assets from buffer to receiver (as FA if available)
        // Note: Receiver registration is handled at vault level before calling this function
        transfer_with_fa_support<AssetType>(&buffer_signer, receiver, assets);
    }

    /// View functions for buffer
    #[view]
    public fun get_buffer_balance<AssetType>(): u64 acquires BufferInfo {
        if (!exists<BufferInfo>(@vault)) {
            return 0
        };
        let buffer_info = borrow_global<BufferInfo>(@vault);
        if (buffer_info.buffer_address == @0x0) {
            return 0
        };
        // FA Support: Include both Coin and FA balance
        get_total_balance<AssetType>(buffer_info.buffer_address)
    }

    #[view]
    public fun get_buffer_info<AssetType>(): (u64, u64) acquires BufferInfo {
        if (!exists<BufferInfo>(@vault)) {
            return (0, 0)
        };
        let buffer_info = borrow_global<BufferInfo>(@vault);
        let current_balance = if (buffer_info.buffer_address != @0x0) {
            // FA Support: Include both Coin and FA balance
            get_total_balance<AssetType>(buffer_info.buffer_address)
        } else {
            0
        };
        (buffer_info.buffer_bucket_max, current_balance)
    }

    #[view]
    public fun is_buffer_full<AssetType>(): bool acquires BufferInfo {
        if (!exists<BufferInfo>(@vault)) {
            return false
        };
        let buffer_info = borrow_global<BufferInfo>(@vault);
        if (buffer_info.buffer_address == @0x0) {
            return false
        };
        // FA Support: Include both Coin and FA balance
        let current_balance = get_total_balance<AssetType>(buffer_info.buffer_address);
        current_balance >= buffer_info.buffer_bucket_max
    }

    #[view]
    public fun get_buffer_resource_address(): address acquires BufferInfo {
        if (!exists<BufferInfo>(@vault)) {
            return @0x0
        };
        let buffer_info = borrow_global<BufferInfo>(@vault);
        buffer_info.buffer_address
    }

    // Get the strategy resource signer
    public(friend) fun get_strategy_signer(): signer acquires CoreInfo {
        let core_info = borrow_global<CoreInfo>(@vault);
        account::create_signer_with_capability(&core_info.resource_signer_cap)
    }

    // Get complete balance of assets for the strategy (without buffer)
    // Backward compatible - doesn't include buffer
    // FA Support: Uses total balance (Coin + FA)
    public fun balance_of<AssetType>(): (u64, u64) acquires CoreInfo {
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);
        
        // FA Support: Get total balance (Coin + FA)
        let strategy_balance = get_total_balance<AssetType>(resource_addr);
        let total_staked = strategy_delegation::get_total_staked<AssetType>(resource_addr);
        
        // Get pending withdrawals (which represents funds that need processing)
        let pending_withdrawals = {
            let core_info = borrow_global<CoreInfo>(@vault);
            core_info.pending_withdrawals
        };
        
        // Available balance = liquid + staked - pending withdrawals (no buffer)
        (strategy_balance + total_staked, pending_withdrawals)
    }

    // Get complete balance of assets for the strategy (with buffer)
    // Includes buffer balance - BufferInfo must be initialized (acquires BufferInfo)
    // This function calls balance_of() and adds buffer balance
    // FA Support: Uses total balance (Coin + FA)
    public fun balance_of_with_buffer<AssetType>(): (u64, u64) acquires CoreInfo, BufferInfo {
        // Get base balance from balance_of() (includes strategy + staked, excludes buffer)
        let (base_balance, pending_withdrawals) = balance_of<AssetType>();
        
        // Add buffer balance (BufferInfo must be initialized - checked by acquires)
        let buffer_info = borrow_global<BufferInfo>(@vault);
        let buffer_balance = if (buffer_info.buffer_address != @0x0) {
            // FA Support: Get total buffer balance (Coin + FA)
            get_total_balance<AssetType>(buffer_info.buffer_address)
        } else {
            0
        };
        
        // Available balance = base (liquid + staked) + buffer - pending withdrawals
        (base_balance + buffer_balance, pending_withdrawals)
    }
    
    // Get pending withdrawals
    public fun get_pending_withdrawals(): u64 acquires CoreInfo {
        let core_info = borrow_global<CoreInfo>(@vault);
        core_info.pending_withdrawals
    }

    // Check if strategy is initialized
    public fun is_initialized(): bool {
        exists<CoreInfo>(@vault)
    }

    // Add validator
    public entry fun add_validator(
        admin: &signer,
        validator: address
    ) {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        
        // Add validator
        strategy_validator::add_validator(admin, validator);
    }

    // Remove validator
    public entry fun remove_validator(
        admin: &signer,
        validator: address
    ) {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @vault, ERR_NOT_ADMIN);
        
        // Remove validator
        strategy_validator::remove_validator(admin, validator);
    }

    #[view]
    /// Returns all validators' staked amounts for the strategy account
    public fun get_all_validator_stakes<AssetType>(): (vector<address>, vector<u64>, vector<u64>, vector<u64>) acquires CoreInfo {
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);
        
        let validators = strategy_validator::get_all_validators();
        let active_stakes = vector::empty<u64>();
        let inactive_stakes = vector::empty<u64>();
        let pending_inactive_stakes = vector::empty<u64>();
        
        let i = 0;
        let len = vector::length(&validators);
        while (i < len) {
            let validator = *vector::borrow(&validators, i);
            let (active, inactive, pending_inactive) = strategy_delegation::get_validator_staked<AssetType>(
                validator,
                resource_addr
            );
            
            vector::push_back(&mut active_stakes, active);
            vector::push_back(&mut inactive_stakes, inactive);
            vector::push_back(&mut pending_inactive_stakes, pending_inactive);
            
            i = i + 1;
        };
        
        (validators, active_stakes, inactive_stakes, pending_inactive_stakes)
    }

    #[view]
    /// Returns all validators' staked amounts for the strategy account
    public fun get_validator_stakes<AssetType>(validator: address): (u64, u64, u64) acquires CoreInfo {
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);

        strategy_delegation::get_validator_staked<AssetType>(validator, resource_addr)
    }

    #[view]
    /// Returns all validators' withdrawable amounts for the strategy account
    public fun get_all_withdrawable_amounts<AssetType>(): (vector<address>, vector<u64>) acquires CoreInfo {
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);
        
        strategy_delegation::get_withdrawable_amounts<AssetType>(resource_addr)
    }

    #[view]
    /// Returns the total staked amount across all validators for the strategy account
    public fun get_strategy_total_staked<AssetType>(): u64 acquires CoreInfo {
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);
        
        strategy_delegation::get_total_staked<AssetType>(resource_addr)
    }

    public(friend) fun get_strategy_resource_address(): address acquires CoreInfo {
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        signer::address_of(&resource_signer)
    }

    #[view]
    /// Returns the current pending withdrawals amount
    public fun get_strategy_pending_withdrawals(): u64 acquires CoreInfo {
        let core_info = borrow_global<CoreInfo>(@vault);
        core_info.pending_withdrawals
    }

    #[view]
    /// Returns the current balance in the strategy's resource account (Coin + FA)
    public fun get_strategy_liquid_balance<AssetType>(): u64 acquires CoreInfo {
        let resource_addr = get_strategy_resource_address();
        
        // FA Support: Include both Coin and FA balance
        get_total_balance<AssetType>(resource_addr)
    }

    #[view]
    /// Returns all strategy balance components: liquid, staked, and pending withdrawals
    public fun get_strategy_complete_balance<AssetType>(): (u64, u64, u64) acquires CoreInfo {
        let liquid_balance = get_strategy_liquid_balance<AssetType>();
        let staked_balance = get_strategy_total_staked<AssetType>();
        let pending_withdrawals = get_strategy_pending_withdrawals();
        
        (liquid_balance, staked_balance, pending_withdrawals)
    }

    #[view]
    /// Returns active validators list
    public fun get_strategy_active_validators(): vector<address> {
        strategy_validator::get_active_validators()
    }

    // ============ Admin Migration Helper Functions ============

    /// Convert all Coin assets in strategy resource account to FA
    /// Called by vault_core as part of admin migration
    public(friend) fun convert_strategy_assets_to_fa<AssetType>(): u64 acquires CoreInfo {
        // Check FA is available
        if (!has_fa_support<AssetType>()) {
            return 0
        };
        
        let resource_signer = {
            let core_info = borrow_global<CoreInfo>(@vault);
            account::create_signer_with_capability(&core_info.resource_signer_cap)
        };
        let resource_addr = signer::address_of(&resource_signer);
        
        // Get current Coin balance before conversion
        let coin_balance = get_coin_balance<AssetType>(resource_addr);
        
        if (coin_balance > 0) {
            convert_all_coin_to_fa<AssetType>(&resource_signer);
        };
        
        coin_balance
    }

    /// Convert all Coin assets in buffer resource account to FA
    /// Called by vault_core as part of admin migration
    public(friend) fun convert_buffer_assets_to_fa<AssetType>(): u64 acquires BufferCapability {
        // Check if buffer is initialized
        if (!exists<BufferInfo>(@vault) || !exists<BufferCapability>(@vault)) {
            return 0
        };
        
        // Check FA is available
        if (!has_fa_support<AssetType>()) {
            return 0
        };
        
        let buffer_signer = get_buffer_signer();
        let buffer_addr = signer::address_of(&buffer_signer);
        
        // Get current Coin balance before conversion
        let coin_balance = get_coin_balance<AssetType>(buffer_addr);
        
        if (coin_balance > 0) {
            convert_all_coin_to_fa<AssetType>(&buffer_signer);
        };
        
        coin_balance
    }
}