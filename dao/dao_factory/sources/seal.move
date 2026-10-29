module dao_factory::seal {
    use std::vector;

    public fun resolve(_dao_address: address, _proposal_id: u64, _args: vector<u8>): signer {
        abort 0
    }
}
