module spike_amm::coin_wrapper {
    use supra_framework::object::{Object};
    use supra_framework::coin::{Coin};
    use supra_framework::fungible_asset::{FungibleAsset, Metadata};
    use std::string::{String};
    use std::option;

    struct FlashLoanReceipt<phantom CoinType> {
        amount: u64,
        fee: u64
    }

    struct FlashLoanReceiptFA {
        amount: u64,
        fee: u64,
        metadata: Object<Metadata>
    }

    #[view]
    public fun view_wrapper_by_components(
        _account_address: address, 
        _module_name: vector<u8>, 
        _struct_name: vector<u8>
    ): option::Option<Object<Metadata>> {
        abort 0
    }

    #[view]
    public fun is_initialized(): bool {
        abort 0
    }

    #[view]
    public fun wrapper_address(): address {
        abort 0
    }

    #[view]
    public fun is_supported<CoinType>(): bool {
        abort 0
    }

    #[view]
    public fun is_wrapper(_metadata: Object<Metadata>): bool {
        abort 0
    }

    #[view]
    public fun get_coin_type(_metadata: Object<Metadata>): String {
        abort 0
    }

    #[view]
    public fun get_wrapper<CoinType>(): Object<Metadata> {
        abort 0
    }

    #[view]
    public fun get_original(_fungible_asset: Object<Metadata>): String {
        abort 0
    }

    #[view]
    public fun format_fungible_asset(_fungible_asset: Object<Metadata>): String {
        abort 0
    }

    #[view]
    public fun get_balance<CoinType>(): u64 {
        abort 0
    }

    #[view]
    public fun flash_loan<CoinType>(_amount: u64): (Coin<CoinType>, FlashLoanReceipt<CoinType>) {
        abort 0
    }

    public fun repay_flash_loan<CoinType>(_payment: Coin<CoinType>, _receipt: FlashLoanReceipt<CoinType>) {
        abort 0
    }
    public fun collect_accumulated_fees<CoinType>() {
        abort 0
    }

    // ===================================================================
    // V2 UPGRADE: FA NATIVE SUPPORT
    // ===================================================================

    public fun flash_loan_fa(
        _metadata: Object<Metadata>,
        _amount: u64
    ): (FungibleAsset, FlashLoanReceiptFA) {
        abort 0
    }

    public fun repay_flash_loan_fa(
        _payment: FungibleAsset,
        _receipt: FlashLoanReceiptFA
    ) {
        abort 0
    }

    public fun collect_accumulated_fees_fa(

    ) {
        abort 0
    }
    
}
