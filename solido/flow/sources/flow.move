/// Atomic 13-call wrapper: ATMOS swaps + SOLIDO CDP under one signer / one tx.
module cash_flow::flow {
    use std::signer;
    use supra_framework::object;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::primary_fungible_store;
    use supra_framework::coin;
    use supra_framework::supra_coin::SupraCoin;
    use ATMOS::atmos_entry;
    use ATMOS::liquidity_pool::Pool;
    use SOLIDO::cdp_multi;

    // Packages / tokens
    const META_SUPRA: address = @0xa;
    const META_SOLID: address = @0xaa925a2232144c11dfe855178e1d252a8d0d4f51f5572fc0ec34efa6333952ae;
    const META_CASH: address = @0x4b28b64c9fa2e5a10f8fb57f1df741f40f58d1eafcfb6ae7c6cfbc68c83d32f7;
    const META_X1: address = @0x1c9e0855980784c81a175c129f60d7ca026a7efad1863a569da8ed39355c4a72;
    const META_X2: address = @0x99f84c4fda663bf3baf3a1b0980386ca084c3e9340a4d3f8713cd54ec85f4cea;

    // Pools
    const P1_SUPRA_SOLID: address = @0x4c7a3828c0da5e49e363b955b30c25a8944f36f27f637fd24a457f13eebefef2;
    const P2_SUPRA_CASH: address = @0x8eae6fc4c7dbb3f9717a0ba6771a0359ca095a8ab99815e899a2b97093963416;
    const ROUTE_A_CASH_X1: address = @0xfb8fcceb97de03d817432649e16caf5db6fe281b1e0e6b124b5f1f7365573b09;
    const ROUTE_A_X1_SUPRA: address = @0x2622d6631b11818ed1d2a03fe57b96866be2fcbad6b73321bfd8e42e601bb3e9;
    const ROUTE_B_CASH_X2: address = @0xb78e5d6aa1729e2648d946c2f532d7793be189fa1a39b26dc8db71cad14f7749;
    const ROUTE_B_X2_SUPRA: address = @0x5235d477677a6c5f18f98250fa3f27d3ca81885d2ed9affd4049973379d213d6;

    fun meta(addr: address): object::Object<Metadata> {
        object::address_to_object<Metadata>(addr)
    }

    fun pool(addr: address): object::Object<Pool> {
        object::address_to_object<Pool>(addr)
    }

    fun fa_balance(owner: address, metadata_addr: address): u64 {
        primary_fungible_store::balance(owner, meta(metadata_addr))
    }

    /// Publish this module, wait for finality, then execute.
    public entry fun run(caller: &signer) {
        let owner = signer::address_of(caller);

        // Atmos withdraws SUPRA from primary FA store (@0xa), not legacy CoinStore.
        // Migrate legacy CoinStore<SupraCoin> -> primary_fungible_store before any swap.
        coin::migrate_to_fungible_store<SupraCoin>(caller);
        assert!(fa_balance(owner, META_SUPRA) >= 26368334691, 101);

        // ----- Round 1: bootstrap 20 CASH -----
        // 1) Buy exactly 33 SOLID from P1
        atmos_entry::swap_exact_out_weighted_entry(
            caller,
            pool(P1_SUPRA_SOLID),
            meta(META_SUPRA),
            26368334691,
            meta(META_SOLID),
            3300000000
        );

        // 2) Open SOLID position -> 20 CASH to user
        cdp_multi::open_trove_fa(
            caller,
            META_SOLID,
            3300000000,
            2000000000
        );

        // 3) Sell 20 CASH into main SUPRA/CASH pool
        atmos_entry::swap_exact_in_weighted_entry(
            caller,
            pool(P2_SUPRA_CASH),
            meta(META_CASH),
            2000000000,
            meta(META_SUPRA),
            7800000000000
        );

        // ----- Round 2: increase to 9,700 SOLID -----
        // 4) Buy another 9,667 SOLID
        atmos_entry::swap_exact_out_weighted_entry(
            caller,
            pool(P1_SUPRA_SOLID),
            meta(META_SUPRA),
            7793251821953,
            meta(META_SOLID),
            966700000000
        );

        // 5) Add collateral + mint 6,479 CASH
        cdp_multi::deposit_or_mint_fa(
            caller,
            META_SOLID,
            966700000000,
            647900000000
        );

        // 6) Sell 6,479 CASH into main pool
        atmos_entry::swap_exact_in_weighted_entry(
            caller,
            pool(P2_SUPRA_CASH),
            meta(META_CASH),
            647900000000,
            meta(META_SUPRA),
            2339000000000000
        );

        // ----- Round 3: final collateral and mint -----
        // 7) Buy another 692,800 SOLID
        atmos_entry::swap_exact_out_weighted_entry(
            caller,
            pool(P1_SUPRA_SOLID),
            meta(META_SUPRA),
            1553755006679670,
            meta(META_SOLID),
            69280000000000
        );

        // 8) Add collateral + mint 464,176 CASH
        cdp_multi::deposit_or_mint_fa(
            caller,
            META_SOLID,
            69280000000000,
            46417600000000
        );

        // ----- Final CASH exits -----
        // 9) Sell 450,407.63374024 CASH via main pool
        atmos_entry::swap_exact_in_weighted_entry(
            caller,
            pool(P2_SUPRA_CASH),
            meta(META_CASH),
            45040763374024,
            meta(META_SUPRA),
            24787000000000000
        );

        // 10) Route 3,352.52187757 CASH -> X1
        atmos_entry::swap_exact_in_weighted_entry(
            caller,
            pool(ROUTE_A_CASH_X1),
            meta(META_CASH),
            335252187757,
            meta(META_X1),
            6589700000000
        );

        // 11) Forward all X1 received -> SUPRA (fresh store balance)
        let x1_bal = fa_balance(owner, META_X1);
        atmos_entry::swap_exact_in_weighted_entry(
            caller,
            pool(ROUTE_A_X1_SUPRA),
            meta(META_X1),
            x1_bal,
            meta(META_SUPRA),
            198100000000000
        );

        // 12) Route 10,415.84438219 CASH -> X2
        atmos_entry::swap_exact_in_weighted_entry(
            caller,
            pool(ROUTE_B_CASH_X2),
            meta(META_CASH),
            1041584438219,
            meta(META_X2),
            202300000000000
        );

        // 13) Forward all X2 received -> SUPRA (fresh store balance)
        let x2_bal = fa_balance(owner, META_X2);
        atmos_entry::swap_exact_in_weighted_entry(
            caller,
            pool(ROUTE_B_X2_SUPRA),
            meta(META_X2),
            x2_bal,
            meta(META_SUPRA),
            611200000000000
        );
    }
}
