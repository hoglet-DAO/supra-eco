module dao_factory::petra {
    use std::option::Option;
    use std::string::String;
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::{Metadata, MintRef};
    use dao_tokens::smart_token::TaxFreeCap;

    public entry fun transfer_admin(_admin: &signer, _new_admin: address) {
        abort 0
    }

    public entry fun accept_admin(_candidate: &signer) {
        abort 0
    }

    public entry fun accept_admin_for_dao(_dao_address: address) {
        abort 0
    }

    public entry fun set_curator(_admin: &signer, _new_curator: address) {
        abort 0
    }

    public entry fun reassign_curator(_admin: &signer, _dao_address: address, _new_curator: address) {
        abort 0
    }

    public entry fun approve_launcher(_admin: &signer, _launcher: address) {
        abort 0
    }

    public entry fun revoke_launcher(_admin: &signer, _launcher: address) {
        abort 0
    }

    public entry fun set_creation_fee(_admin: &signer, _new_fee: u64) {
        abort 0
    }

    public entry fun set_fee_receiver(_admin: &signer, _new_receiver: address) {
        abort 0
    }

    public entry fun add_default_bribe_token(_admin: &signer, _token_addr: address) {
        abort 0
    }

    public entry fun remove_default_bribe_token(_admin: &signer, _token_addr: address) {
        abort 0
    }

    public entry fun set_default_config(_admin: &signer, _config_key: u8, _value: u64) {
        abort 0
    }

    public entry fun renounce_admin(_admin: &signer) {
        abort 0
    }

    public entry fun create_dao_static(
        _creator: &signer,
        _governance_token: Object<Metadata>
    ) {
        abort 0
    }

    public entry fun create_dao_static_for_wrapper(
        _creator: &signer,
        _wrapped_token: Object<Metadata>,
        _native_token: Object<Metadata>
    ) {
        abort 0
    }

    public fun create_dao_static_from_launcher(
        _creator: &signer,
        _launcher_signer: &signer,
        _governance_token: Object<Metadata>,
        _expected_supply: u128
    ): address {
        abort 0
    }

    public fun create_dao_inflationary(
        _creator: &signer,
        _governance_token: Object<Metadata>,
        _mint_ref: MintRef
    ): address {
        abort 0
    }

    public fun claim_token_for_launcher(
        _launcher_signer: &signer,
        _governance_token: Object<Metadata>
    ) {
        abort 0
    }

    public entry fun claim_token_by_admin(
        _admin: &signer,
        _launcher_address: address,
        _governance_token: Object<Metadata>
    ) {
        abort 0
    }

    public entry fun unclaim_token(
        _admin: &signer,
        _governance_token: Object<Metadata>
    ) {
        abort 0
    }

    public fun create_dao_inflationary_from_launcher(
        _creator: &signer,
        _launcher_signer: &signer,
        _governance_token: Object<Metadata>,
        _expected_supply: u128,
        _amm_pool_addresses: vector<address>
    ): address {
        abort 0
    }

    public entry fun activate_dao(_launcher_signer: &signer, _dao_address: address) {
        abort 0
    }

    public entry fun activate_seeded_gauge(
        _launcher_signer: &signer,
        _dao_address: address,
        _staking_token_addr: address
    ) {
        abort 0
    }

    public fun store_tax_free_cap(
        _launcher_signer: &signer,
        _dao_address: address,
        _cap: TaxFreeCap,
        _routers: vector<address>
    ) {
        abort 0
    }

    public fun add_tax_router(
        _launcher_signer: &signer,
        _dao_address: address,
        _router_address: address
    ) {
        abort 0
    }

    public fun update_static_dao_threshold(
        _launcher_signer: &signer,
        _dao_address: address,
        _governance_token: Object<Metadata>
    ) {
        abort 0
    }

    public fun activate_dao_inflationary(
        _launcher_signer: &signer,
        _dao_address: address,
        _governance_token: Object<Metadata>,
        _mint_ref: MintRef
    ) {
        abort 0
    }

    #[view]
    public fun is_admin_active(): bool {
        abort 0
    }

    #[view]
    public fun get_creation_fee(): u64 {
        abort 0
    }

    #[view]
    public fun get_curator(): address {
        abort 0
    }

    #[view]
    public fun get_dao_for_token(_token: Object<Metadata>): Option<address> {
        abort 0
    }

    #[view]
    public fun get_dao_token_metadata(_token_addr: address): (String, String, u8, String, String) {
        abort 0
    }
}
