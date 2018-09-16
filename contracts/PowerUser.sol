pragma solidity ^0.4.24;


import "openzeppelin-solidity/contracts/ownership/DelayedClaimable.sol";
import "openzeppelin-solidity/contracts/access/rbac/RBAC.sol";


/**
 * @title Poweruser
 * @dev The Poweruser contract defines a set of power users who can also exexute 
 * the onlyOwner functions, even if he is not the owner.
 * A power user can transfer his role to a new address.
 */
contract Poweruser is DelayedClaimable, RBAC {
  string public constant ROLE_POWERUSER = "poweruser";

  constructor () public {
    addRole(msg.sender, ROLE_POWERUSER);
  }

  /**
   * @dev Throws if called by any account that's not a superuser.
   */
  modifier onlyPoweruser() {
    checkRole(msg.sender, ROLE_POWERUSER);
    _;
  }

  modifier onlyOwnerOrPoweruser() {
    require(msg.sender == owner || isPoweruser(msg.sender));
    _;
  }

  /**
   * @dev getter to determine if address has poweruser role
   */
  function isPoweruser(address _addr)
    public
    view
    returns (bool)
  {
    return hasRole(_addr, ROLE_POWERUSER);
  }

  /**
   * @dev Add a new account address as power user.
   * @param _newSuperuser The address to be as a power user.
   */
  function addPoweruser(address _newPoweruser) public onlyOwner {
    require(_newPoweruser != address(0));
    addRole(_newPoweruser, ROLE_POWERUSER);
  }

  /**
   * @dev Remove a new account address from power user list.
   * @param _oldSuperuser The address to be as a power user.
   */
  function removePoweruser(address _oldPoweruser) public onlyOwner {
    require(_oldPoweruser != address(0));
    removeRole(_oldPoweruser, ROLE_POWERUSER);
  }
}