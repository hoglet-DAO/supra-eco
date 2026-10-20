module dao_factory::restore {
    use std::vector;

    public entry fun deposit_bribe(
        _depositor: &signer,
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64,
        _token_addr: address,
        _amount: u64
    ) {
        abort 0
    }

    public entry fun claim_bribe(
        _claimant: &signer,
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64,
        _legacy_addr: address,
        _token_addr: address
    ) {
        abort 0
    }

    #[view]
    public fun is_whitelisted(_dao_address: address, _token_addr: address): bool {
        abort 0
    }

    #[view]
    public fun get_whitelisted_tokens(_dao_address: address): vector<address> {
        abort 0
    }

    #[view]
    public fun get_vault_address(_dao_address: address): address {
        abort 0
    }

    #[view]
    public fun get_total_bribes_for(
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64,
        _token_addr: address
    ): u64 {
        abort 0
    }

    #[view]
    public fun has_claimed_bribe(
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64,
        _legacy_addr: address,
        _token_addr: address
    ): bool {
        abort 0
    }

    public entry fun rollover_bribe(
        _caller: &signer,
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64,
        _token_addr: address
    ) {
        abort 0
    }
}
