pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';
import 'zeppelin-solidity/contracts/ownership/Claimable.sol';
import './Autonomy.sol';
// import 'zeppelin-solidity/contracts/token/SafeERC20.sol';

interface tokenRecipient { 
    function receiveApproval(
        address _from, 
        uint256 _value,
        address _token, 
        bytes _extraData
    ) external; 
}

contract DRCToken is BurnableToken, MintableToken, PausableToken, Claimable, Autonomy {    
    string public name = "DRC Token";
    string public symbol = "DRCT";
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 0;

    // add map for recording the accounts that will not be allowed to transfer tokens
    mapping (address => bool) public frozenAccount;
    // record the amount of tokens that have been frozen
    mapping (address => uint256) public frozenAmount;
    event FrozenFunds(address indexed _target, bool _frozen);
    event FrozenFundsPartialy(address indexed _target, bool _frozen, uint256 _value);

    event BurnFrom(address from, address burner, uint256 value);

    /**
     * contruct the token by total amount 
     *
     * initial balance is set. 
     */
    function DRCToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
    
    /**
     * @dev freeze the account's balance 
     *
     * by default all the accounts will not be frozen until set freeze value as true. 
     * 
     * @param _target address the account should be frozen
     * @param _freeze bool if true, the account will be frozen
     */
    function freezeAccount(address _target, bool _freeze) onlyOwner public {
        require(_target != address(0));

        frozenAccount[_target] = _freeze;
        FrozenFunds(_target, _freeze);
    }

    /**
     * @dev freeze the account's balance 
     * 
     * @param _target address the account should be frozen
     * @param _value uint256 the amount of tokens that will be frozen
     */
    function freezeAccountPartialy(address _target, uint256 _value) onlyOwner public {
        require(_target != address(0));
        require(_value <= balances[_target]);

        frozenAccount[_target] = true;
        frozenAmount[_target] = _value;
        FrozenFundsPartialy(_target, true, _value);
    }

    /**
     * @dev transfer token for a specified address with froze status checking
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(_to != address(0));
        require(!frozenAccount[msg.sender] || (_value <= balances[msg.sender].sub(frozenAmount[msg.sender])));

        return super.transfer(_to, _value);
    }
  
    /**
     * @dev Transfer tokens from one address to another with checking the frozen status
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(_from != address(0));
        require(_to != address(0));
        require(!frozenAccount[_from] || (_value <= balances[_from].sub(frozenAmount[_from])));

        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev transfer token for a specified address with froze status checking
     * @param _toMulti The addresses to transfer to.
     * @param _values The array of the amount to be transferred.
     */
    // function transferMultiAddress(address[] _toMulti, uint256[] _values) public whenNotPaused returns (bool) {
    //     require(!frozenAccount[msg.sender]);
    //     assert(_toMulti.length == _values.length);

    //     uint256 i = 0;
    //     while (i < _toMulti.length) {
    //         require(_toMulti[i] != address(0));
    //         require(_values[i] <= balances[msg.sender]);

    //         // SafeMath.sub will throw if there is not enough balance.
    //         balances[msg.sender] = balances[msg.sender].sub(_values[i]);
    //         balances[_toMulti[i]] = balances[_toMulti[i]].add(_values[i]);
    //         Transfer(msg.sender, _toMulti[i], _values[i]);

    //         i = i.add(1);
    //     }

    //     return true;
    // }

    /**
     * @dev Transfer tokens from one address to another with checking the frozen status
     * @param _from address The address which you want to send tokens from
     * @param _toMulti address[] The addresses which you want to transfer to in boundle
     * @param _values uint256[] the array of amount of tokens to be transferred
     */
    // function transferMultiAddressFrom(address _from, address[] _toMulti, uint256[] _values) public whenNotPaused returns (bool) {
    //     require(!frozenAccount[_from]);
    //     assert(_toMulti.length == _values.length);
    
    //     uint256 i = 0;
    //     while ( i < _toMulti.length) {
    //         require(_toMulti[i] != address(0));
    //         require(_values[i] <= balances[_from]);
    //         require(_values[i] <= allowed[_from][msg.sender]);

    //         // SafeMath.sub will throw if there is not enough balance.
    //         balances[_from] = balances[_from].sub(_values[i]);
    //         balances[_toMulti[i]] = balances[_toMulti[i]].add(_values[i]);
    //         allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_values[i]);
    //         Transfer(_from, _toMulti[i], _values[i]);

    //         i = i.add(1);
    //     }

    //     return true;
    // }
  
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) whenNotPaused public {
        super.burn(_value);
    }

    /**
     * @dev Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public whenNotPaused returns (bool success) {
        require(_from != address(0));
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
        totalSupply_ = totalSupply_.sub(_value);
        BurnFrom(msg.sender, _from, _value);
        return true;
    }

    /**
     * @dev Destroy tokens from other account by force, only a congress contract can call this function
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function forceBurnFrom(address _from, uint256 _value) onlyCongress whenNotPaused public returns (bool success) {
        require(_from != address(0));
        require(balances[_from] >= _value);                // Check if the targeted balance is enough        
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance
        totalSupply_ = totalSupply_.sub(_value);
        BurnFrom(msg.sender, _from, _value);
        return true;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint whenNotPaused public returns (bool) {
        require(_to != address(0));
        return super.mint(_to, _amount);
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint whenNotPaused public returns (bool) {
        return super.finishMinting();
    }

    /**
     * @dev Function to restart minting functionality. Only congress contract can do this. 
     * @return True if the operation was successful.
     */
    function restartMint() onlyCongress whenNotPaused public returns (bool) {
        mintingFinished = false;
        return true;
    }
    
    /**
     * @dev Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public whenNotPaused returns (bool success) {
        require(_spender != address(0));

        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}

