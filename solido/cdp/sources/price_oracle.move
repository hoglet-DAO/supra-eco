// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for price_oracle
module SOLIDO::price_oracle {
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

    struct CollateralPriceOracle has key {
        oracles: aptos_std::table::Table<aptos_std::type_info::TypeInfo, OracleInfo>,
    }

    struct OracleInfo has store {
        price: 0x1::fixed_point32::FixedPoint32,
        oracle_id: u32,
        price_age: u64,
    }

    #[view]
    public fun get_oracle_id<T0>(): u32 {
        abort 0
    }

    public(friend) fun get_oracle_params<T0>(): (u32, u64) {
        abort 0
    }

    public fun get_price<T0>(): 0x1::fixed_point32::FixedPoint32 {
        abort 0
    }

    #[view]
    public fun get_price_raw<T0>(): u64 {
        abort 0
    }

    public(friend) fun initialize(arg0: &signer) {
        abort 0
    }

    public(friend) fun set_oracle<T0>(arg0: u32, arg1: u64) {
        abort 0
    }

    public(friend) fun set_price<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun update_oracle<T0>(arg0: u32, arg1: u64) {
        abort 0
    }

}