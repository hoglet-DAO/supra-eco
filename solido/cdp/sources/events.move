// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for events
module SOLIDO::events {
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

    struct CollateralConfigUpdatedEvent has drop, store {
        minimum_debt: u64,
        mcr: u64,
        borrow_rate: u64,
        liquidation_threshold: u64,
        liquidation_penalty: u64,
        redemption_fee: u64,
        enabled: bool,
        liquidation_fee_protocol: u64,
        redemption_fee_gratuity: u64,
    }

    struct CollateralDepositEvent has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        amount: u64,
        timestamp: u64,
    }

    struct CollateralDepositEventV2 has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        amount: u64,
        timestamp: u64,
    }

    struct CollateralWithdrawEvent has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        amount: u64,
        timestamp: u64,
    }

    struct CollateralWithdrawEventV2 has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        amount: u64,
        timestamp: u64,
    }

    struct DebtMintedEvent has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        amount: u64,
        fee: u64,
        timestamp: u64,
    }

    struct DebtMintedEventV2 has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        amount: u64,
        fee: u64,
        timestamp: u64,
    }

    struct DebtRepaidEvent has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        amount: u64,
        timestamp: u64,
    }

    struct DebtRepaidEventV2 has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        amount: u64,
        timestamp: u64,
    }

    struct FeeCollectorUpdatedEvent has drop, store {
        new_fee_collector: address,
    }

    struct OperationStatusUpdatedEvent has drop, store {
        open_trove: bool,
        borrow: bool,
        deposit: bool,
        redeem: bool,
    }

    struct OracleUpdatedEvent has drop, store {
        new_oracle_id: u32,
        new_price_age: u64,
    }

    struct PositionMigratedEvent has drop, store {
        user: address,
        coin_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        collateral_amount: u64,
        debt_amount: u64,
        timestamp: u64,
    }

    struct RedemptionEvent has drop, store {
        redeemer: address,
        provider: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        collateral_redeemed: u64,
        debt_redeemed: u64,
        fee_paid: u64,
        timestamp: u64,
    }

    struct RedemptionEventV2 has drop, store {
        redeemer: address,
        provider: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        collateral_redeemed: u64,
        debt_redeemed: u64,
        fee_paid: u64,
        timestamp: u64,
    }

    struct TroveClosedEvent has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        collateral_returned: u64,
        debt_repaid: u64,
        timestamp: u64,
    }

    struct TroveClosedEventV2 has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        collateral_returned: u64,
        debt_repaid: u64,
        timestamp: u64,
    }

    struct TroveLiquidatedEvent has drop, store {
        user: address,
        liquidator: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        collateral_liquidated: u64,
        debt_liquidated: u64,
        liquidator_reward: u64,
        protocol_fee: u64,
        user_refund: u64,
        timestamp: u64,
    }

    struct TroveLiquidatedEventV2 has drop, store {
        user: address,
        liquidator: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        collateral_liquidated: u64,
        debt_liquidated: u64,
        liquidator_reward: u64,
        protocol_fee: u64,
        user_refund: u64,
        timestamp: u64,
    }

    struct TroveOpenedEvent has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        collateral_amount: u64,
        debt_amount: u64,
        timestamp: u64,
    }

    struct TroveOpenedEventV2 has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        collateral_amount: u64,
        debt_amount: u64,
        timestamp: u64,
    }

    struct TroveUpdatedEvent has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        collateral_amount: u64,
        debt_amount: u64,
        timestamp: u64,
        block_number: u64,
        action: u8,
    }

    struct TroveUpdatedEventV2 has drop, store {
        user: address,
        collateral_type: aptos_std::type_info::TypeInfo,
        metadata_addr: address,
        is_paired: bool,
        collateral_amount: u64,
        debt_amount: u64,
        timestamp: u64,
        block_number: u64,
        action: u8,
    }

    public(friend) fun emit_collateral_config_updated_event(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: bool, arg7: u64, arg8: u64) {
        abort 0
    }

    public(friend) fun emit_collateral_deposit_event(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: u64, arg3: u64) {
        abort 0
    }

    public(friend) fun emit_collateral_deposit_event_v2(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: address, arg3: bool, arg4: u64, arg5: u64) {
        abort 0
    }

    public(friend) fun emit_collateral_withdraw_event(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: u64, arg3: u64) {
        abort 0
    }

    public(friend) fun emit_collateral_withdraw_event_v2(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: address, arg3: bool, arg4: u64, arg5: u64) {
        abort 0
    }

    public(friend) fun emit_debt_minted_event(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: u64, arg3: u64, arg4: u64) {
        abort 0
    }

    public(friend) fun emit_debt_minted_event_v2(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: address, arg3: bool, arg4: u64, arg5: u64, arg6: u64) {
        abort 0
    }

    public(friend) fun emit_debt_repaid_event(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: u64, arg3: u64) {
        abort 0
    }

    public(friend) fun emit_debt_repaid_event_v2(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: address, arg3: bool, arg4: u64, arg5: u64) {
        abort 0
    }

    public(friend) fun emit_fee_collector_updated_event(arg0: address) {
        abort 0
    }

    public(friend) fun emit_operation_status_updated_event(arg0: bool, arg1: bool, arg2: bool, arg3: bool) {
        abort 0
    }

    public(friend) fun emit_oracle_updated_event(arg0: u32, arg1: u64) {
        abort 0
    }

    public(friend) fun emit_position_migrated<T0>(arg0: address, arg1: address, arg2: u64, arg3: u64) {
        abort 0
    }

    public(friend) fun emit_redemption_event(arg0: address, arg1: address, arg2: aptos_std::type_info::TypeInfo, arg3: u64, arg4: u64, arg5: u64, arg6: u64) {
        abort 0
    }

    public(friend) fun emit_redemption_event_v2(arg0: address, arg1: address, arg2: aptos_std::type_info::TypeInfo, arg3: address, arg4: bool, arg5: u64, arg6: u64, arg7: u64, arg8: u64) {
        abort 0
    }

    public(friend) fun emit_trove_closed(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: u64, arg3: u64, arg4: u64) {
        abort 0
    }

    public(friend) fun emit_trove_closed_v2(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: address, arg3: bool, arg4: u64, arg5: u64, arg6: u64) {
        abort 0
    }

    public(friend) fun emit_trove_liquidated(arg0: address, arg1: address, arg2: aptos_std::type_info::TypeInfo, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u64, arg8: u64) {
        abort 0
    }

    public(friend) fun emit_trove_liquidated_v2(arg0: address, arg1: address, arg2: aptos_std::type_info::TypeInfo, arg3: address, arg4: bool, arg5: u64, arg6: u64, arg7: u64, arg8: u64, arg9: u64, arg10: u64) {
        abort 0
    }

    public(friend) fun emit_trove_opened(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: u64, arg3: u64, arg4: u64) {
        abort 0
    }

    public(friend) fun emit_trove_opened_v2(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: address, arg3: bool, arg4: u64, arg5: u64, arg6: u64) {
        abort 0
    }

    public(friend) fun emit_trove_updated_event(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u8) {
        abort 0
    }

    public(friend) fun emit_trove_updated_event_v2(arg0: address, arg1: aptos_std::type_info::TypeInfo, arg2: address, arg3: bool, arg4: u64, arg5: u64, arg6: u64, arg7: u64, arg8: u8) {
        abort 0
    }

    public(friend) fun err_admin_revoked(): u64 {
        abort 0
    }

    public(friend) fun err_already_initialized(): u64 {
        abort 0
    }

    public(friend) fun err_below_minimum_debt(): u64 {
        abort 0
    }

    public(friend) fun err_cannot_liquidate(): u64 {
        abort 0
    }

    public(friend) fun err_coin_not_initialized(): u64 {
        abort 0
    }

    public(friend) fun err_collateral_disabled(): u64 {
        abort 0
    }

    public(friend) fun err_collateral_not_registered(): u64 {
        abort 0
    }

    public(friend) fun err_fee_too_small(): u64 {
        abort 0
    }

    public(friend) fun err_insufficient_collateral(): u64 {
        abort 0
    }

    public(friend) fun err_insufficient_collateral_balance(): u64 {
        abort 0
    }

    public(friend) fun err_insufficient_debt_balance(): u64 {
        abort 0
    }

    public(friend) fun err_invalid_array_length(): u64 {
        abort 0
    }

    public(friend) fun err_invalid_debt_amount(): u64 {
        abort 0
    }

    public(friend) fun err_invalid_liquidation(): u64 {
        abort 0
    }

    public(friend) fun err_invalid_price(): u64 {
        abort 0
    }

    public(friend) fun err_liquidation_amount_too_small(): u64 {
        abort 0
    }

    public(friend) fun err_no_position_exists(): u64 {
        abort 0
    }

    public(friend) fun err_not_admin(): u64 {
        abort 0
    }

    public(friend) fun err_not_redemption_provider(): u64 {
        abort 0
    }

    public(friend) fun err_operation_disabled(): u64 {
        abort 0
    }

    public(friend) fun err_oracle_not_found(): u64 {
        abort 0
    }

    public(friend) fun err_position_already_exists(): u64 {
        abort 0
    }

    public(friend) fun err_position_too_small_for_partial_liquidation(): u64 {
        abort 0
    }

    public(friend) fun err_price_stale(): u64 {
        abort 0
    }

    public(friend) fun err_self_liquidation(): u64 {
        abort 0
    }

    public(friend) fun err_slippage_exceeded(): u64 {
        abort 0
    }

    public(friend) fun err_unsupported_collateral(): u64 {
        abort 0
    }

    public(friend) fun trove_action_adjust(): u8 {
        abort 0
    }

    public(friend) fun trove_action_close(): u8 {
        abort 0
    }

    public(friend) fun trove_action_liquidate(): u8 {
        abort 0
    }

    public(friend) fun trove_action_open(): u8 {
        abort 0
    }

    public(friend) fun trove_action_redeem(): u8 {
        abort 0
    }

}