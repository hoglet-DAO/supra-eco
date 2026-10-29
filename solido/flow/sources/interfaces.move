// SPDX-License-Identifier: MIT
module ATMOS::liquidity_pool {
    struct Pool has key {}
}

module ATMOS::atmos_entry {
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::Metadata;
    use ATMOS::liquidity_pool::Pool;

    public entry fun swap_exact_out_weighted_entry(
        _caller: &signer,
        _pool: Object<Pool>,
        _fa_in: Object<Metadata>,
        _max_in: u64,
        _fa_out: Object<Metadata>,
        _exact_out: u64
    ) {
        abort 0
    }

    public entry fun swap_exact_in_weighted_entry(
        _caller: &signer,
        _pool: Object<Pool>,
        _fa_in: Object<Metadata>,
        _exact_in: u64,
        _fa_out: Object<Metadata>,
        _min_out: u64
    ) {
        abort 0
    }
}

module SOLIDO::cdp_multi {
    public entry fun open_trove_fa(
        _caller: &signer,
        _coll_addr: address,
        _coll_amount: u64,
        _debt_amount: u64
    ) {
        abort 0
    }

    public entry fun deposit_or_mint_fa(
        _caller: &signer,
        _coll_addr: address,
        _coll_amount: u64,
        _debt_amount: u64
    ) {
        abort 0
    }
}
