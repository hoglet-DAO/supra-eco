// SPDX-License-Identifier: MIT
// Solido Protocol - Interface for fa_adapter
module SOLIDO::fa_adapter {
    use std::signer;
    use std::vector;
    use std::string::String;
    use std::option::Option;
    use aptos_std::type_info::TypeInfo;
    use aptos_std::table::Table;
    use supra_framework::object::Object;
    use supra_framework::fungible_asset::{Metadata, FungibleAsset};
    use supra_framework::coin::{Coin, MintCapability, BurnCapability, FreezeCapability};
    use supra_framework::account;

    public(friend) fun address_from_metadata(arg0: supra_framework::object::Object<supra_framework::fungible_asset::Metadata>): address {
        abort 0
    }

    public(friend) fun amount_fa(arg0: &supra_framework::fungible_asset::FungibleAsset): u64 {
        abort 0
    }

    public(friend) fun balance_fa(arg0: address, arg1: supra_framework::object::Object<supra_framework::fungible_asset::Metadata>): u64 {
        abort 0
    }

    public(friend) fun deposit_fa(arg0: address, arg1: supra_framework::fungible_asset::FungibleAsset) {
        abort 0
    }

    public(friend) fun ensure_fa_store(arg0: address, arg1: supra_framework::object::Object<supra_framework::fungible_asset::Metadata>): supra_framework::object::Object<0x1::fungible_asset::FungibleStore> {
        abort 0
    }

    public(friend) fun get_paired_metadata<T0>(): supra_framework::object::Object<supra_framework::fungible_asset::Metadata> {
        abort 0
    }

    public(friend) fun has_fa_store(arg0: address, arg1: supra_framework::object::Object<supra_framework::fungible_asset::Metadata>): bool {
        abort 0
    }

    #[view]
    public fun is_fa_paired<T0>(): bool {
        abort 0
    }

    public(friend) fun metadata_from_address(arg0: address): supra_framework::object::Object<supra_framework::fungible_asset::Metadata> {
        abort 0
    }

    public(friend) fun metadata_from_asset(arg0: &supra_framework::fungible_asset::FungibleAsset): supra_framework::object::Object<supra_framework::fungible_asset::Metadata> {
        abort 0
    }

    public(friend) fun transfer_fa(arg0: &signer, arg1: supra_framework::object::Object<supra_framework::fungible_asset::Metadata>, arg2: address, arg3: u64) {
        abort 0
    }

    public(friend) fun withdraw_fa(arg0: &signer, arg1: supra_framework::object::Object<supra_framework::fungible_asset::Metadata>, arg2: u64): supra_framework::fungible_asset::FungibleAsset {
        abort 0
    }

}