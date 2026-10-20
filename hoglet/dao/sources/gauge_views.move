module dao_views::gauge_views {
    use std::vector;

    #[view]
    public fun find_gauge_by_staking_token(_dao_address: address, _staking_token_addr: address): u64 {
        abort 0
    }

    #[view]
    public fun get_user_gauge_info(_gauge_addr: address, _account: address): (
        u128,
        u64,
        u128,
        u128,
        u128,
        u64,
        u64
    ) {
        abort 0
    }

    #[view]
    public fun get_batch_user_gauge_balances(_gauge_addrs: vector<address>, _account: address): (
        vector<u128>,
        vector<u64>
    ) {
        abort 0
    }
}
