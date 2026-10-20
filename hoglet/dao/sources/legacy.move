module dao_factory::legacy {
    use std::option::Option;
    use std::string::String;
    use supra_framework::object::Object;

    struct VeToken has key {}

    #[view]
    public fun get_voting_power(_legacy: Object<VeToken>): u64 {
        abort 0
    }

    #[view]
    public fun get_voting_power_at(_legacy: Object<VeToken>, _query_epoch: u64): u64 {
        abort 0
    }

    #[view]
    public fun locked_amount(_legacy: Object<VeToken>): u64 {
        abort 0
    }

    #[view]
    public fun is_expired(_legacy: Object<VeToken>): bool {
        abort 0
    }

    #[view]
    public fun get_nft_metadata_info(_legacy: Object<VeToken>): (u64, u64, address, u64, String, String, u64) {
        abort 0
    }

    #[view]
    public fun get_token_metadata_address(_dao_address: address): address {
        abort 0
    }

    #[view]
    public fun get_total_locked(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun get_total_locked_at(_dao_address: address, _query_epoch: u64): u64 {
        abort 0
    }

    #[view]
    public fun get_total_voting_power_at(_dao_address: address, _query_epoch: u64): u64 {
        abort 0
    }

    #[view]
    public fun get_total_voting_power(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun get_rebase_store_address(_dao_address: address): address {
        abort 0
    }

    #[view]
    public fun get_escrow_store_address(_dao_address: address): address {
        abort 0
    }

    #[view]
    public fun get_delegate(_legacy: Object<VeToken>): Option<address> {
        abort 0
    }

    #[view]
    public fun get_delegator(_ve_token_obj: Object<VeToken>): address {
        abort 0
    }

    #[view]
    public fun get_owner_by_address(_ve_token_addr: address): address {
        abort 0
    }

    #[view]
    public fun get_dao_address(_legacy: Object<VeToken>): address {
        abort 0
    }

    #[view]
    public fun ve_info(_nft_addr: address, _target_dao: address): (bool, u64, u64, bool) {
        abort 0
    }

    public fun max_lock_epochs(): u64 {
        abort 0
    }

    public fun create_lock(
        _user: &signer,
        _dao_address: address,
        _amount: u64,
        _lock_epochs: u64
    ): Object<VeToken> {
        abort 0
    }

    public entry fun extend_lockup(
        _user: &signer,
        _legacy_addr: address,
        _new_end_epoch: u64
    ) {
        abort 0
    }

    public entry fun increase_amount(
        _user: &signer,
        _legacy_addr: address,
        _amount: u64
    ) {
        abort 0
    }

    public entry fun withdraw(
        _user: &signer,
        _legacy_addr: address
    ) {
        abort 0
    }

    public entry fun merge(
        _user: &signer,
        _from_legacy_addr: address,
        _to_legacy_addr: address
    ) {
        abort 0
    }

    public entry fun delegate_voting_power(
        _user: &signer,
        _legacy_addr: address,
        _delegate_to: address
    ) {
        abort 0
    }

    public entry fun revoke_delegation(
        _user: &signer,
        _legacy_addr: address
    ) {
        abort 0
    }

    #[view]
    public fun is_delegate(_ve_token_obj: Object<VeToken>, _user: address): bool {
        abort 0
    }

    public entry fun claim_rewards(
        _user: &signer,
        _legacy_addr: address
    ) {
        abort 0
    }

    #[view]
    public fun pending_rewards(_legacy: Object<VeToken>): u64 {
        abort 0
    }

    #[view]
    public fun pending_rebase(_ve_addr: address): u64 {
        abort 0
    }

    public entry fun compound(
        _caller: &signer,
        _legacy_addr: address
    ) {
        abort 0
    }

    public entry fun sweep_expired_rebase(
        _legacy_addr: address
    ) {
        abort 0
    }
}
