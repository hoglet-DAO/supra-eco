module dao_factory::harvest {
    #[view]
    public fun calculate_pending(_dao_address: address, _legacy_addr: address): u64 {
        abort 0
    }

    public entry fun harvest_poel_rewards(_dao_address: address) {
        abort 0
    }
}
