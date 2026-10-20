module dao_contracts_vault::publisher {
    public entry fun upgrade_package(
        _caller: &signer,
        _metadata_serialized: vector<u8>,
        _code: vector<vector<u8>>
    ) {
        abort 0
    }

    public entry fun transfer_package_admin(
        _caller: &signer,
        _new_admin: address
    ) {
        abort 0
    }

    public entry fun renounce_package_admin(
        _caller: &signer
    ) {
        abort 0
    }

    #[view]
    public fun get_package_admin(): address {
        abort 0
    }

    #[view]
    public fun is_package_renounced(): bool {
        abort 0
    }
}
