pragma solidity ^0.4.13;

// import 'zeppelin-solidity/contracts/ownership/DelayedClaimable.sol';
import './MultiOwners.sol';

// interface iContract {
//     function transferOwnership(address _newOwner) external;
//     function owner() external view returns (address);
// }

contract MultiOwnerContract is MultiOwners {
    Claimable public ownedContract;
    address public pendingOwnedOwner;
    // address internal origOwner;

    string public constant AUTH_CHANGEOWNEDOWNER = "transferOwnerOfOwnedContract";

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    // modifier onlyPendingOwnedOwner() {
    //     require(msg.sender == pendingOwnedOwner);
    //     _;
    // }

    /**
     * @dev bind a contract as its owner
     *
     * @param _contract the contract address that will be binded by this Owner Contract
     */
    function bindContract(address _contract) onlyOwner public returns (bool) {
        require(_contract != address(0));
        ownedContract = Claimable(_contract);
        // origOwner = ownedContract.owner();

        // take ownership of the owned contract
        ownedContract.claimOwnership();

        return true;
    }

    /**
     * @dev change the owner of the contract from this contract address to the original one. 
     *
     */
    // function transferOwnershipBack() onlyOwner public {
    //     ownedContract.transferOwnership(origOwner);
    //     ownedContract = Claimable(address(0));
    //     origOwner = address(0);
    // }

    /**
     * @dev change the owner of the contract from this contract address to another one. 
     *
     * @param _nextOwner the contract address that will be next Owner of the original Contract
     */
    function changeOwnedOwnershipto(address _nextOwner) onlyMultiOwners public {
        require(ownedContract != address(0));
        require(hasAuth(AUTH_CHANGEOWNEDOWNER));

        if (ownedContract.owner() != pendingOwnedOwner) {
            ownedContract.transferOwnership(_nextOwner);
            pendingOwnedOwner = _nextOwner;
            // ownedContract = Claimable(address(0));
            // origOwner = address(0);
        } else {
            // the pending owner has already taken the ownership
            ownedContract = Claimable(address(0));
            pendingOwnedOwner = address(0);
        }

        clearAuth(AUTH_CHANGEOWNEDOWNER);
    }

    function ownedOwnershipTransferred() onlyOwner public returns (bool) {
        require(ownedContract != address(0));
        if (ownedContract.owner() == pendingOwnedOwner) {
            // the pending owner has already taken the ownership  
            ownedContract = Claimable(address(0));
            pendingOwnedOwner = address(0);
            return true;
        } else {
            return false;
        }
    } 

}