// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for cdp_multi
module SOLIDO::cdp_multi {
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

    struct CASH has store {
        value: u64,
    }

    struct LRCollectorCapability has key {
        cap: supra_framework::account::SignerCapability,
    }

    struct PureFA has key {
        dummy_field: bool,
    }

    struct SignerCapability has key {
        cap: supra_framework::account::SignerCapability,
    }

    struct TroveManager has key {
        debtToken_mint_cap: supra_framework::coin::MintCapability<CASH>,
        debtToken_burn_cap: supra_framework::coin::BurnCapability<CASH>,
        debtToken_freeze_cap: supra_framework::coin::FreezeCapability<CASH>,
        total_collateral: aptos_std::table::Table<aptos_std::type_info::TypeInfo, u64>,
        total_debt: aptos_std::table::Table<aptos_std::type_info::TypeInfo, u64>,
    }

    struct UnifiedVaultStats has key {
        total_collateral: aptos_std::table::Table<address, u64>,
        total_debt: aptos_std::table::Table<address, u64>,
    }

    public entry fun add_collateral<T0>(arg0: &signer, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u64, arg8: u8, arg9: u64, arg10: u64, arg11: u32, arg12: u64) {
        abort 0
    }

    public entry fun add_fa_collateral(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u64, arg8: u64, arg9: u8, arg10: u64, arg11: u64, arg12: u32, arg13: u64, arg14: bool, arg15: u32) {
        abort 0
    }

    public entry fun admin_burn_from(arg0: &signer, arg1: address, arg2: u64) {
        abort 0
    }

    public entry fun admin_burn_from_fa_store(arg0: &signer, arg1: address, arg2: u64) {
        abort 0
    }

    public entry fun admin_force_close_trove_fa(arg0: &signer, arg1: address, arg2: address) {
        abort 0
    }

    public entry fun admin_reinstate_debt_fa(arg0: &signer, arg1: address, arg2: address, arg3: u64) {
        abort 0
    }

    public entry fun admin_set_coin_frozen(arg0: &signer, arg1: address, arg2: bool) {
        abort 0
    }

    public entry fun admin_set_coin_frozen_batch(arg0: &signer, arg1: vector<address>, arg2: bool) {
        abort 0
    }

    public entry fun admin_set_debt_fa(arg0: &signer, arg1: address, arg2: address, arg3: u64) {
        abort 0
    }

    public entry fun admin_set_frozen(arg0: &signer, arg1: address, arg2: bool) {
        abort 0
    }

    public entry fun admin_set_frozen_batch(arg0: &signer, arg1: vector<address>, arg2: bool) {
        abort 0
    }

    #[view]
    public fun check_migration_needed<T0>(arg0: address): bool {
        abort 0
    }

    public entry fun close_trove<T0>(arg0: &signer) {
        abort 0
    }

    public entry fun close_trove_fa(arg0: &signer, arg1: address) {
        abort 0
    }

    public entry fun close_trove_fa_with_coin<T0>(arg0: &signer) {
        abort 0
    }

    public entry fun close_trove_pure_fa(arg0: &signer, arg1: address) {
        abort 0
    }

    public entry fun collect_poel_rewards(arg0: &signer, arg1: vector<address>, arg2: address, arg3: address) {
        abort 0
    }

    public entry fun convert_cash_coin_to_fa(arg0: &signer, arg1: u64) {
        abort 0
    }

    public entry fun convert_vault_coin_to_fa<T0>(arg0: &signer) {
        abort 0
    }

    public entry fun deposit_or_mint<T0>(arg0: &signer, arg1: u64, arg2: u64) {
        abort 0
    }

    public entry fun deposit_or_mint_fa(arg0: &signer, arg1: address, arg2: u64, arg3: u64) {
        abort 0
    }

    public entry fun deposit_or_mint_fa_with_coin<T0>(arg0: &signer, arg1: u64, arg2: u64) {
        abort 0
    }

    #[view]
    public fun get_cash_fa_balance(arg0: address): u64 {
        abort 0
    }

    #[view]
    public fun get_coin_type_info_for_fa(arg0: address): aptos_std::type_info::TypeInfo {
        abort 0
    }

    #[view]
    public fun get_collateral_config<T0>(): (u64, u64, u64, u64, u64, u64, u64, bool, u64, u64) {
        abort 0
    }

    public fun get_collateral_price<T0>(): 0x1::fixed_point32::FixedPoint32 {
        abort 0
    }

    #[view]
    public fun get_collateral_price_raw<T0>(): u64 {
        abort 0
    }

    #[view]
    public fun get_fa_collateral_config(arg0: address): (u64, u64, u64, u64, u64, u64, u64, bool, u64, u64) {
        abort 0
    }

    #[view]
    public fun get_fa_collateral_price(arg0: address): 0x1::fixed_point32::FixedPoint32 {
        abort 0
    }

    #[view]
    public fun get_fa_collateral_price_raw(arg0: address): u64 {
        abort 0
    }

    #[view]
    public fun get_fa_operation_status(arg0: address): (bool, bool, bool, bool) {
        abort 0
    }

    #[view]
    public fun get_fee_collector(): address {
        abort 0
    }

    #[view]
    public fun get_lr_collector(): address {
        abort 0
    }

    #[view]
    public fun get_metadata_addr_for_coin<T0>(): address {
        abort 0
    }

    #[view]
    public fun get_operation_status<T0>(): (bool, bool, bool, bool) {
        abort 0
    }

    #[view]
    public fun get_poel_reward_info(arg0: vector<address>): (vector<address>, vector<u64>, u64, u64, u64, u64, u64) {
        abort 0
    }

    #[view]
    public fun get_poel_reward_info_for_account(arg0: address, arg1: vector<address>): (vector<address>, vector<u64>, u64, u64, u64, u64, u64) {
        abort 0
    }

