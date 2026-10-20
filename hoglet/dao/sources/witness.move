module dao_factory::witness {
    public entry fun cast_vote(
        _voter: &signer,
        _dao_address: address,
        _legacy_addr: address,
        _proposal_id: u64,
        _support: u8
    ) {
        abort 0
    }

    #[view]
    public fun has_voted(
        _dao_address: address,
        _proposal_id: u64,
        _legacy_addr: address
    ): bool {
        abort 0
    }
}
