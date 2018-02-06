pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/PausableToken.sol';
// import 'zeppelin-solidity/contracts/token/SafeERC20.sol';

interface tokenRecipient { 
    function receiveApproval(
        address _from, 
        uint256 _value,
        address _token, 
        bytes _extraData
    ) public; 
}

contract DRCTestToken is BurnableToken, MintableToken, PausableToken {    
    string public name = 'DRC Test Token 1';
    string public symbol = 'DRC1';
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 1000000000000000000000000000;

    // add map for recording the accounts that will not be allowed to transfer tokens
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);

    /**
     * contruct the token by total amount 
     *
     * initial balance is set. 
     */
    function DRCTestToken() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply;
    }
    
    /**
     * freeze the account's balance 
     *
     * by default all the accounts will not be frozen until set freeze value as true. 
     */
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

  /**
   * @dev transfer token for a specified address with froze status checking
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(!frozenAccount[msg.sender]);
    return super.transfer(_to, _value);
  }
  
  /**
   * @dev Transfer tokens from one address to another with checking the frozen status
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(!frozenAccount[_from]);
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev transfer token for a specified address with froze status checking
   * @param _toMulti The addresses to transfer to.
   * @param _values The array of the amount to be transferred.
   */
  function transferMultiAddress(address[] _toMulti, uint256[] _values) public returns (bool) {
    require(!frozenAccount[msg.sender]);
    uint256 i = 0;
    while ( i < _toMulti.length) {
        require(_toMulti[i] != address(0));
        require(_values[i] <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_values[i]);
        balances[_toMulti[i]] = balances[_toMulti[i]].add(_values[i]);
        Transfer(msg.sender, _toMulti[i], _values[i]);
    }

    return true;
  }

  /**
   * @dev Transfer tokens from one address to another with checking the frozen status
   * @param _from address The address which you want to send tokens from
   * @param _toMulti address[] The addresses which you want to transfer to in boundle
   * @param _values uint256[] the array of amount of tokens to be transferred
   */
  function transferMultiAddressFrom(address _from, address[] _toMulti, uint256[] _values) public returns (bool) {
    require(!frozenAccount[_from]);
    
    uint256 i = 0;
    while ( i < _toMulti.length) {
        require(_toMulti[i] != address(0));
        require(_values[i] <= balances[_from]);
        require(_values[i] <= allowed[_from][msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[_from] = balances[_from].sub(_values[i]);
        balances[_toMulti[i]] = balances[_toMulti[i]].add(_values[i]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_values[i]);
        Transfer(_from, _toMulti[i], _values[i]);
    }

    return true;
  }
  
    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
        return true;
    }
    
    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}

