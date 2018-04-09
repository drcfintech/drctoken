pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Claimable.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

// interface itoken {
//     function balanceOf(address _owner) public view returns (uint256 balance)
//     function allowance(address _owner, address _spender) external view returns (uint256);
//     function transfer(address _to, uint256 _value) external returns (bool);
//     function transferFrom(address _from, address _to, uint256 _values) external returns (bool);
// }

contract FlyDropToken is Claimable {
    using SafeMath for uint256;

    struct ApproveRecord {
        uint256 value;
        bytes info;
    }

    ERC20 internal erc20tk;
    mapping (address => ApproveRecord) internal AccountRecords;

    event ReceiveApproval(address _from, uint256 _value, address _token, bytes _extraData);

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
        erc20tk = ERC20(_token);
        AccountRecords[_from] = ApproveRecord(_value, _extraData);
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
}