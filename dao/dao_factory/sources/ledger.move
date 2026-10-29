module dao_factory::ledger {
    use std::vector;

    #[view]
    public fun get_proposal_state(_dao_address: address, _proposal_id: u64): u8 {
        abort 0
    }

    #[view]
    public fun get_proposal_details(_dao_address: address, _proposal_id: u64): (address, u64, u64, u64, bool, bool, u64, u64, u64) {
        abort 0
    }

    #[view]
    public fun get_proposal_ve_token(_dao_address: address, _proposal_id: u64): address {
        abort 0
    }

    #[view]
    public fun get_proposal_quorum(_dao_address: address, _proposal_id: u64): u64 {
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
