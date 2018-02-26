#!/usr/bin/env node

'use strict';

var Web3 = require("web3");
var http_url = process.argv[2];
var provider = new Web3.providers.HttpProvider(http_url); //http rpc provider
var web3 = new Web3(provider);

var read_file = require("fs");
var abi_file_release_lock_contract = process.argv[3];
var abi_file_drc_token = process.argv[4];
var release_lock_contract_address = "0x5bE3f0f1A759291DbdC5C550F6FF97Aa5113bEC3";
var drc_token_contract_address = "0x022196D0670320B211db5A1b1Da4e775A2FB40e6";

var loadContract = function (abi_file_name, address) {
	  var abi_data = read_file.readFileSync(abi_file_name, "utf-8"); //read abi data file
	  console.log(abi_data);

	  var myContract = web3.eth.contract(abi_data);
	  var myContractInstance = myContract.at(address);

	  return myContractInstance;
}

var releaselockInstance = loadContract(abi_file_release_lock_contract, release_lock_contract_address);
var drctokenInstance = loadContract(abi_file_drc_token, drc_token_contract_address);

var drctokenOwner = drctokenInstance.owner.call();
if (drctokenOwner != release_lock_contract_address) {
}
