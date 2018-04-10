var MintDRCT = artifacts.require("MintDRCT");

module.exports = function(deployer) {  
  deployer.deploy(MintDRCT, {gas: '5775218', gasPrice: '20000000000'})
  .then(function(instance) {
    console.log(instance);
  });
};