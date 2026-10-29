module dexlyn_swap::curves {

    // --- STRUCTS ---
    // Based on the ABI: 
    // 1. They are NOT empty (they have a boolean dummy_field).
    // 2. They do NOT have abilities listed (no 'has drop, store').

    struct Uncorrelated {
        dummy_field: bool
    }

    struct Stable {
        dummy_field: bool
    }

    // --- FUNCTIONS ---
    // Included to match the module interface completely.

    public fun assert_valid_curve<Curve>() {
        abort 0
    }

    #[view]
    public fun is_stable<Curve>(): bool {
        abort 0
    }

    #[view]
    public fun is_uncorrelated<Curve>(): bool {
        abort 0
    }

    #[view]
    public fun is_valid_curve<Curve>(): bool {
        abort 0
    }
}
