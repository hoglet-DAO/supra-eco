module hoglet_core::hoglet_core {
    use std::string::String;

    #[event]
    struct PumpEvent has drop, store {
        pool_address: address,
        dev: address,
        name: String,
        symbol: String,
        token_address: address,
        quote_address: address,
        uri: String,
        website: String,
        description: String,
        socials: String,
        initial_virtual_token_reserves: u128,
        initial_virtual_quote_reserves: u128,
        raising: u64,
        project_type: String,
        token_decimals: u8,
        quote_decimals: u8,
    }

    #[event]
    struct TradeEvent has drop, store {
        quote_amount: u64,
        is_buy: bool,
        token_address: address,
        token_amount: u64,
        user: address,
        timestamp: u64,
    }

    struct PoolStateView has copy, drop, store {
        token_address: address,
        quote_metadata: address,
        virtual_token_reserves: u128,
        virtual_quote_reserves: u128,
        is_completed: bool,
        is_migrated_to_dex: bool,
        target_threshold: u64,
        dev_address: address,
    }

    public entry fun deploy(
        _caller: &signer,
        _raising: u64,
        _name: String,
        _symbol: String,
        _uri: String,
        _website: String,
        _description: String,
        _socials: String,
        _quote_address: address,
        _unstake_period_seconds: u64
    ) {
        abort 0
    }

    public entry fun buy_tokens(
        _caller: &signer,
        _token_address: address,
        _quote_in_amount_param: u64,
        _min_token_out: u64
    ) {
        abort 0
    }

    public entry fun sell_tokens(
        _caller: &signer,
        _token_address: address,
        _sell_token_amount: u64,
        _min_quote_out: u64
    ) {
        abort 0
    }

    public entry fun execute_migration(
        _caller: &signer,
        _token_address: address
    ) {
        abort 0
    }

    public entry fun swap_quote_for_exact_tokens(
        _caller: &signer,
        _token_address: address,
        _buy_token_amount: u64,
        _max_quote_in: u64
    ) {
        abort 0
    }

    public entry fun deploy_and_buy_for_exact_quote(
        _caller: &signer,
        _raising: u64,
        _name: String,
        _symbol: String,
        _uri: String,
        _website: String,
        _description: String,
        _socials: String,
        _quote_address: address,
        _unstake_period_seconds: u64,
        _quote_in_amount: u64,
        _min_token_out: u64
    ) {
        abort 0
    }

    public entry fun stake(
        _user: &signer,
        _token_address: address,
        _stake_amount: u64
    ) {
        abort 0
    }

    public entry fun unstake(
        _user: &signer,
        _token_address: address,
        _unstake_amount: u64
    ) {
        abort 0
    }

    public entry fun harvest(
        _user: &signer,
        _token_address: address
    ) {
        abort 0
    }

    #[view]
    public fun buy_token_amount(
        _token_address: address,
        _buy_token_amount: u64
    ): u128 {
        abort 0
    }

    #[view]
    public fun get_current_pool_quote_balance(_token_address: address): u64 {
        abort 0
    }

    #[view]
    public fun buy_quote_amount(_token_address: address, _buy_quote_amount: u64): u128 {
        abort 0
    }

    #[view]
    public fun sell_token(_token_address: address, _sell_token_amount: u64): u128 {
        abort 0
    }

    #[view]
    public fun get_current_price(_token_address: address): u128 {
        abort 0
    }

    #[view]
    public fun buy_price_with_fee(_token_address: address, _buy_meme_amount: u64): u128 {
        abort 0
    }

    #[view]
    public fun sell_price_with_fee(_token_address: address, _sell_meme_amount: u64): u128 {
        abort 0
    }

    public entry fun activate_delayed_dao(
        _caller: &signer,
        _token_address: address
    ) {
        abort 0
    }

    #[view]
    public fun is_launcher_project(_token_address: address): bool {
        abort 0
    }

    #[view]
    public fun get_bonding_curve_progress_data(_token_address: address): (u64, u64, bool) {
        abort 0
    }

    #[view]
    public fun calculate_virtual_pools(_raising: u64, _quote_address: address): (u128, u128) {
        abort 0
    }

    #[view]
    public fun get_percentage_bps_reward(_raising: u64, _quote_address: address): u64 {
        abort 0
    }

    #[view]
    public fun get_user_stake_info(_token_address: address, _user_addr: address): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_hodl_pool_stats(_token_address: address): (u64, u128) {
        abort 0
    }

    #[view]
    public fun get_pool_state(_token_address: address): PoolStateView {
        abort 0
    }
}
