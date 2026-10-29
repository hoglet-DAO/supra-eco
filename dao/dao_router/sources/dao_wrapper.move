module dao_router::dao_wrapper {
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::{FungibleAsset, Metadata};

    struct FlashLoanReceiptFA {
        amount: u64,
        fee: u64,
        metadata: Object<Metadata>,
    }

    public fun unwrap_fa(_wrapper_fa: FungibleAsset): FungibleAsset {
        abort 0
    }

    public entry fun unwrap_entry(
        _user: &signer,
        _wrapped_metadata: Object<Metadata>,
        _amount: u64
    ) {
        abort 0
    }

    public fun flash_loan_fa(
        _native_metadata: Object<Metadata>,
        _amount: u64
    ): (FungibleAsset, FlashLoanReceiptFA) {
        abort 0
    }

    public fun repay_flash_loan_fa(
        _repayment_asset: FungibleAsset,
        _receipt: FlashLoanReceiptFA
    ) {
        abort 0
    }

    public fun flash_loan_receipt_amount(_receipt: &FlashLoanReceiptFA): u64 {
        abort 0
    }

    public fun flash_loan_receipt_fee(_receipt: &FlashLoanReceiptFA): u64 {
        abort 0
    }

    public fun flash_loan_receipt_metadata(_receipt: &FlashLoanReceiptFA): Object<Metadata> {
        abort 0
    }

    #[view]
    public fun is_wrapper_fa(_metadata: Object<Metadata>): bool {
        abort 0
    }

    #[view]
    public fun is_wrapper_registered_for_native(_native_metadata: Object<Metadata>): bool {
        abort 0
    }

    #[view]
    public fun get_original_fa(_wrapper_metadata: Object<Metadata>): Object<Metadata> {
        abort 0
    }

    #[view]
    public fun get_wrapper_for_fa(_native_metadata: Object<Metadata>): Object<Metadata> {
        abort 0
    }

    #[view]
    public fun wrapper_address(): address {
        abort 0
    }

    #[view]
    public fun get_balance_fa(_native_metadata: Object<Metadata>): u64 {
        abort 0
    }

    #[view]
    public fun expected_fee(_amount: u64): u64 {
        abort 0
    }

    #[view]
    public fun get_flash_loan_fee_bps(): u64 {
        abort 0
    }

    #[view]
    public fun get_admin(): address {
        abort 0
    }
}
