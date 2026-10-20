module dao_factory::charter {
    use std::option::Option;
    use std::string::String;
    use std::vector;

    public fun min_delay_seconds(): u64 {
        abort 0
    }

    public fun max_delay_seconds(): u64 {
        abort 0
    }

    public fun min_period_seconds(): u64 {
        abort 0
    }

    #[view]
    public fun is_inflationary(_dao_address: address): bool {
        abort 0
    }

    #[view]
    public fun is_blessed(_dao_address: address): bool {
        abort 0
    }

    public entry fun bless_dao(_curator: &signer, _dao_address: address) {
        abort 0
    }

    #[view]
    public fun get_launcher_address(_dao_address: address): address {
        abort 0
    }

    #[view]
    public fun get_guardian(_dao_address: address): Option<address> {
        abort 0
    }

    public fun validate_config_value(_dao_address: address, _config_key: u8, _config_value: u64) {
        abort 0
    }

    #[view]
    public fun get_proposal_count(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun is_active(_dao_address: address): bool {
        abort 0
    }

    #[view]
    public fun get_dao_config_view(_dao_address: address): (String, u64, u64, u64, u64, u64, u64, u64) {
        abort 0
    }

    #[view]
    public fun get_late_quorum_extension(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun get_timelock_delay(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun get_grace_period(_dao_address: address): u64 {
        abort 0
    }

    #[view]
    public fun get_proposal_snapshot_epoch(_dao_address: address, _proposal_id: u64): u64 {
        abort 0
    }

    #[view]
    public fun get_proposal_type(_dao_address: address, _proposal_id: u64): u8 {
        abort 0
    }

    #[view]
    public fun get_proposal_action_treasury(_dao_address: address, _proposal_id: u64): (address, u64) {
        abort 0
    }

    #[view]
    public fun get_proposal_action_config(_dao_address: address, _proposal_id: u64): (u8, u64) {
        abort 0
    }

    #[view]
    public fun get_proposal_action_gauge(_dao_address: address, _proposal_id: u64): (u8, address, u64) {
        abort 0
    }

    #[view]
    public fun get_proposal_action_module_setting(_dao_address: address, _proposal_id: u64): (u8, address, vector<u8>, u64) {
        abort 0
    }

    #[view]
    public fun get_proposal_execution_hash(_dao_address: address, _proposal_id: u64): vector<u8> {
        abort 0
    }

    #[view]
    public fun get_proposal_args_commitment(_dao_address: address, _proposal_id: u64): vector<u8> {
        abort 0
    }

    #[view]
    public fun get_proposal_script_id(_dao_address: address, _proposal_id: u64): u64 {
        abort 0
    }

    #[view]
    public fun get_proposal_action_script_allow(_dao_address: address, _proposal_id: u64): (u64, bool) {
        abort 0
    }

    #[view]
    public fun get_dynamic_quorum(_dao_address: address, _default_quorum: u64): u64 {
        abort 0
    }
}
