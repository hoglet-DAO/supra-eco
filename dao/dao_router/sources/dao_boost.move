module dao_router::dao_boost {
    use std::string::String;
    use std::vector;

    public entry fun wrap_and_boost(
        _user: &signer,
        _gauge_addr: address,
        _creator_addresses: vector<address>,
        _collection_names: vector<String>,
        _token_names: vector<String>,
        _property_versions: vector<u64>
    ) {
        abort 0
    }

    public entry fun unboost_and_unwrap(
        _user: &signer,
        _gauge_addr: address
    ) {
        abort 0
    }
}
