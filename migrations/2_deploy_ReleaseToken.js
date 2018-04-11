var ReleaseToken = artifacts.require("ReleaseToken");

module.exports = function(deployer) {  
  deployer.deploy(ReleaseToken, {gas: '5775218', gasPrice: '4000000000'})
  .then(function(instance) {
    console.log(instance);
  });
};