module dao_contracts_vault::vault_fee {
    public entry fun set_fee_config(
        _admin: &signer,
        _fee_recipient: address,
        _fee_amount: u64
    ) {
        abort 0
    }

    public entry fun transfer_fee_admin(
        _admin: &signer,
        _new_admin: address
    ) {
        abort 0
    }

    #[view]
    public fun get_fee_info(): (u64, address, address) {
        abort 0
    }

    #[view]
    public fun get_fee_limits(): (u64, u64) {
        abort 0
    }

    #[view]
    public fun get_fee_admin(): address {
        abort 0
    }
}
