module hoglet_hodl::hodl_fa {
    use std::option::Option;
    use std::string::String;
    use supra_framework::fungible_asset::FungibleAsset;
    use aptos_token::token::Token;

    struct PoolIdentifier has copy, drop, store {
        creator_addr: address,
        stake_addr: address,
        reward_addr: address,
    }

    struct NFTBoostConfig has copy, drop, store {
        boost_percent: u128,
        collection_owner: address,
        collection_name: String,
    }

    public fun create_boost_config(
        _collection_owner: address,
        _collection_name: String,
        _boost_percent: u128
    ): NFTBoostConfig {
        abort 0
    }

    public fun register_pool(
        _caller: &signer,
        _stake_addr: address,
        _reward_addr: address,
        _initial_reward_amount: u64,
        _duration: u64,
        _nft_boost_config: Option<NFTBoostConfig>
    ) {
        abort 0
    }

    public fun register_hodl_pool(
        _caller: &signer,
        _stake_addr: address,
        _reward_addr: address,
        _unstake_period_seconds: u64,
        _nft_boost_config: Option<NFTBoostConfig>
    ) {
        abort 0
    }

    public fun stake(
        _user: &signer,
        _pool_key: PoolIdentifier,
        _stake_amount: u64
    ) {
        abort 0
    }

    public fun unstake(
        _user: &signer,
        _pool_key: PoolIdentifier,
        _amount: u64
    ): FungibleAsset {
        abort 0
    }

    public fun deposit_and_stake_for_beneficiary(
        _caller_signer: &signer,
        _pool_key: PoolIdentifier,
        _beneficiary_addr: address,
        _stake_asset: FungibleAsset
    ) {
        abort 0
    }

    public fun harvest(
        _user: &signer,
        _pool_key: PoolIdentifier
    ): (u64, FungibleAsset) {
        abort 0
    }

    public fun boost(
        _user: &signer,
        _pool_key: PoolIdentifier,
        _nft: Token
    ) {
        abort 0
    }

    public fun remove_boost(
        _user: &signer,
        _pool_key: PoolIdentifier
    ): Token {
        abort 0
    }

    public fun remove_boost_many(
        _user: &signer,
        _pool_keys: vector<PoolIdentifier>
    ) {
        abort 0
    }

    public fun finalize_hodl_pool_rewards(
        _caller_signer: &signer,
        _pool_key: PoolIdentifier,
        _total_reward_amount: u64
    ) {
        abort 0
    }

    public fun enable_emergency(
        _admin: &signer,
        _pool_key: PoolIdentifier
    ) {
        abort 0
    }

    public fun disable_emergency(
        _admin: &signer,
        _pool_key: PoolIdentifier
    ) {
        abort 0
    }

    public fun unstake_many(
        _user: &signer,
        _pool_keys: vector<PoolIdentifier>
    ) {
        abort 0
    }

    public fun harvest_many(
        _user: &signer,
        _pool_keys: vector<PoolIdentifier>
    ) {
        abort 0
    }

    public fun emergency_unstake(
        _user: &signer,
        _pool_key: PoolIdentifier
    ): (u64, Option<FungibleAsset>, Option<Token>) {
        abort 0
    }

    public fun withdraw_to_treasury(
        _treasury_signer: &signer,
        _pool_key: PoolIdentifier,
        _amount: u64
    ): FungibleAsset {
        abort 0
    }

    public fun get_start_timestamp(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): u64 {
        abort 0
    }

    public fun is_boostable(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): bool {
        abort 0
    }

    public fun get_boost_config(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): (address, String, u128) {
        abort 0
    }

    public fun is_finished(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): bool {
        abort 0
    }

    public fun get_end_timestamp(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): u64 {
        abort 0
    }

    public fun get_unlocked_stake_amount(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address,
        _user_addr: address
    ): u64 {
        abort 0
    }

    public fun pool_exists(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): bool {
        abort 0
    }

    public fun stake_exists(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address,
        _user_addr: address
    ): bool {
        abort 0
    }

    public fun get_pool_total_stake(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): u64 {
        abort 0
    }

    public fun get_pool_total_boosted(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): u128 {
        abort 0
    }

    public fun get_user_stake_or_zero(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address,
        _user_addr: address
    ): u64 {
        abort 0
    }

    public fun is_boosted(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address,
        _user_addr: address
    ): bool {
        abort 0
    }

    public fun get_user_boosted(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address,
        _user_addr: address
    ): u128 {
        abort 0
    }

    public fun get_pending_user_rewards(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address,
        _user_addr: address
    ): u64 {
        abort 0
    }

    public fun is_emergency(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): bool {
        abort 0
    }

    public fun is_local_emergency(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address
    ): bool {
        abort 0
    }

    public fun get_module_resource_address(): address {
        abort 0
    }

    #[view]
    public fun new_pool_identifier(
        creator_addr: address,
        stake_addr: address,
        reward_addr: address
    ): PoolIdentifier {
        PoolIdentifier {
            creator_addr,
            stake_addr,
            reward_addr,
        }
    }

    public fun get_user_staked_pools(_user_addr: address): vector<PoolIdentifier> {
        abort 0
    }

    public fun get_user_boosted_pools(_user_addr: address): vector<PoolIdentifier> {
        abort 0
    }

    public fun get_user_stake_details(
        _pool_creator_addr: address,
        _stake_addr: address,
        _reward_addr: address,
        _user_addr: address
    ): (u64, u64, u64, u64, u128) {
        abort 0
    }

    public fun is_hodl_period_finished(
        _resource_addr: address,
        _pool_key: PoolIdentifier
    ): bool {
        abort 0
    }
}
