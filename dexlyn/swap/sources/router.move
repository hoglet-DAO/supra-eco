module dexlyn_swap::router {
    use std::option::Option;
    use dexlyn_swap_lp::lp_coin::LP;
    use supra_framework::coin::Coin;

    public fun register_pool<X, Y, Curve>(_account: &signer) {
        abort 0
    }

    public fun add_liquidity<X, Y, Curve>(
        _coin_x: Coin<X>,
        _min_coin_x_val: u64,
        _coin_y: Coin<Y>,
        _min_coin_y_val: u64,
    ): (Coin<X>, Coin<Y>, Coin<LP<X, Y, Curve>>) {
        abort 0
    }

    public fun remove_liquidity<X, Y, Curve>(
        _lp_coins: Coin<LP<X, Y, Curve>>,
        _min_x_out_val: u64,
        _min_y_out_val: u64,
    ): (Coin<X>, Coin<Y>) {
        abort 0
    }

    public fun swap_exact_coin_for_coin<X, Y, Curve>(
        _coin_in: Coin<X>,
        _coin_out_min_val: u64,
    ): Coin<Y> {
        abort 0
    }

    public fun swap_coin_for_exact_coin<X, Y, Curve>(
        _coin_max_in: Coin<X>,
        _coin_out_val: u64,
    ): (Coin<X>, Coin<Y>) {
        abort 0
    }

    public fun swap_coin_for_coin_unchecked<X, Y, Curve>(
        _coin_in: Coin<X>,
        _coin_out_val: u64,
    ): Coin<Y> {
        abort 0
    }

    // Getters

    #[view]
    public fun get_decimals_scales<X, Y, Curve>(): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_cumulative_prices<X, Y, Curve>(): (u128, u128, u64) {
        abort 0
    }

    #[view]
    public fun get_pool<X, Y, Curve>(): Option<address> {
        abort 0
    }

    #[view]
    public fun get_reserves_size<X, Y, Curve>(): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_fees_config<X, Y, Curve>(): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_fee<X, Y, Curve>(): u64 {
        abort 0
    }

    #[view]
    public fun get_dao_fees_config<X, Y, Curve>(): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_dao_fee<X, Y, Curve>(): u64 {
        abort 0
    }

    #[view]
    public fun is_swap_exists<X, Y, Curve>(): bool {
        abort 0
    }

    #[view]
    public fun calc_optimal_coin_values<X, Y, Curve>(
        _x_desired: u64,
        _y_desired: u64,
        _x_min: u64,
        _y_min: u64
    ): (u64, u64) {
        abort 0
    }

    public fun convert_with_current_price(
        _coin_in: u64, 
        _reserve_in: u64, 
        _reserve_out: u64
    ): u64 {
        abort 0
    }

    #[view]
    public fun get_reserves_for_lp_coins<X, Y, Curve>(
        _lp_to_burn_val: u64
    ): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_amount_out<X, Y, Curve>(_amount_in: u64): u64 {
        abort 0
    }

    #[view]
    public fun get_amount_in<X, Y, Curve>(_amount_out: u64): u64 {
        abort 0
    }
}
