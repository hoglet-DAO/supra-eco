module dao_factory::foundry {
    use std::vector;

    public entry fun stake(_user: &signer, _gauge_addr: address, _amount: u64) {
        abort 0
    }

    public entry fun withdraw(_user: &signer, _gauge_addr: address, _amount: u64) {
        abort 0
    }

    public entry fun get_reward(_user: &signer, _gauge_addr: address) {
        abort 0
    }

    public entry fun apply_boost(_user: &signer, _gauge_addr: address, _nft_addrs: vector<address>) {
        abort 0
    }

    public entry fun unboost(_user: &signer, _gauge_addr: address) {
        abort 0
    }

    public entry fun sync_boost(_gauge_addr: address, _user: address) {
        abort 0
    }

    #[view]
    public fun total_supply(_gauge_addr: address): u128 {
        abort 0
    }

    #[view]
    public fun balance_of(_gauge_addr: address, _account: address): u128 {
        abort 0
    }

    #[view]
    public fun earned(_gauge_addr: address, _account: address): u64 {
        abort 0
    }

    #[view]
    public fun reward_rate(_gauge_addr: address): u128 {
        abort 0
    }

    #[view]
    public fun period_finish(_gauge_addr: address): u64 {
        abort 0
    }

    #[view]
    public fun reward_per_token(_gauge_addr: address): u128 {
        abort 0
    }

    #[view]
    public fun working_supply(_gauge_addr: address): u128 {
        abort 0
    }

    #[view]
    public fun working_balance_of(_gauge_addr: address, _account: address): u128 {
        abort 0
    }

    #[view]
    public fun get_user_boost_bps(_gauge_addr: address, _account: address): u64 {
        abort 0
    }

    #[view]
    public fun get_user_boost_nfts(_gauge_addr: address, _account: address): vector<address> {
        abort 0
    }

    #[view]
    public fun staking_token(_gauge_addr: address): address {
        abort 0
    }
}
