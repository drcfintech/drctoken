pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

interface iContract {
    function transferOwnership(address _newOwner) external;
    function owner() external view returns (address);
}

contract OwnerContract is Ownable {
    iContract public ownedContract;
    address origOwner;

    /**
     * @dev bind a contract as its owner
     *
     * @param _contract the contract address that will be binded by this Owner Contract
     */
    function setContract(address _contract) public onlyOwner {
        require(_contract != address(0));
        ownedContract = iContract(_contract);
        origOwner = ownedContract.owner();
    }

    /**
     * @dev change the owner of the contract from this contract address to the original one. 
     *
     */
    function transferOwnershipBack() public onlyOwner {
        ownedContract.transferOwnership(origOwner);
        ownedContract = iContract(address(0));
        origOwner = address(0);
    }
}