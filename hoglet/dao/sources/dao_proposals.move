module dao_router::dao_proposals {
    use std::string::String;
    use std::vector;

    public entry fun propose_treasury_transfer(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _asset_address: address,
        _recipient: address,
        _amount: u64
    ) {
        abort 0
    }

    public entry fun propose_nft_transfer(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _nft_address: address,
        _recipient: address
    ) {
        abort 0
    }

    public entry fun propose_config_change(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _config_key: u8,
        _config_value: u64
    ) {
        abort 0
    }

    public entry fun propose_guardian_update(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _new_guardian: address
    ) {
        abort 0
    }

    public entry fun propose_gauge_action(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _action_type: u8,
        _target_address: address,
        _gauge_id: u64
    ) {
        abort 0
    }

    public entry fun propose_module_setting(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _setting_type: u8,
        _target_address: address,
        _string_value: String,
        _bool_value: bool
    ) {
        abort 0
    }

    public entry fun propose_boost_action(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _action_type: u8,
        _collection_addr: address,
        _boost_bps: u64
    ) {
        abort 0
    }

    public entry fun propose_script_allow(
        _proposer: &signer,
        _legacy_addr: address,
        _dao_address: address,
        _title: String,
        _description_hash: vector<u8>,
        _script_id: u64,
        _add: bool
    ) {
        abort 0
    }
}
