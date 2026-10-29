/// The global config for dexlyn_swap: fees and manager accounts (admins).
module dexlyn_swap::global_config {

    /// Get DAO admin address.
    public fun get_dao_admin(): address {
        abort 0
    }

    /// Get emergency admin address.
    public fun get_emergency_admin(): address {
        abort 0
    }

    /// Get fee admin address.
    public fun get_fee_admin(): address {
        abort 0
    }

    /// Get default fee for pool.
    /// IMPORTANT: use functions in Liquidity Pool module as pool fees could be different from default ones.
    public fun get_default_fee<Curve>(): u64 {
        abort 0
    }

    /// Get default DAO fee.
    public fun get_default_dao_fee(): u64 {
        abort 0
    }

    #[view]
    public fun get_global_config_addr(): address {
        abort 0
    }
}
