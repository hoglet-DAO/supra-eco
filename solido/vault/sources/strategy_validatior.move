module vault::strategy_validator {
    use std::error;
    use std::signer;
    use std::vector;
    use supra_framework::event;
    use supra_framework::table::{Self, Table};

    friend vault::strategy_core;

    // Error codes
    const ERR_VALIDATOR_NOT_FOUND: u64 = 1;

    // Validator information
    struct ValidatorInfo has store, drop {
        is_active: bool
    }

    // Validator registry
    struct ValidatorRegistry has key {
        initialized: bool,
        validators: vector<address>,
        validator_info: Table<address, ValidatorInfo>
    }

    // Events
    #[event]
    struct ValidatorAddedEvent has drop, store {
        validator: address
    }

    #[event]
    struct ValidatorRemovedEvent has drop, store {
        validator: address
    }

    // Initialize validator registry
    public(friend) fun initialize<AssetType>(
        admin: &signer
    ) {
        if (!exists<ValidatorRegistry>(@vault)) {
            move_to(admin, ValidatorRegistry {
                initialized: true,
                validators: vector::empty<address>(),
                validator_info: table::new<address, ValidatorInfo>()
            });
        };
    }

    // Add validator to registry
    public(friend) fun add_validator(
        admin: &signer,
        validator: address
    ) acquires ValidatorRegistry {

        let registry = borrow_global_mut<ValidatorRegistry>(@vault);
        
        // Check if validator already exists
        if (table::contains(&registry.validator_info, validator)) {
            // If it exists but is not active, just reactivate it
            let validator_info = table::borrow_mut(&mut registry.validator_info, validator);
            if (!validator_info.is_active) {
                validator_info.is_active = true;
                // No need to add to validators vector again
            }
        } else {
            // Add new validator to registry
            table::add(&mut registry.validator_info, validator, ValidatorInfo { is_active: true });
            vector::push_back(&mut registry.validators, validator);
        };

        // Emit event
        event::emit(ValidatorAddedEvent { validator });
    }

    // Remove validator from registry completely
    public(friend) fun remove_validator(
        admin: &signer,
        validator: address
    ) acquires ValidatorRegistry {

        let registry = borrow_global_mut<ValidatorRegistry>(@vault);
        
        // Check if validator exists
        assert!(table::contains(&registry.validator_info, validator), ERR_VALIDATOR_NOT_FOUND);
        
        // Remove validator from validator_info table
        table::remove(&mut registry.validator_info, validator);
        
        // Remove validator from validators vector
        let i = 0;
        let len = vector::length(&registry.validators);
        while (i < len) {
            let current_validator = *vector::borrow(&registry.validators, i);
            if (current_validator == validator) {
                vector::remove(&mut registry.validators, i);
                break
            };
            i = i + 1;
        };

        // Emit event
        event::emit(ValidatorRemovedEvent { validator });
    }

    // Check if validator is active
    public fun is_validator_active(validator: address): bool acquires ValidatorRegistry {
        let registry = borrow_global<ValidatorRegistry>(@vault);
        
        if (!table::contains(&registry.validator_info, validator)) {
            return false
        };
        
        let validator_info = table::borrow(&registry.validator_info, validator);
        validator_info.is_active
    }

    // Get all validators, including inactive ones
    #[view]
    public fun get_all_validators(): vector<address> acquires ValidatorRegistry {
        let registry = borrow_global<ValidatorRegistry>(@vault);
        registry.validators
    }

    #[view]
    // Get only active validators
    public fun get_active_validators(): vector<address> acquires ValidatorRegistry {
        let registry = borrow_global<ValidatorRegistry>(@vault);
        let active_validators = vector::empty<address>();
        
        let i = 0;
        let len = vector::length(&registry.validators);
        while (i < len) {
            let validator = *vector::borrow(&registry.validators, i);
            let validator_info = table::borrow(&registry.validator_info, validator);
            
            if (validator_info.is_active) {
                vector::push_back(&mut active_validators, validator);
            };
            
            i = i + 1;
        };
        
        active_validators
    }
} 