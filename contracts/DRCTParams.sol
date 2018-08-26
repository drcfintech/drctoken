pragma solidity ^0.4.23;


import 'openzeppelin-solidity/contracts/ownership/Claimable.sol';
import './Autonomy.sol';


/**
 * contract that define the wallet management parameters on DRC platform
 * only owner could initialize the parameters, but the congress contract 
 * could set the parameters in the future
 */
contract DRCWalletMgrParams is Claimable, Autonomy {
    uint256 public reMintCap; // max value of reMint up limit
    uint256 public onceMintRate; // Max value of once minting


    function initialReMintCap(uint256 _value) onlyOwner public {
        require(!init);

        reMintCap = _value;
    }

    function initialOnceMintAmount(uint256 _value) onlyOwner public {
        require(!init);

        onceMintRate = _value;
    }

    function setReMintCap(uint256 _value) onlyCongress public {
        reMintCap = _value;
    }   

    function setOnceMintAmount(uint256 _value) onlyCongress public {
        onceMintRate = _value;
    }
}