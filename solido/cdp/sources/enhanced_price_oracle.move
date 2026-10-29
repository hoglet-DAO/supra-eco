// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for enhanced_price_oracle
module SOLIDO::enhanced_price_oracle {
    use std::signer;
    use std::vector;
    use std::string::String;
    use std::option::Option;
    use aptos_std::type_info::TypeInfo;
    use aptos_std::table::Table;
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::{Metadata, FungibleAsset};
    use supra_framework::coin::{Coin, MintCapability, BurnCapability, FreezeCapability};
    use supra_framework::account;

    struct EnhancedOracleInfo has drop, store {
        price: 0x1::fixed_point32::FixedPoint32,
        oracle_id: u32,
        price_age: u64,
        pair_type: u8,
        base_oracle_id: u32,
    }

    struct EnhancedPriceOracle has key {
        oracles: aptos_std::table::Table<aptos_std::type_info::TypeInfo, EnhancedOracleInfo>,
    }

    struct FAOracleRegistry has key {
        oracles: aptos_std::table::Table<address, EnhancedOracleInfo>,
    }

    #[view]
    public fun get_oracle_id<T0>(): u32 {
        abort 0
    }

    public(friend) fun get_oracle_info_full<T0>(): (u32, u64, u8, u32) {
        abort 0
    }

    #[view]
    public fun get_oracle_params<T0>(): (u32, u64) {
        abort 0
    }

    public fun get_price<T0>(): 0x1::fixed_point32::FixedPoint32 {
        abort 0
    }

    public fun get_price_fa(arg0: address): 0x1::fixed_point32::FixedPoint32 {
        abort 0
    }

    #[view]
    public fun get_price_raw<T0>(): u64 {
        abort 0
    }

    #[view]
    public fun get_price_raw_fa(arg0: address): u64 {
        abort 0
    }

    public entry fun initialize_enhanced_oracle(arg0: &signer) {
        abort 0
    }

    public entry fun initialize_fa_oracle_registry(arg0: &signer) {
        abort 0
    }

    public fun is_fa_oracle_registry_initialized(): bool {
        abort 0
    }

    public(friend) fun remove_enhanced_oracle<T0>() {
        abort 0
    }

    public(friend) fun set_direct_usd_oracle<T0>(arg0: u32, arg1: u64) {
        abort 0
    }

    public(friend) fun set_direct_usd_oracle_fa(arg0: address, arg1: u32, arg2: u64) {
        abort 0
    }

    public(friend) fun set_price<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun set_price_fa(arg0: address, arg1: u64) {
        abort 0
    }

    public(friend) fun set_primary_rate_oracle<T0>(arg0: u32, arg1: u32, arg2: u64) {
        abort 0
    }

    public(friend) fun set_primary_rate_oracle_fa(arg0: address, arg1: u32, arg2: u32, arg3: u64) {
        abort 0
    }

    public(friend) fun update_oracle<T0>(arg0: u32, arg1: u64) {
        abort 0
    }

    public(friend) fun update_oracle_fa(arg0: address, arg1: u32, arg2: u64) {
        abort 0
    }

}