module vault::strategy_delegation {
    use std::signer;
    use std::vector;
    use supra_framework::event;
    use supra_framework::pbo_delegation_pool;
    use supra_framework::timestamp;
    use vault::strategy_validator;
    
    friend vault::strategy_core;

    friend vault::strategy_staking;

    // Delegation configuration - simplified since we don't track pools
    struct DelegationConfig has key {
        initialized: bool
    }

    // Delegation events
    #[event]
    struct DelegationEvent has drop, store {
        validator: address,
        amount: u64,
        delegator: address,
        timestamp: u64,
        active_stake: u64,
        inactive_stake: u64,
        pending_inactive_stake: u64
    }

    #[event]
    struct UndelegationEvent has drop, store {
        validator: address,
        amount: u64,
        delegator: address,
        timestamp: u64,
        remaining_active_stake: u64
    }

    #[event]
    struct WithdrawUnlockedEvent has drop, store {
        validator: address,
        amount: u64,
        delegator: address,
        timestamp: u64,
        total_withdrawn: u64,
        remaining_pending_inactive: u64
    }


    // Initialize delegation module - called by strategy_core
    public(friend) fun initialize<AssetType>(admin: &signer) {
        
        if (!exists<DelegationConfig>(@vault)) {
            move_to(admin, DelegationConfig {
                initialized: true
            });
        };
    }

    // Delegate funds to a validator - no pool check
    public(friend) fun delegate<AssetType>(
        strategy_signer: &signer,
        validator: address,
        amount: u64
    ) {
        let delegator = signer::address_of(strategy_signer);
        
        // Call PBO delegation pool to add stake
        pbo_delegation_pool::add_stake(strategy_signer, validator, amount);
        
        // Get updated stake amounts after delegation
        let (active, inactive, pending_inactive) = pbo_delegation_pool::get_stake(
            validator,
            delegator
        );
        
        // Emit delegation event with enhanced data
        event::emit(DelegationEvent {
            validator,
            amount,
            delegator,
            timestamp: timestamp::now_seconds(),
            active_stake: active,
            inactive_stake: inactive,
            pending_inactive_stake: pending_inactive
        });
    }

    // Undelegate funds from a validator - no pool check
    public(friend) fun undelegate<AssetType>(
        strategy_signer: &signer,
        validator: address,
        amount: u64
    ) {
        let delegator = signer::address_of(strategy_signer);
        
        // Call PBO delegation pool to unlock stake
        pbo_delegation_pool::unlock(strategy_signer, validator, amount);

        // Get remaining active stake after undelegation
        let (remaining_active, _, _) = pbo_delegation_pool::get_stake(
            validator,
            delegator
        );
        // Emit undelegation event with enhanced data
        event::emit(UndelegationEvent {
            validator,
            amount,
            delegator,
            timestamp: timestamp::now_seconds(),
            remaining_active_stake: remaining_active
        });
    }

    // Withdraw unlocked funds from all validators and return the total amount withdrawn
    public(friend) fun withdraw_unlocked<AssetType>(
        strategy_signer: &signer
    ): u64 {
        // Get validators from the validator module
        let validators = strategy_validator::get_all_validators();
        let total_withdrawn = 0;
        let delegator = signer::address_of(strategy_signer);
        
        // Iterate through all validators and withdraw unlocked funds
        let i = 0;
        let len = vector::length(&validators);
        while (i < len) {
            let validator = *vector::borrow(&validators, i);
            
            // Check if there are any withdrawable funds
            let (can_withdraw, withdraw_amount) = pbo_delegation_pool::get_pending_withdrawal(
                validator, 
                delegator
            );
            
            // Only withdraw if there are unlocked funds available
            if (can_withdraw && withdraw_amount > 0) {
                // Use withdraw function
                pbo_delegation_pool::withdraw(
                    strategy_signer,
                    validator,
                    withdraw_amount
                );
                
                total_withdrawn = total_withdrawn + withdraw_amount;
                
                // Get remaining pending inactive stake after withdrawal
                let (_, _, remaining_pending_inactive) = pbo_delegation_pool::get_stake(
                    validator,
                    delegator
                );
                
                // Emit withdraw unlocked event with enhanced data
                event::emit(WithdrawUnlockedEvent {
                    validator,
                    amount: withdraw_amount,
                    delegator,
                    timestamp: timestamp::now_seconds(),
                    total_withdrawn,
                    remaining_pending_inactive
                });
            };
            
            i = i + 1;
        };
        
        total_withdrawn
    }
    
    // Get total staked amount across all validators
    #[view]
    public fun get_total_staked<AssetType>(delegator_address: address): u64 {
        let validators = strategy_validator::get_all_validators();
        let total_staked = 0;
        
        let i = 0;
        let len = vector::length(&validators);
        while (i < len) {
            let validator = *vector::borrow(&validators, i);
            
            let (active, inactive, pending_inactive) = pbo_delegation_pool::get_stake(
                validator,
                delegator_address
            );
            
            total_staked = total_staked + active + inactive + pending_inactive;
            i = i + 1;
        };
        
        total_staked
    }


    #[view]
    public fun get_validator_staked<AssetType>(validator: address, delegator_address: address): (u64, u64, u64) {
        pbo_delegation_pool::get_stake(
            validator,
            delegator_address
        )
    }
    
    #[view]
    public fun get_withdrawable_amounts<AssetType>(strategy_addr: address): (vector<address>, vector<u64>) {
        // Get validators from the validator module
        let validators = strategy_validator::get_all_validators();
        let withdrawable_amounts = vector::empty<u64>();
        
        // Iterate through all validators and check withdrawable funds
        let i = 0;
        let len = vector::length(&validators);
        while (i < len) {
            let validator = *vector::borrow(&validators, i);
            
            // Check if there are any withdrawable funds
            let (can_withdraw, withdraw_amount) = pbo_delegation_pool::get_pending_withdrawal(
                validator, 
                strategy_addr
            );
            
            // Add the withdrawable amount (will be 0 if not withdrawable)
            if (can_withdraw) {
                vector::push_back(&mut withdrawable_amounts, withdraw_amount);
            } else {
                vector::push_back(&mut withdrawable_amounts, 0);
            };
            
            i = i + 1;
        };
        
        (validators, withdrawable_amounts)
    }
    

    // Get only active staked amount (available for protocol operations)
    #[view]
    public fun get_active_staked<AssetType>(delegator_address: address): u64 {
        let validators = strategy_validator::get_all_validators();
        let total_active = 0;
        
        let i = 0;
        let len = vector::length(&validators);
        while (i < len) {
            let validator = *vector::borrow(&validators, i);
            
            let (active, inactive, pending_inactive) = pbo_delegation_pool::get_stake(
                validator,
                delegator_address
            );
            
            // Only include active
            total_active = total_active + active;
            i = i + 1;
        };
        
        total_active
    }
    
}