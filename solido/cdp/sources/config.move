// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for config
module SOLIDO::config {
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

    struct CollateralConfig has copy, drop, store {
        minimum_debt: u64,
        mcr: u64,
        borrow_rate: u64,
        liquidation_reserve: u64,
        liquidation_threshold: u64,
        liquidation_penalty: u64,
        redemption_fee: u64,
        enabled: bool,
        decimals: u8,
        liquidation_fee_protocol: u64,
        redemption_fee_gratuity: u64,
    }

    struct CollateralRegistry has key {
        configs: aptos_std::table::Table<aptos_std::type_info::TypeInfo, CollateralConfig>,
        operation_status: aptos_std::table::Table<aptos_std::type_info::TypeInfo, TroveOperationStatus>,
        fee_collector: address,
    }

    struct FACollateralConfig has copy, drop, store {
        minimum_debt: u64,
        mcr: u64,
        borrow_rate: u64,
        liquidation_reserve: u64,
        liquidation_threshold: u64,
        liquidation_penalty: u64,
        redemption_fee: u64,
        enabled: bool,
        decimals: u8,
        liquidation_fee_protocol: u64,
        redemption_fee_gratuity: u64,
        fa_metadata_addr: address,
        coin_type_info: std::option::Option<aptos_std::type_info::TypeInfo>,
        is_paired: bool,
    }

    struct FACollateralRegistry has key {
        configs: aptos_std::table::Table<address, FACollateralConfig>,
        operation_status: aptos_std::table::Table<address, FAOperationStatus>,
    }

    struct FAOperationStatus has copy, drop, store {
        open_trove: bool,
        borrow: bool,
        deposit: bool,
        redeem: bool,
    }

    struct TroveOperationStatus has copy, drop, store {
        open_trove: bool,
        borrow: bool,
        deposit: bool,
        redeem: bool,
    }

    public(friend) fun add_collateral<T0>(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u8, arg8: u64, arg9: u64, arg10: u32, arg11: u64) {
        abort 0
    }

    public(friend) fun add_fa_collateral(arg0: address, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u64, arg8: u8, arg9: u64, arg10: u64, arg11: std::option::Option<aptos_std::type_info::TypeInfo>) {
        abort 0
    }

    public(friend) fun get_borrow_rate<T0>(): u64 {
        abort 0
    }

    public(friend) fun get_coin_type_info_opt(arg0: address): std::option::Option<aptos_std::type_info::TypeInfo> {
        abort 0
    }

    public(friend) fun get_collateral_decimals<T0>(): u8 {
        abort 0
    }

    #[view]
    public fun get_config<T0>(): (u64, u64, u64, u64, u64, u64, u64, bool, u64, u64) {
        abort 0
    }

    public(friend) fun get_decimals<T0>(): u8 {
        abort 0
    }

    public(friend) fun get_enabled<T0>(): bool {
        abort 0
    }

    public(friend) fun get_fa_borrow_rate(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_config(arg0: address): FACollateralConfig {
        abort 0
    }

    public(friend) fun get_fa_decimals(arg0: address): u8 {
        abort 0
    }

    public(friend) fun get_fa_liquidation_fee_protocol(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_liquidation_penalty(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_liquidation_reserve(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_liquidation_threshold(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_mcr(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_minimum_debt(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_operation_status(arg0: address): (bool, bool, bool, bool) {
        abort 0
    }

    public(friend) fun get_fa_redemption_fee(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fa_redemption_fee_gratuity(arg0: address): u64 {
        abort 0
    }

    public(friend) fun get_fee_collector(): address {
        abort 0
    }

    public(friend) fun get_liquidation_fee_protocol<T0>(): u64 {
        abort 0
    }

    public(friend) fun get_liquidation_penalty<T0>(): u64 {
        abort 0
    }

    public(friend) fun get_liquidation_reserve<T0>(): u64 {
        abort 0
    }

    public(friend) fun get_liquidation_threshold<T0>(): u64 {
        abort 0
    }

    public(friend) fun get_mcr<T0>(): u64 {
        abort 0
    }

    public(friend) fun get_minimum_debt<T0>(): u64 {
        abort 0
    }

    #[view]
    public fun get_operation_status<T0>(): (bool, bool, bool, bool) {
        abort 0
    }

    public(friend) fun get_redemption_fee<T0>(): u64 {
        abort 0
    }

    public(friend) fun get_redemption_fee_gratuity<T0>(): u64 {
        abort 0
    }

    public fun has_paired_coin(arg0: address): bool {
        abort 0
    }

    public(friend) fun initialize(arg0: &signer, arg1: address) {
        abort 0
    }

    public(friend) fun initialize_fa_registry(arg0: &signer) {
        abort 0
    }

    #[view]
    public fun is_fa_collateral_registered(arg0: address): bool {
        abort 0
    }

    public fun is_fa_collateral_valid(arg0: address): bool {
        abort 0
    }

    public fun is_fa_registry_initialized(): bool {
        abort 0
    }

    #[view]
    public fun is_valid_collateral<T0>(): bool {
        abort 0
    }

    #[view]
    public fun is_valid_fa_collateral(arg0: address): bool {
        abort 0
    }

    public(friend) fun set_config<T0>(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: bool, arg7: u64, arg8: u64) {
        abort 0
    }

    public(friend) fun set_fa_coin_type(arg0: address, arg1: aptos_std::type_info::TypeInfo) {
        abort 0
    }

    public(friend) fun set_fa_config(arg0: address, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: bool, arg8: u64, arg9: u64) {
        abort 0
    }

    public(friend) fun set_fa_operation_status(arg0: address, arg1: bool, arg2: bool, arg3: bool, arg4: bool) {
        abort 0
    }

    public(friend) fun set_fee_collector(arg0: address) {
        abort 0
    }

    public(friend) fun set_operation_status<T0>(arg0: bool, arg1: bool, arg2: bool, arg3: bool) {
        abort 0
    }

}