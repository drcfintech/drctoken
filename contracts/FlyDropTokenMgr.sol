pragma solidity ^0.4.18;


import "zeppelin-solidity/contracts/ownership/DelayedClaimable.sol";
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './FlyDropToken.sol';


interface itoken {    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool);
}


/**
 * @title manage transfer tokens to multi addresses
 */
contract FlyDropTokenMgr is DelayedClaimable {    
    using SafeMath for uint256;

    address[] dropTokenAddrs;
    FlyDropToken currentDropTokenContract;
    // mapping(address => mapping (address => uint256)) budgets;

    /**
     * @dev Send tokens to other multi addresses in one function
     *
     * @param _rand a random index for choosing a FlyDropToken contract address
     * @param _from address The address which you want to send tokens from
     * @param _value uint256 the amounts of tokens to be sent
     * @param _token address the ERC20 token address
     * @param _extraData bytes the extra data for the record
     */
    function prepare(uint256 _rand, 
                     address _from, 
                     address _token, 
                     uint256 _value,
                     bytes _extraData) onlyOwner public returns (bool) {
        require(_token != address(0));
        require(_from != address(0));
        require(_rand > 0);

        if (ERC20(_token).allowance(_from, this) < _value) {
            return false;
        }

        if (_rand > dropTokenAddrs.length) {
            FlyDropToken dropTokenContract = new FlyDropToken();
            dropTokenAddrs.push(address(dropTokenContract));
            currentDropTokenContract = dropTokenContract;
        } else {
            currentDropTokenContract = FlyDropToken(dropTokenAddrs[_rand.sub(1)]);
        }

        ERC20(_token).transferFrom(_from, this, _value);
        // budgets[_token][_from] = budgets[_token][_from].sub(_value);
        return itoken(_token).approveAndCall(currentDropTokenContract, _value, _extraData);
        // return true;
    } 

    // function setBudget(address _token, address _from, uint256 _value) onlyOwner public {
    //     require(_token != address(0));
    //     require(_from != address(0));

    //     budgets[_token][_from] = _value;
    // }

    /**
     * @dev Send tokens to other multi addresses in one function
     *
     * @param _destAddrs address The addresses which you want to send tokens to
     * @param _values uint256 the amounts of tokens to be sent
     */
    function flyDrop(address[] _destAddrs, uint256[] _values) onlyOwner public returns (uint256) {
        require(address(currentDropTokenContract) != address(0));
        return currentDropTokenContract.multiSend(_destAddrs, _values);
    }

}