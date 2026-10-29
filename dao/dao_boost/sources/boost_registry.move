module dao_boost::boost_registry {
    use std::vector;
    use supra_framework::object::Object;
    use aptos_token_objects::token::Token;

    public fun initialize(_dao_signer: &signer) {
        abort 0
    }

    public fun set_collection(
        _dao_signer: &signer,
        _collection_addr: address,
        _boost_bps: u64
    ) {
        abort 0
    }

    public fun remove_collection(
        _dao_signer: &signer,
        _collection_addr: address
    ) {
        abort 0
    }

    public fun compute_boost(
        _dao_address: address,
        _nft_tokens: vector<Object<Token>>,
        _base_power: u64
    ): u64 {
        abort 0
    }

    public fun compute_escrowed_boost(
        _dao_address: address,
        _nft_addrs: vector<address>,
        _base_power: u64
    ): u64 {
        abort 0
    }

    public fun hard_cap_bps(): u64 {
        abort 0
    }

    #[view]
    public fun is_initialized(_dao_address: address): bool {
        abort 0
    }

    #[view]
    public fun get_collection_boost(_dao_address: address, _collection_addr: address): u64 {
        abort 0
    }

    #[view]
    public fun is_boosted_collection(_dao_address: address, _collection_addr: address): bool {
        abort 0
    }

    #[view]
    public fun get_registry_size(_dao_address: address): u64 {
        abort 0
    }
}
