module hoglet_wrap_v1_to_da::nft_wrapper {
    use std::string::String;
    use supra_framework::object::Object;
    use aptos_token_objects::token::Token as TokenV2;
    use aptos_token::token::Token as TokenV1;

    #[view]
    public fun get_wrapped_collection_address(
        _creator: address,
        _collection_name: String
    ): address {
        abort 0
    }

    public fun wrap_v1_to_da(
        _user: &signer,
        _v1_token: TokenV1
    ): Object<TokenV2> {
        abort 0
    }

    public fun unwrap_da_to_v1(
        _user: &signer,
        _v2_token: Object<TokenV2>
    ): TokenV1 {
        abort 0
    }

    #[view]
    public fun is_wrapped(_v2_token_addr: address): bool {
        abort 0
    }
}