    #[view]
    public fun get_position_by_coin<T0>(arg0: address): (u64, u64, bool) {
        abort 0
    }

    #[view]
    public fun get_position_unified(arg0: address, arg1: address): (u64, u64, bool) {
        abort 0
    }

    #[view]
    public fun get_total_stats<T0>(): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_total_stats_by_metadata(arg0: address): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_total_stats_combined<T0>(): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_unified_vault_stats(arg0: address): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_user_position<T0>(arg0: address): (u64, u64, bool) {
        abort 0
    }

    #[view]
    public fun has_any_position(arg0: address): bool {
        abort 0
    }

    public entry fun initialize(arg0: &signer, arg1: address) {
        abort 0
    }

    public entry fun initialize_cash_fa(arg0: &signer) {
        abort 0
    }

    #[view]
    public fun is_cash_fa_initialized(): bool {
        abort 0
    }

    public fun is_fa_collateral_registered(arg0: address): bool {
        abort 0
    }

    public fun is_initialized(): bool {
        abort 0
    }

    #[view]
    public fun is_position_unified<T0>(arg0: address): bool {
        abort 0
    }

    #[view]
    public fun is_redemption_provider<T0>(arg0: address): bool {
        abort 0
    }

    #[view]
    public fun is_redemption_provider_fa(arg0: address, arg1: address): bool {
        abort 0
    }

    #[view]
    public fun is_valid_collateral<T0>(): bool {
        abort 0
    }

    public entry fun link_coin_to_fa_metadata<T0>(arg0: &signer) {
        abort 0
    }

    public entry fun liquidate<T0>(arg0: &signer, arg1: address) {
        abort 0
    }

    public entry fun liquidate_fa(arg0: &signer, arg1: address, arg2: address) {
        abort 0
    }

    public entry fun liquidate_fa_with_coin(arg0: &signer, arg1: address, arg2: address) {
        abort 0
    }

    public entry fun migrate_position<T0>(arg0: &signer) {
        abort 0
    }

    public entry fun migrate_position_admin<T0>(arg0: &signer, arg1: address) {
        abort 0
    }

    public entry fun open_trove<T0>(arg0: &signer, arg1: u64, arg2: u64) {
        abort 0
    }

    public entry fun open_trove_fa(arg0: &signer, arg1: address, arg2: u64, arg3: u64) {
        abort 0
    }

    public entry fun open_trove_fa_with_coin<T0>(arg0: &signer, arg1: u64, arg2: u64) {
        abort 0
    }

    public entry fun partial_liquidate<T0>(arg0: &signer, arg1: address, arg2: u64) {
        abort 0
    }

    public entry fun partial_liquidate_fa(arg0: &signer, arg1: address, arg2: address, arg3: u64) {
        abort 0
    }

    public entry fun partial_liquidate_fa_with_coin(arg0: &signer, arg1: address, arg2: address, arg3: u64) {
        abort 0
    }

    public entry fun redeem<T0>(arg0: &signer, arg1: address, arg2: u64, arg3: u64) {
        abort 0
    }

    public entry fun redeem_fa(arg0: &signer, arg1: address, arg2: address, arg3: u64, arg4: u64) {
        abort 0
    }

    public entry fun redeem_fa_with_coin(arg0: &signer, arg1: address, arg2: address, arg3: u64, arg4: u64) {
        abort 0
    }

    public entry fun redeem_multiple<T0>(arg0: &signer, arg1: vector<address>, arg2: vector<u64>, arg3: vector<u64>) {
        abort 0
    }

    public entry fun register_as_redemption_provider<T0>(arg0: &signer, arg1: bool) {
        abort 0
    }

    public entry fun register_collateral_coin<T0>(arg0: &signer) {
        abort 0
    }

    public entry fun register_debtToken_coin(arg0: &signer) {
        abort 0
    }

    public entry fun remove_enhanced_oracle<T0>(arg0: &signer) {
        abort 0
    }

    public entry fun repay_or_withdraw<T0>(arg0: &signer, arg1: u64, arg2: u64) {
        abort 0
    }

    public entry fun repay_or_withdraw_fa(arg0: &signer, arg1: address, arg2: u64, arg3: u64) {
        abort 0
    }

    public entry fun repay_or_withdraw_fa_with_coin<T0>(arg0: &signer, arg1: u64, arg2: u64) {
        abort 0
    }

    public entry fun set_config<T0>(arg0: &signer, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: bool, arg8: u64, arg9: u64) {
        abort 0
    }

    public entry fun set_fa_config(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u64, arg8: bool, arg9: u64, arg10: u64) {
        abort 0
    }

    public entry fun set_fa_operation_status(arg0: &signer, arg1: address, arg2: bool, arg3: bool, arg4: bool, arg5: bool) {
        abort 0
    }

    public entry fun set_fee_collector(arg0: &signer, arg1: address) {
        abort 0
    }

    public entry fun set_operation_status<T0>(arg0: &signer, arg1: bool, arg2: bool, arg3: bool, arg4: bool) {
        abort 0
    }

    public entry fun set_oracle<T0>(arg0: &signer, arg1: u32, arg2: u64) {
        abort 0
    }

    public entry fun set_primary_rate_oracle<T0>(arg0: &signer, arg1: u32, arg2: u32, arg3: u64) {
        abort 0
    }

    public entry fun set_primary_rate_oracle_fa(arg0: &signer, arg1: address, arg2: u32, arg3: u32, arg4: u64) {
        abort 0
    }

    public entry fun update_oracle_fa(arg0: &signer, arg1: address, arg2: u32, arg3: u64) {
        abort 0
    }

    public fun verify_collateral_ratio<T0>(arg0: u64, arg1: u64) {
        abort 0
    }

}