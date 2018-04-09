var DRCToken = artifacts.require("DRCToken");

module.exports = function(deployer) {  
  deployer.deploy(DRCToken);
};