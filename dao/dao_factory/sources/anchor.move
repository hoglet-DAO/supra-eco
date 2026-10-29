module dao_factory::anchor {
    public entry fun queue_proposal(_dao_address: address, _proposal_id: u64) {
        abort 0
    }

    public entry fun execute_action(_caller: &signer, _dao_address: address, _proposal_id: u64) {
        abort 0
    }

    public entry fun cancel_proposal(_caller: &signer, _dao_address: address, _proposal_id: u64) {
        abort 0
    }

    public entry fun public_cancel_proposal(_dao_address: address, _proposal_id: u64) {
        abort 0
    }

    public entry fun cancel_expired_proposal(_dao_address: address, _proposal_id: u64) {
        abort 0
    }

    public entry fun finalize_proposal(_dao_address: address, _proposal_id: u64) {
        abort 0
    }
}
