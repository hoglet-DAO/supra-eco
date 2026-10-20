/// This module provides high-level entry points for Atmos Swap protocol
/// Handles user interactions with pools including creation, liquidity management, and swaps
/// Manages both stable and weighted pool operations with safety checks
module atmos_swap::atmos_entry {
    use supra_framework::fungible_asset;
    use supra_framework::object;

    use atmos_swap::liquidity_pool::{Pool};


    // ------------------------------------------
    // --------- Public Entry functions ---------
    // ------------------------------------------


    /// Adds liquidity to stable pool with safety checks
    /// Handles token collection and LP token distribution
    ///
    /// # Parameters
    /// * `user`: Account adding liquidity
    /// * `pool`: Target pool
    /// * `deposit_amounts`: Amount for each token
    /// * `min_lp_amount`: Minimum acceptable LP tokens
    ///
    /// # Process Flow
    /// 1. Validates input parameters
    /// 2. Collects tokens from user
    /// 3. Adds liquidity to pool
    /// 4. Returns LP tokens
    ///
    /// # Aborts
    /// * If amounts don't match pool tokens
    /// * If user has insufficient balance
    /// * If LP tokens below minimum
    public entry fun add_liquidity_stable_entry(
        _user: &signer,
        _pool: object::Object<Pool>,
        _deposit_amounts: vector<u64>,
        _min_lp_amount: u64
    ) {
        abort 0
    }

    /// Adds liquidity to weighted pool with safety checks
    /// Handles token collection, LP token distribution, and refunds
    ///
    /// # Parameters
    /// * `user`: Account adding liquidity
    /// * `pool`: Target pool
    /// * `deposit_amounts`: Amount for each token
    /// * `min_lp_amount`: Minimum acceptable LP tokens
    ///
    /// # Process Flow
    /// 1. Validates inputs
    /// 2. Collects tokens
    /// 3. Adds liquidity
    /// 4. Returns LP tokens
    /// 5. Processes refunds
    ///
    /// # Aborts
    /// * If amounts don't match pool tokens
    /// * If user has insufficient balance
    /// * If LP tokens below minimum
    public entry fun add_liquidity_weighted_entry(
        _user: &signer,
        _pool: object::Object<Pool>,
        _deposit_amounts: vector<u64>,
        _min_lp_amount: u64
    )  {
        abort 0
    }

    /// Creates new stable pool with initial liquidity
    /// Sets up pool parameters and deposits initial tokens
    ///
    /// # Parameters
    /// * `user`: Account creating pool
    /// * `token_metadata`: Pool token details
    /// * `deposit_amounts`: Initial liquidity amounts
    /// * `swap_fee_bps`: Trading fee in basis points
    /// * `amp_factor`: Amplification parameter
    ///
    /// # Process Flow
    /// 1. Validates parameters
    /// 2. Collects initial tokens
    /// 3. Creates pool
    /// 4. Returns LP tokens
    ///
    /// # Aborts
    /// * If amounts don't match tokens
    /// * If user has insufficient balance
    public entry fun create_pool_stable_entry(
        _user: &signer,
        _token_metadata: vector<object::Object<fungible_asset::Metadata>>,
        _deposit_amounts: vector<u64>,
        _swap_fee_bps: u64,
        _amp_factor: u64
    ) {
        abort 0
    }

    /// Creates new weighted pool with initial liquidity
    /// Sets up pool with custom token weights
    ///
    /// # Parameters
    /// * `user`: Account creating pool
    /// * `token_metadata`: Pool token details
    /// * `deposit_amounts`: Initial liquidity amounts
    /// * `pool_weights`: Weight for each token
    /// * `swap_fee_bps`: Trading fee in basis points
    ///
    /// # Process Flow
    /// 1. Validates parameters
    /// 2. Collects initial tokens
    /// 3. Creates weighted pool
    /// 4. Returns LP tokens
    ///
    /// # Aborts
    /// * If amounts don't match tokens
    /// * If user has insufficient balance
    public entry fun create_pool_weighted_entry(
        _user: &signer,
        _token_metadata: vector<object::Object<fungible_asset::Metadata>>,
        _deposit_amounts: vector<u64>,
        _pool_weights: vector<u64>,
        _swap_fee_bps: u64
    )
    {
        abort 0
    }

    /// Remove liquidity from a pool
    ///
    /// # Parameters
    /// * `user`: The signer of the user account removing liquidity
    /// * `pool`: The pool object to remove liquidity from
    /// * `lp_token`: LP token metadata object
    /// * `lp_amount`: Amount of LP tokens to burn
    /// * `min_amounts`: Minimum amounts of tokens to receive
    ///
    /// # Aborts
    /// * If lp_amount is zero
    /// * If user has insufficient LP tokens
    /// * If received amounts are less than minimum amounts
    public entry fun remove_liquidity_entry(
        _user: &signer,
        _pool: object::Object<Pool>,
        _lp_token: object::Object<fungible_asset::Metadata>,
        _lp_amount: u64,
        _min_amounts: vector<u64>
    )
    {
        abort 0
    }

