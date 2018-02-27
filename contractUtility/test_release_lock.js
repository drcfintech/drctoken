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
};

var releaselockInstance = loadContract(abi_file_release_lock_contract, release_lock_contract_address);
var drctokenInstance = loadContract(abi_file_drc_token, drc_token_contract_address);

var drctokenOrigOwner = "0xAe995911A6E29342a115DFC354501F3465017c4E";
var drctokenOwner = drctokenInstance.owner.call();
if (drctokenOwner != release_lock_contract_address) {
	drctokenInstance.transferOwnership(release_lock_contract_address, {from: drctokenOwner});
}

// freeze test accounts
var test_accounts = ["0xf17f52151EbEF6C7334FAD080c5704D77216b732", 
					 "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef", 
					 "0x821aEa9a577a9b44299B9c15c88cf3087F3b5544", 
					 "0x0d1d4e623D10F9FBA5Db95830F7d3839406C6AF2",
					 "0x2932b7A2355D6fecc4b5c0B6BD44cC31df247a2e",
					 "0x2191eF87E392377ec08E7c08Eb105Ef5448eCED5",
					 "0x0F4F2Ac550A1b4e2280d04c21cEa7EBD822934b5",
					 "0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc",
					 "0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE",
					 "0x69e1CB5cFcA8A311586e3406ed0301C06fb839a2",
					 "0xF014343BDFFbED8660A9d8721deC985126f189F3",
					 "0x0E79EDbD6A727CfeE09A2b1d0A59F7752d5bf7C9"];

var release_lock_data = [[500000, (new Date(2018, 2, 27, 1, 0, 0)).getTime(), 0],
						 [200000, (new Date(2018, 2, 27, 1, 5, 17)).getTime(), 600],
						 [300000, (new Date(2018, 2, 27, 1, 10, 0)).getTime(), 0],
						 [100000, (new Date(2018, 2, 27, 1, 12, 10)).getTime(), 600],
						 [600000, (new Date(2018, 2, 27, 1, 20, 0)).getTime(), 0],
						 [700000, (new Date(2018, 2, 27, 1, 8, 8)).getTime(), 600],
						 [3500000, (new Date(2018, 2, 27, 1, 10, 0)).getTime(), 0],
						 [50000, (new Date(2018, 2, 27, 1, 18, 25)).getTime(), 600],
						 [5000000, (new Date(2018, 2, 27, 1, 15, 0)).getTime(), 0],
						 [250000, (new Date(2018, 2, 27, 1, 10, 12)).getTime(), 600],
						 [470000, (new Date(2018, 2, 27, 1, 17, 46)).getTime(), 600],
						 [6230000, (new Date(2018, 2, 27, 1, 22, 0)).getTime(), 0]];

var release_lock_data_2 = [[500000, (new Date(2018, 2, 27, 0, 50, 0)).getTime(), 900],
						   [200000, (new Date(2018, 2, 27, 1, 10, 17)).getTime(), 600],
						   [300000, (new Date(2018, 2, 27, 1, 10, 0)).getTime(), 0],
						   [100000, (new Date(2018, 2, 27, 1, 17, 10)).getTime(), 600],
						   [600000, (new Date(2018, 2, 27, 1, 15, 0)).getTime(), 900],
						   [700000, (new Date(2018, 2, 27, 1, 12, 8)).getTime(), 0],
						   [350000, (new Date(2018, 2, 27, 1, 10, 0)).getTime(), 0],
						   [500000, (new Date(2018, 2, 27, 1, 24, 25)).getTime(), 600],
						   [500000, (new Date(2018, 2, 27, 1, 15, 0)).getTime(), 0],
						   [250000, (new Date(2018, 2, 27, 1, 15, 12)).getTime(), 600],
						   [470000, (new Date(2018, 2, 27, 1, 25, 46)).getTime(), 600],
						   [623000, (new Date(2018, 2, 27, 1, 22, 0)).getTime(), 0]];

var release_lock_data_3 = [[500000, (new Date(2018, 2, 27, 1, 10, 0)).getTime(), 0],
						   [200000, (new Date(2018, 2, 27, 1, 15, 17)).getTime(), 600],
						   [300000, (new Date(2018, 2, 27, 1, 15, 0)).getTime(), 0],
						   [100000, (new Date(2018, 2, 27, 1, 22, 10)).getTime(), 600],
						   [600000, (new Date(2018, 2, 27, 1, 20, 0)).getTime(), 900],
						   [700000, (new Date(2018, 2, 27, 1, 10, 8)).getTime(), 600],
						   [350000, (new Date(2018, 2, 27, 1, 13, 0)).getTime(), 600],
						   [500000, (new Date(2018, 2, 27, 1, 30, 25)).getTime(), 0],
						   [500000, (new Date(2018, 2, 27, 1, 20, 0)).getTime(), 0],
						   [250000, (new Date(2018, 2, 27, 1, 20, 12)).getTime(), 900],
						   [470000, (new Date(2018, 2, 27, 1, 28, 46)).getTime(), 0],
						   [623000, (new Date(2018, 2, 27, 1, 27, 0)).getTime(), 600]];

var sleep = require('system-sleep');
var releaselockOwner = releaselockInstance.owner.call();

var len = release_lock_data.length;
for (var i = 0; i < len; i++) {
	releaselockInstance.freeze(
		drctokenInstance.address, 
		test_accounts[i], 
		release_lock_data[i][0],
		release_lock_data[i][1],
		release_lock_data[i][2],
		{from: releaselockOwner, gasPrice: '3000000000'}
	);
	sleep(5000);

	drctokenInstance.transferFrom(
		drctokenOrigOwner, 
		test_accounts[i], 
		release_lock_data[i][0], 
		{from: releaselockOwner, gasPrice: '3000000000'});
	sleep(5000);
	
	releaselockInstance.freeze(
		drctokenInstance.address, 
		test_accounts[i], 
		release_lock_data_2[i][0],
		release_lock_data_2[i][1],
		release_lock_data_2[i][2],
		{from: releaselockOwner, gasPrice: '3000000000'}
	);
	sleep(5000);

	drctokenInstance.transferFrom(
		drctokenOrigOwner,
		test_accounts[i], 
		release_lock_data_2[i][0],
		{from: releaselockOwner, gasPrice: '3000000000'}
	);
	sleep(5000);

	releaselockInstance.freeze(
		drctokenInstance.address, 
		test_accounts[i], 
		release_lock_data_3[i][0],
		release_lock_data_3[i][1],
		release_lock_data_3[i][2],
		{from: releaselockOwner, gasPrice: '3000000000'}
	);
	sleep(5000);

	drctokenInstance.transfer(
		drctokenOrigOwner,
		test_accounts[i], 
		release_lock_data_3[i][0],
		{from: releaselockOwner, gasPrice: '3000000000'}
	);
	sleep(5000);

	var totalNeedApprove = release_lock_data[i][0] + release_lock_data_2[i][0] + release_lock_data_3[i][0];
	drctokenInstance.approve(releaselockInstance.address, totalNeedApprove);
}


