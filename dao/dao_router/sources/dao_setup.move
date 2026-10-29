module dao_router::dao_setup {
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::Metadata;

    public entry fun activate_dao(
        _user: &signer,
        _governance_token: Object<Metadata>
    ) {
        abort 0
    }

    public entry fun create_dao_static_coin<CoinType>(_creator: &signer) {
        abort 0
    }

    public fun resolve_metadata<CoinType>(): Object<Metadata> {
        abort 0
    }
}
