pragma solidity ^0.4.23;


/**
 * contract which define the interface of DRCWalletsStorage contract, which store 
 * the deposit and withdraw wallets data
 */
interface ILockedStorage {
    // get frozen status for the _wallet address
    function frozenAccounts(address _wallet) external view returns (bool); 

    // get a wallet address by the account address and the index
    function isExisted(address _wallet) external view returns (bool); 

    // get a wallet name by the account address and the index
    function walletName(address _wallet) external view returns (string); 

    // get the frozen amount of the account address
    function frozenAmount(address _wallet) external view returns (uint256);

    // get the balance of the account address
    function balanceOf(address _wallet) external view returns (uint256);

    // get the account address by index
    function addressByIndex(uint256 _ind) external view returns (address); 

    // get the number of the locked stage of the target address
    function lockedStagesNum(address _target) external view returns (uint256);

    // get the endtime of the locked stages of an account     
    function endTimeOfStage(address _target, uint _ind) external view returns (uint256);

    // get the remain unrleased tokens of the locked stages of an account     
    function remainOfStage(address _target, uint _ind) external view returns (uint256);
    
    // get the remain unrleased tokens of the locked stages of an account  
    function amountOfStage(address _target, uint _ind) external view returns (uint256);

    // get the remain releasing period end time of an account
    function releaseEndTimeOfStage(address _target, uint _ind) external view returns (uint256);

    // get the frozen amount of the account address
    function size() external view returns (uint256);

    // add one account address for that wallet
    function addAccount(address _wallet, string _name, uint256 _value) external returns (bool); 

    // add a time record of one account
    function addLockedTime(address _target, 
                           uint256 _value, 
                           uint256 _frozenEndTime, 
                           uint256 _releasePeriod) external returns (bool);

    // freeze or release the tokens that has been locked in the account address.
    function freezeTokens(address _wallet, bool _freeze, uint256 _value) external returns (bool);

    // increase balance of this account address
    function increaseBalance(address _wallet, uint256 _value) external returns (bool);

    // decrease balance of this account address
    function decreaseBalance(address _wallet, uint256 _value) external returns (bool);

    // remove account contract address from storage
    function removeAccount(address _wallet) external returns (bool);

    // remove a time records from the time records list of one account
    function removeLockedTime(address _target, uint _ind) external returns (bool);

    // set the new endtime of the released time of an account
    function changeEndTime(address _target, uint256 _ind, uint256 _newEndTime) external returns (bool);

    // set the new released period end time of an account
    function setNewReleaseEndTime(address _target, uint256 _ind, uint256 _newReleaseEndTime) external returns (bool);

    // decrease the remaining locked amount of an account
    function decreaseRemainLockedOf(address _target, uint256 _ind, uint256 _value) external returns (bool);

    // withdraw tokens from this contract
    function withdrawToken(address _token, address _to, uint256 _value) external returns (bool);
}