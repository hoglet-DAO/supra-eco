module dao_tax_router::tax_router {
    use std::vector;
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::{FungibleAsset, FungibleStore};
    use dao_tokens::smart_token::TaxFreeCap;

    public fun store_tax_free_cap(
        _dao_signer: &signer,
        _cap: TaxFreeCap,
        _routers: vector<address>
    ) {
        abort 0
    }

    #[view]
    public fun has_tax_free_router(_dao_address: address): bool {
        abort 0
    }

    #[view]
    public fun is_whitelisted_router(_dao_address: address, _router_address: address): bool {
        abort 0
    }

    #[view]
    public fun get_whitelisted_routers(_dao_address: address): vector<address> {
        abort 0
    }

    public fun add_router(_dao_signer: &signer, _router_address: address) {
        abort 0
    }

    public fun remove_router(_dao_signer: &signer, _router_address: address) {
        abort 0
    }

    public fun is_store_owned_by(_store: Object<FungibleStore>, _router_addr: address): bool {
        abort 0
    }

    public fun withdraw_tax_free(
        _dao_address: address,
        _router_proof: &signer,
        _from_store: Object<FungibleStore>,
        _amount: u64
    ): FungibleAsset {
        abort 0
    }

    public fun transfer_tax_free_from_owner(
        _dao_address: address,
        _owner: &signer,
        _from_store: Object<FungibleStore>,
        _to_store: Object<FungibleStore>,
        _amount: u64
    ) {
        abort 0
    }

    public fun deposit_tax_free(
        _dao_address: address,
        _router_proof: &signer,
        _to_store: Object<FungibleStore>,
        _fa: FungibleAsset
    ) {
        abort 0
    }
}
