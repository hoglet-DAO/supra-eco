// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for strategy_core
module SOLIDO::strategy_core {
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

    struct CDPConfig has key {
        slippage: u64,
    }

    struct StrategyCapability has key {
        cap: supra_framework::account::SignerCapability,
    }

    struct StrategyInfo has key {
        vault_resource_addr: address,
        asset_type: aptos_std::type_info::TypeInfo,
    }

    #[view]
    public fun balance_of<T0>(): u64 {
        abort 0
    }

    public(friend) fun execute_liquidate<T0, T1>(arg0: address) {
        abort 0
    }

    public fun execute_liquidation_only<T0, T1>(arg0: address, arg1: address) {
        abort 0
    }

    public(friend) fun execute_liquidation_only_fa(arg0: address, arg1: address, arg2: address) {
        abort 0
    }

    public(friend) fun execute_liquidation_only_internal<T0, T1>(arg0: address, arg1: address) {
        abort 0
    }

    #[view]
    public fun get_slippage(): u64 {
        abort 0
    }

    #[view]
    public fun get_strategy_resource_address(): address {
        abort 0
    }

    public(friend) fun get_strategy_signer(): signer {
        abort 0
    }

    public fun initialize<T0>(arg0: &signer, arg1: address) {
        abort 0
    }

    public entry fun setup(arg0: &signer, arg1: u64) {
        abort 0
    }

    public entry fun update_slippage(arg0: &signer, arg1: u64) {
        abort 0
    }

}