module spike_amm::flash_loan_router {
    use supra_framework::coin::{Coin};
    use supra_framework::fungible_asset::{FungibleAsset, Metadata};
    use supra_framework::object::{Object};
    
    // We only import what is necessary to define argument and return TYPES.
    use spike_amm::amm_pair;
    use spike_amm::coin_wrapper;

    // --- STRUCTS ---
    
    // IMPORTANT: We keep 'phantom' here because the real contract uses it.
    // This ensures that the type hash is identical to the one on mainnet.
    struct FlashLoanFromPoolAsCoinReceipt<phantom CoinType> {
        _pair_receipt: amm_pair::FlashLoanReceipt,
        _loan_amount: u64
    }
    
    // ===================================================================
    // PUBLIC FUNCTIONS (INTERFACES)
    // ===================================================================

    public fun borrow_from_vault<CoinType>(
        _amount: u64
    ): (Coin<CoinType>, coin_wrapper::FlashLoanReceipt<CoinType>) {
        abort 0
    }

    public fun repay_to_vault<CoinType>(
        _payment: Coin<CoinType>,
        _receipt: coin_wrapper::FlashLoanReceipt<CoinType>
    ) {
        abort 0
    }

    public fun borrow_from_pool_as_coin<CoinType>(
        _pair: Object<amm_pair::Pair>,
        _amount: u64
    ): (Coin<CoinType>, FlashLoanFromPoolAsCoinReceipt<CoinType>) {
        abort 0
    }

    public fun repay_to_pool_as_coin<CoinType>(
        _payment: Coin<CoinType>,
        _receipt: FlashLoanFromPoolAsCoinReceipt<CoinType>,
        _fungible_assetpair: Object<amm_pair::Pair>
    ) {
        abort 0
    }

    // ===================================================================
    // 2. "POOL" SCENARIO: Withdrawal from AMM Pool (FA)
    // ===================================================================

    public fun borrow_fa_from_pool(
        _pair: Object<amm_pair::Pair>,
        _token: Object<Metadata>,
        _amount: u64
    ): (FungibleAsset, amm_pair::FlashLoanReceipt) {
        abort 0
    }

    public fun repay_fa_to_pool(
        _pair: Object<amm_pair::Pair>,
        _payment: FungibleAsset,
        _receipt: amm_pair::FlashLoanReceipt
    ) {
        abort 0
    }

    public fun native_fa_to_coin<CoinType>(_fa: FungibleAsset): Coin<CoinType> {
        abort 0
    }

    public fun coin_to_native_fa<CoinType>(_c: Coin<CoinType>): FungibleAsset {
        abort 0
    }

    public fun get_internal_metadata<CoinType>(): Object<Metadata> {
        abort 0
    }

    public fun borrow_fa_from_vault(
        _token: Object<Metadata>,
        _amount: u64
    ): (FungibleAsset, coin_wrapper::FlashLoanReceiptFA) {
        abort 0
    }

    public fun repay_fa_to_vault(
        _payment: FungibleAsset,
        _receipt: coin_wrapper::FlashLoanReceiptFA
    ) {
        abort 0
    }

    // ===================================================================
    // VIEW FUNCTIONS
    // ===================================================================

    #[view]
    public fun check_best_liquidity_source<CoinType>(
        _pair: Object<amm_pair::Pair>
    ): u8 {
        abort 0
    }

    #[view]
    public fun expected_fee(_amount: u64): u64 {
        abort 0
    }

    #[view]
    public fun max_flash_loan_vault<CoinType>(): u64 {
        abort 0
    }

    #[view]
    public fun max_flash_loan_pool_smart<CoinType>(_pair: Object<amm_pair::Pair>): u64 {
        abort 0
    }

    #[view]
    public fun max_flash_loan_pool(
        _pair: Object<amm_pair::Pair>, 
        _token: Object<Metadata>
    ): u64 {
        abort 0
    }

    #[view]
    public fun get_native_metadata<CoinType>(): Object<Metadata> {
        abort 0
    }

    #[view]
    public fun check_best_liquidity_source_fa(
        _pair: Object<amm_pair::Pair>,
        _token: Object<Metadata>
    ): u8 {
        abort 0
    }

    #[view]
    public fun max_flash_loan_vault_fa(
        _token: Object<Metadata>
    ): u64 {
        abort 0
    }
}

