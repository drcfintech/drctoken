
pragma solidity ^0.4.24;



/**
 * @title manage transfer tokens to multi addresses
 */
interface IFlyDropTokenMgr {
    // Send tokens to other multi addresses in one function
    function prepare(uint256 _rand, 
                     address _from, 
                     address _token, 
                     uint256 _value) external returns (bool);

    // Send tokens to other multi addresses in one function
    function flyDrop(address[] _destAddrs, uint256[] _values) external returns (uint256);

    // getter to determine if address has poweruser role
    function isPoweruser(address _addr) external view returns (bool);
}