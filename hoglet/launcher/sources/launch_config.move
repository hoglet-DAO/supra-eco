module hoglet_core::launch_config {
    use std::vector;

    struct QuoteConfig has copy, drop, store {
        price_ratio_whole: u64,
        min_trade_amount: u64,
        raising_min: u64,
        raising_max: u64,
        enabled: bool,
    }

    #[view]
    public fun get_resource_address(): address {
        abort 0
    }

    #[view]
    public fun get_admin(): address {
        abort 0
    }

    public entry fun transfer_admin(_admin: &signer, _new_admin: address) {
        abort 0
    }

    public fun is_meme_project(_raising: u64): bool {
        abort 0
    }

    public entry fun update_config(
        _admin: &signer,
        _new_creator_fee_bps: u64,
        _new_platform_fee: u64,
        _new_deploy_fee: u64,
        _new_platform_fee_address: address,
        _new_benefitiary_address_for_excess: address,
        _new_raise_limit_min: u64,
        _new_raise_limit_max: u64,
        _new_virtual_mult_range_meme: u64,
        _new_virtual_mult_range_DAO: u64,
        _new_virtual_mult_range_BIG_DAO: u64,
        _new_tokens_per_sup: u64,
        _new_raising_percentage_meme: u64,
        _new_raising_percentage_DAO: u64,
        _new_raising_percentage_BIG_DAO: u64,
        _new_staking_rate: u64,
        _new_unstake_period_seconds_min: u64,
        _new_unstake_period_seconds_max: u64,
        _new_unstake_period_seconds_default: u64,
        _new_min_trade_supra_amount: u64,
        _new_migrator_reward_bps: u64,
        _new_migration_slippage_bps: u64,
        _new_staking_reward_meme_bps: u64
    ) {
        abort 0
    }

    public fun get_platform_fees(): (u64, u64, u64, address) {
        abort 0
    }

    public fun get_raise_limits_config(): (u64, u64) {
        abort 0
    }

    public fun get_virtual_mult_ranges(): (u64, u64, u64) {
        abort 0
    }

    public fun get_raising_percentages(): (u64, u64, u64) {
        abort 0
    }

    public fun get_token_decimals(): u8 {
        abort 0
    }

    public fun get_unstake_period_default(): u64 {
        abort 0
    }

    public fun get_unstake_period_range(): (u64, u64) {
        abort 0
    }

    public fun get_tokens_per_sup(): u64 {
        abort 0
    }

    public fun get_benefitiary_address_for_excess(): address {
        abort 0
    }

    public fun get_migrator_reward_bps(): u64 {
        abort 0
    }

    public fun get_migration_slippage_bps(): u64 {
        abort 0
    }

    public fun get_staking_reward_meme_bps(): u64 {
        abort 0
    }

    public fun get_min_trade_supra_amount(): u64 {
        abort 0
    }

    public entry fun set_buffer_target(_admin: &signer, _iasset_address: address, _is_enabled: bool) {
        abort 0
    }

    public fun is_buffer_enabled(): bool {
        abort 0
    }

    public fun get_buffer_iasset_address(): address {
        abort 0
    }

    public fun is_supra_native_fa(_quote: address): bool {
        abort 0
    }

    public fun is_quote_tax_aware_capable(_quote: address): bool {
        abort 0
    }

    public fun validate_quote_is_pure_canonical_fa(_admin: &signer, _quote: address) {
        abort 0
    }

    public entry fun add_quote(
        _admin: &signer,
        _quote: address,
        _price_ratio_whole: u64,
        _min_trade_amount: u64,
        _raising_min: u64,
        _raising_max: u64
    ) {
        abort 0
    }

    public entry fun update_quote_params(
        _admin: &signer,
        _quote: address,
        _price_ratio_whole: u64,
        _min_trade_amount: u64,
        _raising_min: u64,
        _raising_max: u64
    ) {
        abort 0
    }

    public entry fun set_quote_enabled(_admin: &signer, _quote: address, _enabled: bool) {
        abort 0
    }

    public entry fun add_quote_with_oracle(_admin: &signer, _quote: address) {
        abort 0
    }

    public fun get_quote_decimals(_quote: address): u8 {
        abort 0
    }

    public entry fun refresh_quote_with_oracle(_admin: &signer, _quote: address) {
        abort 0
    }

    public entry fun remove_quote(_admin: &signer, _quote: address) {
        abort 0
    }

    public fun get_quote_config(_quote: address): (bool, bool, u64, u64, u64, u64) {
        abort 0
    }

    public fun is_quote_enabled(_quote: address): bool {
        abort 0
    }

    public fun get_quote_price_ratio(_quote: address): u64 {
        abort 0
    }

    public fun get_quote_min_trade_amount(_quote: address): u64 {
        abort 0
    }

    public fun require_quote_config(_quote: address): QuoteConfig {
        abort 0
    }

    public fun get_all_quotes(): vector<address> {
        abort 0
    }

    public fun get_quote_raise_thresholds(_quote: address): (u64, u64, u64, u64) {
        abort 0
    }
}
