module dao_router::dao_zap {
    use std::vector;
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::Metadata;

    public entry fun buy_and_lock_coin<CoinType>(
        _user: &signer,
        _gov_token: Object<Metadata>,
        _amount: u64,
        _amount_out_min: u64,
        _path: vector<address>,
        _deadline: u64,
        _lock_epochs: u64
    ) {
        abort 0
    }

    public entry fun buy_and_lock_fa(
        _user: &signer,
        _gov_token: Object<Metadata>,
        _amount: u64,
        _amount_out_min: u64,
        _path: vector<address>,
        _deadline: u64,
        _lock_epochs: u64
    ) {
        abort 0
    }
}
