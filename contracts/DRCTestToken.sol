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
    string public name = 'DRC Test Token';
    string public symbol = 'DRCT';
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 150000000;
    uint public SECOND_SUPPLY = 400000000;
    uint public THIRD_SUPPLY = 550000000;

    /**
     * contruct the token by total amount 
     *
     * there are 3 phases for releasing the tokens, initial balance is set. 
     */
    function DRCTestToken() public {
        totalSupply = INITIAL_SUPPLY + SECOND_SUPPLY + THIRD_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    /**
     * start the second release phase 
     *
     * the second phase will use second supply amount of tokens 
     */
    function startSecondPhase() public {
        balances[msg.sender] = balances[msg.sender].add(SECOND_SUPPLY);
    }

    /**
     * start the third release phase 
     *
     * the third phase will use third supply amount of tokens 
     */
    function startThirdPhase() public {
        balances[msg.sender] = balances[msg.sender].add(THIRD_SUPPLY);
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