    /// Set amplification factor for a stable pool
    ///
    /// # Parameters
    /// * `admin`: The signer of the admin account
    /// * `pool`: The pool object to modify
    /// * `new_amp_factor`: New amplification factor value
    ///
    /// # Aborts
    /// * If caller is not an admin
    public entry fun set_stable_pool_amp_factor(
        _admin: &signer,
        _pool: object::Object<Pool>,
        _new_amp_factor: u64
    )
    {
        abort 0
    }



    /// Set protocol allocation of swap fees
    ///
    /// # Parameters
    /// * `admin`: The signer of the admin account
    /// * `new_allocation_bps`: New allocation in basis points
    ///
    /// # Aborts
    /// * If caller is not an admin
    /// * If allocation exceeds maximum allowed
    public entry fun set_swap_fee_protocol_allocation_bps(
        _admin: &signer,
        _new_allocation_bps: u64
    )  {
        abort 0
    }

    /// Perform exact input swap in stable pool
    ///
    /// # Parameters
    /// * `trader`: The signer of the trader account
    /// * `pool`: The pool object to swap in
    /// * `token_in`: Input token metadata
    /// * `amount_in`: Amount of input tokens
    /// * `token_out`: Output token metadata
    /// * `min_amount_out`: Minimum amount of output tokens to receive
    ///
    /// # Aborts
    /// * If amount_in is zero
    /// * If trader has insufficient balance
    /// * If output amount is less than min_amount_out
    public entry fun swap_exact_in_stable_entry(
        _trader: &signer,
        _pool: object::Object<Pool>,
        _token_in: object::Object<fungible_asset::Metadata>,
        _amount_in: u64,
        _token_out: object::Object<fungible_asset::Metadata>,
        _min_amount_out: u64
    )
    {
        abort 0
    }

    /// Perform exact input swap in weighted pool
    ///
    /// # Parameters
    /// * `trader`: The signer of the trader account
    /// * `pool`: The pool object to swap in
    /// * `token_in`: Input token metadata
    /// * `amount_in`: Amount of input tokens
    /// * `token_out`: Output token metadata
    /// * `min_amount_out`: Minimum amount of output tokens to receive
    ///
    /// # Aborts
    /// * If amount_in is zero
    /// * If trader has insufficient balance
    /// * If output amount is less than min_amount_out
    public entry fun swap_exact_in_weighted_entry(
        _trader: &signer,
        _pool: object::Object<Pool>,
        _token_in: object::Object<fungible_asset::Metadata>,
        _amount_in: u64,
        _token_out: object::Object<fungible_asset::Metadata>,
        _min_amount_out: u64
    )
    {
        abort 0
    }

    /// Perform exact output swap in stable pool
    ///
    /// # Parameters
    /// * `trader`: The signer of the trader account
    /// * `pool`: The pool object to swap in
    /// * `token_in`: Input token metadata
    /// * `max_amount_in`: Maximum amount of input tokens
    /// * `token_out`: Output token metadata
    /// * `exact_amount_out`: Exact amount of output tokens to receive
    ///
    /// # Aborts
    /// * If exact_amount_out is zero
    /// * If trader has insufficient balance
    public entry fun swap_exact_out_stable_entry(
        _trader: &signer,
        _pool: object::Object<Pool>,
        _token_in: object::Object<fungible_asset::Metadata>,
        _max_amount_in: u64,
        _token_out: object::Object<fungible_asset::Metadata>,
        _exact_amount_out: u64
    )
    {
        abort 0
    }

    /// Perform exact output swap in weighted pool
    ///
    /// # Parameters
    /// * `trader`: The signer of the trader account
    /// * `pool`: The pool object to swap in
    /// * `token_in`: Input token metadata
    /// * `max_amount_in`: Maximum amount of input tokens
    /// * `token_out`: Output token metadata
    /// * `exact_amount_out`: Exact amount of output tokens to receive
    ///
    /// # Aborts
    /// * If exact_amount_out is zero
    /// * If trader has insufficient balance
    public entry fun swap_exact_out_weighted_entry(
        _trader: &signer,
        _pool: object::Object<Pool>,
        _token_in: object::Object<fungible_asset::Metadata>,
        _max_amount_in: u64,
        _token_out: object::Object<fungible_asset::Metadata>,
        _exact_amount_out: u64
    )
    {
        abort 0
    }

}
