module dao_views::proposal_views {
    use std::vector;

    #[view]
    public fun get_proposal_full_info(_dao_address: address, _proposal_id: u64): (
        u8,
        address,
        u64,
        u64,
        u64,
        bool,
        bool,
        u64,
        u64,
        u64,
        u64,
        address,
        u64
    ) {
        abort 0
    }

    #[view]
    public fun get_batch_proposal_states(_dao_address: address, _proposal_ids: vector<u64>): vector<u8> {
        abort 0
    }
}
