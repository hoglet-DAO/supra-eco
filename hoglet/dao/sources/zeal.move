module dao_factory::zeal {
    use std::vector;

    #[view]
    public fun is_initialized(_dao_address: address): bool {
        abort 0
    }

    #[view]
    public fun get_vault_address(_dao_address: address): address {
        abort 0
    }

    public entry fun vote(
        _voter: &signer,
        _dao_address: address,
        _legacy_addr: address,
        _gauge_ids: vector<u64>,
        _weights: vector<u64>
    ) {
        abort 0
    }

    public entry fun claim_gauge_emission(
        _caller: &signer,
        _dao_address: address,
        _gauge_id: u64
    ) {
        abort 0
    }

    #[view]
    public fun get_gauge_count(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun get_gauge_destination(_dao_address: address, _gauge_id: u64): address {
        abort 0
    }

    #[view]
    public fun get_gauge_total_votes(
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64
    ): u128 {
        abort 0
    }

    #[view]
    public fun get_user_vote_power(_dao_address: address, _legacy_addr: address): u64 {
        abort 0
    }

    #[view]
    public fun get_all_user_votes(_dao_address: address, _legacy_addr: address): (vector<u64>, vector<u64>) {
        abort 0
    }

    #[view]
    public fun get_epoch_total_votes(_dao_address: address, _pilgrim: u64): u128 {
        abort 0
    }

    #[view]
    public fun is_gauge_emission_claimed(
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64
    ): bool {
        abort 0
    }

    #[view]
    public fun is_gauge_active(_dao_address: address, _gauge_id: u64): bool {
        abort 0
    }
}
