module dao_router::dao_staking {
    use std::option::Option;
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::Metadata;

    #[view]
    public fun get_dao_for_token(_gov_token: Object<Metadata>): Option<address> {
        abort 0
    }

    public entry fun create_lock(
        _user: &signer,
        _gov_token: Object<Metadata>,
        _amount: u64,
        _lock_epochs: u64
    ) {
        abort 0
    }

    public entry fun increase_lock_amount(
        _user: &signer,
        _legacy_addr: address,
        _amount: u64
    ) {
        abort 0
    }

    public entry fun increase_lock_amount_from_native(
        _user: &signer,
        _legacy_addr: address,
        _native_amount: u64
    ) {
        abort 0
    }

    public entry fun withdraw_and_unwrap(
        _user: &signer,
        _legacy_addr: address
    ) {
        abort 0
    }

    public entry fun create_lock_from_coins<CoinType>(
        _user: &signer,
        _amount: u64,
        _lock_epochs: u64
    ) {
        abort 0
    }
}
