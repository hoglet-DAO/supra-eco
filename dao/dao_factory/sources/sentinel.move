module dao_factory::sentinel {
    public entry fun pause(
        _caller: &signer,
        _dao_address: address,
        _duration_epochs: u64
    ) {
        abort 0
    }

    public entry fun unpause(
        _caller: &signer,
        _dao_address: address
    ) {
        abort 0
    }

    public fun assert_not_paused(_dao_address: address) {
        abort 0
    }

    #[view]
    public fun is_paused(_dao_address: address): bool {
        abort 0
    }

    #[view]
    public fun pause_expiry_epoch(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun can_pause(_dao_address: address): bool {
        abort 0
    }
}
