module vault::strategy_staking {
    use std::error;
    use std::signer;
    use std::string::String;
    use std::vector;
    use supra_framework::coin;
    use supra_framework::event;
    use supra_framework::timestamp;
    use vault::strategy_delegation;
    use vault::strategy_validator;
    use vault::strategy_core;

    friend vault::strategy_core;

    // Error codes
    const ERR_INVALID_VALIDATOR: u64 = 1;
    const ERR_ZERO_AMOUNT: u64 = 2;
    const ERR_INSUFFICIENT_FUNDS: u64 = 3;

    // Simplified staking configuration - removed validator_stakes table
    struct StakingConfig has key {
        initialized: bool
    }

    // Events
    #[event]
    struct AssetsStakedEvent has drop, store {
        validator: address,
        amount: u64,
        timestamp: u64
    }

    #[event]
    struct AssetsUnstakedEvent has drop, store {
        validator: address,
        amount: u64,
        timestamp: u64
    }

    // ============ FA Helper Functions ============

    /// Get total balance for an address
    /// NOTE: In Supra, coin::balance() already returns Coin + FA when pairing is enabled
    fun get_total_balance<AssetType>(addr: address): u64 {
        if (coin::is_account_registered<AssetType>(addr)) {
            coin::balance<AssetType>(addr)
        } else { 0 }
    }

    // Initialize staking module
    public(friend) fun initialize<AssetType>(
        admin: &signer
    ) {

        if (!exists<StakingConfig>(@vault)) {
            move_to(admin, StakingConfig {
                initialized: true
            });
        };
    }

    // Stake assets to a specific validator
    // Note: pbo_delegation_pool::add_stake handles FA automatically
    public(friend) fun stake_asset<AssetType>(
        strategy_signer: &signer,
        validator: address,
        amount: u64
    ) {
        // Verify validator exists in the registry
        assert!(strategy_validator::is_validator_active(validator), error::invalid_argument(ERR_INVALID_VALIDATOR));
        
        // FA Support: Check total balance (Coin + FA), pbo handles the conversion
        let strategy_addr = signer::address_of(strategy_signer);
        assert!(get_total_balance<AssetType>(strategy_addr) >= amount, error::invalid_state(ERR_INSUFFICIENT_FUNDS));
        
        // Delegate assets to validator
        strategy_delegation::delegate<AssetType>(strategy_signer, validator, amount);
        
        // Emit staking event
        event::emit(AssetsStakedEvent {
            validator,
            amount,
            timestamp: timestamp::now_seconds()
        });
    }

    // Unstake assets from a specific validator
    public(friend) fun unstake_asset<AssetType>(
        strategy_signer: &signer,
        validator: address,
        amount: u64
    ) {
        // Verify we have a positive amount to unstake
        assert!(amount > 0, error::invalid_argument(ERR_ZERO_AMOUNT));
        
        // Get current active stake for this validator
        let strategy_addr = signer::address_of(strategy_signer);
        let (active, _, _) = strategy_delegation::get_validator_staked<AssetType>(validator, strategy_addr);
        
        // Make sure we don't unstake more than available active stake
        if (amount > active) {
            amount = active;
        };
        
        if (amount > 0) {
            // Undelegate assets from validator
            strategy_delegation::undelegate<AssetType>(strategy_signer, validator, amount);
            
            // Emit unstaking event
            event::emit(AssetsUnstakedEvent {
                validator,
                amount,
                timestamp: timestamp::now_seconds()
            });
        };
    }
}