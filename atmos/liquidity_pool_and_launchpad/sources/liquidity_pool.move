module atmos_swap::liquidity_pool {
    use std::option::{Option};
    use std::string::{String};
    use supra_framework::fungible_asset::{Metadata, FungibleAsset, MintRef, TransferRef, BurnRef};
    use supra_framework::object::{Object, ExtendRef};
    use supra_framework::smart_table::{SmartTable};
    use supra_framework::smart_vector::{SmartVector};

    // ------------------------------------------
    // ----------------- Structs ----------------
    // CRITICAL: These must match the real contract byte-for-byte
    // ------------------------------------------

    #[resource_group_member(group = supra_framework::object::ObjectGroup)]
    struct Pool has key {
        extend_ref: ExtendRef,
        assets_metadata: vector<Object<Metadata>>,
        pool_type: u8,
        swap_fee_bps: u64,
        locked: bool,
        lp_token_mint_ref: MintRef,
        lp_token_transfer_ref: TransferRef,
        lp_token_burn_ref: BurnRef,
    }

    #[resource_group_member(group = supra_framework::object::ObjectGroup)]
    struct StablePool has key {
        amp_factor: u64,
        precision_multipliers: vector<u64>,
    }

    #[resource_group_member(group = supra_framework::object::ObjectGroup)]
    struct WeightedPool has key {
        weights: vector<u64>,
    }

    struct RemoveLiquiditySimulate has drop {
        withdrawn_amounts: vector<u64>,
    }

    struct RemoveLiquiditySimulateV2 has drop {
        withdrawn_amounts: vector<u64>,
        assets : vector<Object<Metadata>>,
    }

    struct LiquidityBalancesSimulate has drop {
        pool: address,
        lp_balance: u64,
        tokens: vector<String>,
        withdrawn_amounts: vector<u64>,
    }

    struct AddLiquiditySimulate has drop {
        minted_lp_token_amount: u64,
        refund_amounts: vector<u64>,
    }

    struct SwapSimulate has drop {
        amount_in: u64,
        amount_in_post_fee: u64,
        amount_out: u64,
        amount_normalized_in: u128,
        amount_normalized_out: u128,
        total_fee_amount: u64,
        protocol_fee_amount: u64,
        idx_in: u64,
        idx_out: u64,
        swap_fee_bps: u64,
    }

    struct PoolStore has store, key {
        pools: SmartTable<address, PoolResponse>,
        protocol_fee_ratio: u64,
        pools_vec: SmartVector<address>,
    }

    struct PoolResponse has store, copy, drop {
        pool_address: address,
        coins: vector<Object<Metadata>>,
        pool_balances: vector<u64>,
        lp_token_supply: u64,
        amp_factor: u64,
        precision_multipliers: vector<u64>,
        weights: vector<u64>,
        swap_fee_bps: u64,
        pool_type: u8,
        locked: bool,
    }

    struct UserPoolBalancesPagigatedRes has drop, store {
        user_balances: vector<UserPoolbalances>,
        next_bucket_num : Option<u64>,
        start_idx : Option<u64>,
    }

    struct UserPoolbalances has drop, store {
        pool_address : address,
        lp_balance : u64
    }

    // ------------------------------------------
    // ------------ Public Functions ------------
    // ------------------------------------------

    public fun create_pool_stable(
        _initial_assets: vector<FungibleAsset>,
        _swap_fee_bps: u64,
        _amp_factor: u64
    ) : (Object<Pool>, FungibleAsset)  {
        abort 0
    }

    public fun create_pool_weighted(
        _initial_assets: vector<FungibleAsset>,
        _pool_weights: vector<u64>,
        _swap_fee_bps: u64
    ) : (Object<Pool>, FungibleAsset)  {
        abort 0
    }

    public fun add_liquidity_stable(
        _pool: Object<Pool>,
        _assets_to_add: vector<FungibleAsset>
    ) : FungibleAsset  {
        abort 0
    }

    public fun add_liquidity_weighted(
        _pool: Object<Pool>,
        _assets_to_add: vector<FungibleAsset>
    ) : (FungibleAsset, vector<FungibleAsset>)  {
        abort 0
    }

    public fun remove_liquidity(
        _pool: Object<Pool>,
        _lp_tokens: FungibleAsset
    ) : vector<FungibleAsset>  {
        abort 0
    }

    public fun swap_exact_in_stable(
        _trader: &signer,
        _pool: Object<Pool>,
        _tokens_in: FungibleAsset,
        _token_out: Object<Metadata>
    ) : FungibleAsset  {
        abort 0
    }

    public fun swap_exact_in_weighted(
        _trader: &signer,
        _pool: Object<Pool>,
        _input_tokens: FungibleAsset,
        _token_out: Object<Metadata>
    ) : FungibleAsset  {
        abort 0
    }

    public fun swap_exact_out_stable(
        _trader: &signer,
        _pool: Object<Pool>,
        _input_tokens: FungibleAsset,
        _token_out: Object<Metadata>,
        _exact_amount_out: u64
    ) : (FungibleAsset, FungibleAsset) {
        abort 0
    }

    public fun swap_exact_out_weighted(
        _trader: &signer,
        _pool: Object<Pool>,
        _input_tokens: FungibleAsset,
        _token_out: Object<Metadata>,
        _exact_amount_out: u64
    ) : (FungibleAsset, FungibleAsset) {
        abort 0
    }

    // ------------------------------------------
    // -- Existence Checks & Seeds (Used by Adapter) --
    // ------------------------------------------

    public fun stable_pool_exists(
        _token_metadata: vector<Object<Metadata>>,
        _swap_fee_bps: u64
    ) : bool  {
        abort 0
    }

    public fun weighted_pool_exists(
        _token_metadata: vector<Object<Metadata>>,
        _weights: vector<u64>,
        _swap_fee_bps: u64
    ) : bool  {
        abort 0
    }

    #[view]
    public fun lp_seed_stable(
        _token_metadata: vector<Object<Metadata>>,
        _swap_fee_bps: u64
    ) : vector<u8>  {
        abort 0
    }

    #[view]
    public fun lp_seed_weighted(
        _token_metadata: vector<Object<Metadata>>,
        _weights: vector<u64>,
        _swap_fee_bps: u64
    ) : vector<u8>  {
        abort 0
    }

    // ------------------------------------------
    // ------------ View Functions --------------
    // ------------------------------------------

    #[view]
    public fun pool_amp_factor(_pool: Object<Pool>) : u64  { abort 0 }

    #[view]
    public fun pool_assets_metadata(_pool: Object<Pool>) : vector<Object<Metadata>>  { abort 0 }

    #[view]
    public fun pool_balances(_pool: Object<Pool>) : vector<u64>  { abort 0 }

    #[view]
    public fun pool_is_stable(_pool: Object<Pool>) : bool  { abort 0 }

    #[view]
    public fun pool_is_weighted(_pool: Object<Pool>) : bool  { abort 0 }

    #[view]
    public fun pool_locked(_pool: Object<Pool>) : bool  { abort 0 }

    #[view]
    public fun pool_lp_token_metadata(_pool: Object<Pool>) : Object<Metadata>  { abort 0 }

    #[view]
    public fun pool_lp_token_supply(_pool: Object<Pool>) : u64  { abort 0 }

    #[view]
    public fun pool_precision_multipliers(_pool: Object<Pool>) : vector<u64>  { abort 0 }

    #[view]
    public fun pool_size(_pool: Object<Pool>) : u64  { abort 0 }

    #[view]
    public fun pool_swap_fee_bps(_pool: Object<Pool>) : u64  { abort 0 }

    #[view]
    public fun pool_type(_pool: Object<Pool>) : u8 { abort 0 }

    #[view]
    public fun pool_weights(_pool: Object<Pool>) : vector<u64>  { abort 0 }
}
