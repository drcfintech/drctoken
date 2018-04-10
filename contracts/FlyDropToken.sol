pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

import 'zeppelin-solidity/contracts/ownership/Claimable.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';


/**
 * @title transfer tokens to multi addresses
 */
contract FlyDropToken is Claimable {
    using SafeMath for uint256;

    struct ApproveRecord {
        uint256 value;
        bytes info;
    }

    ERC20 internal erc20tk;
    mapping (address => ApproveRecord) internal accountRecords;

    event ReceiveApproval(address _from, uint256 _value, address _token, bytes _extraData);

    /**
     * @dev receive approval from an ERC20 token contract, take a record
     *
     * @param _from address The address which you want to send tokens from
     * @param _value uint256 the amounts of tokens to be sent
     * @param _token address the ERC20 token address
     * @param _extraData bytes the extra data for the record
     */
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
        erc20tk = ERC20(_token);
        require(erc20tk.transferFrom(_from, this, _value)); // transfer tokens to this contract        
        accountRecords[_from] = ApproveRecord(_value, _extraData);
        ReceiveApproval(_from, _value, _token, _extraData);
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
    
    /**
     * @dev Send tokens to other multi addresses in one function
     *
     * @param _from address The address which you want to send tokens from
     * @param _destAddrs address The addresses which you want to send tokens to
     * @param _values uint256 the amounts of tokens to be sent
     */
    function multiSendFrom(address _from, address[] _destAddrs, uint256[] _values) onlyOwner public returns (uint256) {
        require(_destAddrs.length == _values.length);
        
        uint256 i = 0;
        for (; i < _destAddrs.length; i = i.add(1)) {            
            if (!erc20tk.transferFrom(_from, _destAddrs[i], _values[i])) {
                break;
            }
        }

        return (i);
    }

    /**
     * @dev get records about approval
     *
     * @param _destAddrs address The addresses which you want to send tokens to
     * @param _values uint256 the amounts of tokens to be sent
     */
    function multiSend(address _approver) onlyOwner public returns (ApproveRecord) {
        require(_approver != address(0));
        
        return accountRecords[_approver];
    }
}