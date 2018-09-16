pragma solidity ^0.4.18;

import 'openzeppelin-solidity/contracts/ownership/Claimable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';



/**
 * @title transfer tokens to multi addresses
 */
contract SimpleFlyDropToken is Claimable {
    using SafeMath for uint256;

    ERC20 internal erc20tk;    

    function setToken(address _token) onlyOwner public {
        require(_token != address(0));
        erc20tk = ERC20(_token);
    }

    /**
     * @dev Send tokens to other multi addresses in one function
     *
     * @param _destAddrs address The addresses which you want to send tokens to
     * @param _values uint256 the amounts of tokens to be sent
     */
    function multiSend(address[] _destAddrs, uint256[] _values) onlyOwner public returns (uint256) {
        require(_destAddrs.length == _values.length);
        
        uint256 i = 0;
        for (; i < _destAddrs.length; i = i.add(1)) {            
            if (!erc20tk.transfer(_destAddrs[i], _values[i])) {
                break;
            }
        }

        return (i);
    }
}
