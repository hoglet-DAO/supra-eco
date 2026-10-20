module dao_views::legacy_views {
    use std::vector;

    #[view]
    public fun get_batch_nft_metadata(
        _nfts: vector<address>,
        _target_dao: address
    ): (
        vector<address>,
        vector<u64>,
        vector<u64>,
        vector<u64>,
        vector<bool>,
        u64
    ) {
        abort 0
    }

    #[view]
    public fun get_owned_nft_metadata(
        _nfts: vector<address>,
        _target_dao: address,
        _owners: vector<address>
    ): (
        vector<address>,
        vector<u64>,
        vector<u64>,
        vector<u64>,
        vector<bool>,
        vector<address>,
        u64
    ) {
        abort 0
    }
}
