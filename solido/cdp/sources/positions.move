// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for positions
module SOLIDO::positions {
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

    struct CollateralPosition has copy, drop, store {
        collateral_amount: u64,
        debt_amount: u64,
        last_update_time: u64,
    }

    struct RedemptionProvider has key {
        providers: aptos_std::table::Table<address, aptos_std::table::Table<aptos_std::type_info::TypeInfo, bool>>,
    }

    struct UnifiedCollateralPosition has copy, drop, store {
        collateral_amount: u64,
        debt_amount: u64,
        last_update_time: u64,
        metadata_addr: address,
    }

    struct UnifiedRedemptionProvider has key {
        providers: aptos_std::table::Table<address, aptos_std::table::Table<address, bool>>,
    }

    struct UnifiedUserPositions has key {
        positions: aptos_std::table::Table<address, aptos_std::table::Table<address, UnifiedCollateralPosition>>,
    }

    struct UserPositions has key {
        positions: aptos_std::table::Table<address, aptos_std::table::Table<aptos_std::type_info::TypeInfo, CollateralPosition>>,
    }

    public(friend) fun assert_position_exists<T0>(arg0: address) {
        abort 0
    }

    public(friend) fun assert_position_exists_unified(arg0: address, arg1: address) {
        abort 0
    }

    public(friend) fun create_position<T0>(arg0: address, arg1: u64, arg2: u64, arg3: u64) {
        abort 0
    }

    public(friend) fun create_position_unified(arg0: address, arg1: address, arg2: u64, arg3: u64, arg4: u64) {
        abort 0
    }

    public(friend) fun get_metadata_addr_for_coin<T0>(): address {
        abort 0
    }

    #[view]
    public fun get_position<T0>(arg0: address): (u64, u64, u64, bool) {
        abort 0
    }

    public(friend) fun get_position_data<T0>(arg0: address): (u64, u64) {
        abort 0
    }

    public(friend) fun get_position_data_unified(arg0: address, arg1: address): (u64, u64) {
        abort 0
    }

    public(friend) fun get_position_data_unified_safe(arg0: address, arg1: address): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_position_unified(arg0: address, arg1: address): (u64, u64, u64, bool) {
        abort 0
    }

    public(friend) fun has_legacy_coin_position<T0>(arg0: address): bool {
        abort 0
    }

    public(friend) fun initialize(arg0: &signer) {
        abort 0
    }

    public(friend) fun initialize_unified_positions(arg0: &signer) {
        abort 0
    }

    #[view]
    public fun is_redemption_provider<T0>(arg0: address): bool {
        abort 0
    }

    #[view]
    public fun is_redemption_provider_unified(arg0: address, arg1: address): bool {
        abort 0
    }

    public(friend) fun is_unified_positions_initialized(): bool {
        abort 0
    }

    public(friend) fun migrate_legacy_position_to_unified<T0>(arg0: address, arg1: address) {
        abort 0
    }

    public(friend) fun position_exists_unified(arg0: address, arg1: address): bool {
        abort 0
    }

    public(friend) fun register_redemption_provider<T0>(arg0: address, arg1: bool) {
        abort 0
    }

    public(friend) fun register_redemption_provider_unified(arg0: address, arg1: address, arg2: bool) {
        abort 0
    }

    public(friend) fun remove_position<T0>(arg0: address) {
        abort 0
    }

    public(friend) fun remove_position_unified(arg0: address, arg1: address) {
        abort 0
    }

    public(friend) fun update_position<T0>(arg0: address, arg1: u64, arg2: u64, arg3: u64) {
        abort 0
    }

    public(friend) fun update_position_unified(arg0: address, arg1: address, arg2: u64, arg3: u64, arg4: u64) {
        abort 0
    }

}