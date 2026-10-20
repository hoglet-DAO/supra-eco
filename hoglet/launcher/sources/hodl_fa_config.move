module hoglet_hodl::hodl_fa_config {
    use std::option::Option;

    public fun get_emergency_admin_address(): address {
        abort 0
    }

    public fun get_pool_registration_fee_config(): (u64, address) {
        abort 0
    }

    public fun get_linked_contract_address(): Option<address> {
        abort 0
    }
}
