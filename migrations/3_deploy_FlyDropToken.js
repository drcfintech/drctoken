var FlyDropToken = artifacts.require("FlyDropToken");

module.exports = function(deployer) {  
  deployer.deploy(FlyDropToken, {gas: '5775218', gasPrice: '20000000000'})
  .then(function(instance) {
    console.log(instance);
  });
};