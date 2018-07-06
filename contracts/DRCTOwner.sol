pragma solidity ^0.4.23;

// import 'zeppelin-solidity/contracts/ownership/DelayedClaimable.sol';
import './OwnerContract.sol';


interface itoken {
    function freezeAccount(address _target, bool _freeze) external;
    function freezeAccountPartialy(address _target, uint256 _value) external;
    function balanceOf(address _owner) external view returns (uint256 balance);
    // function transferOwnership(address newOwner) external;
    function allowance(address _owner, address _spender) external view returns (uint256);
    function initialCongress(address _congress) external;
    function mint(address _to, uint256 _amount) external returns (bool);
    function finishMinting() external returns (bool);
    function pause() external;
    function unpause() external;
}

contract DRCTOwner is OwnerContract {
    string public constant AUTH_INITCONGRESS = "initCongress";
    string public constant AUTH_CANMINT = "canMint";

    bool congressInit = true;

    /**
     * @dev change the owner of the contract from this contract address to another one. 
     *
     * @param _congress the contract address that will be next Owner of the original Contract
     */
    function initCongress(address _congress) onlyMultiOwners public {
        require(hasAuth(AUTH_INITCONGRESS));        
        require(congressInit);

        itoken tk = itoken(address(ownedContract));
        tk.initialCongress(_congress);

        clearAuth(AUTH_INITCONGRESS);
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyMultiOwners public returns (bool) {
        require(hasAuth(AUTH_CANMINT)); 

        itoken tk = itoken(address(ownedContract));
        bool res = tk.mint(_to, _amount);

        clearAuth(AUTH_CANMINT);
        return res;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyMultiOwners public returns (bool) {
        require(hasAuth(AUTH_CANMINT)); 

        itoken tk = itoken(address(ownedContract));
        bool res = tk.finishMinting();

        clearAuth(AUTH_CANMINT);
        return res;
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
        itoken tk = itoken(address(ownedContract));        
        if (_freeze) {
            require(tk.allowance(_target, this) == tk.balanceOf(_target));
        }

        tk.freezeAccount(_target, _freeze);
    }

    /**
     * @dev freeze the account's balance 
     * 
     * @param _target address the account should be frozen
     * @param _value uint256 the amount of tokens that will be frozen
     */
    function freezeAccountPartialy(address _target, uint256 _value) onlyOwner public {
        require(_target != address(0));
        itoken tk = itoken(address(ownedContract)); 
        require(tk.allowance(_target, this) == _value);

        tk.freezeAccountPartialy(_target, _value);
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner public {        
        itoken tk = itoken(address(ownedContract));
        tk.pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner public {     
        itoken tk = itoken(address(ownedContract));
        tk.unpause();
    }

}