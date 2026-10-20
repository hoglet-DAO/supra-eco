module dao_router::dao_bribe {
    public entry fun deposit_bribe_coin<CoinType>(
        _depositor: &signer,
        _dao_address: address,
        _pilgrim: u64,
        _gauge_id: u64,
        _amount: u64
    ) {
        abort 0
    }
}
