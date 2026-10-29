/// dexlyn_swap LP coin.
module dexlyn_swap_lp::lp_coin {
    /// LP coin type for dexlyn_swap.
    // Added 'has drop, store' to ensure compatibility when used as a type witness or in storage.
    struct LP<phantom X, phantom Y, phantom Curve> has drop, store {}
}
