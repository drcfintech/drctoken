pragma solidity ^0.4.23;


import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './OwnerContract.sol';


/**
 * contract that manage the wallet operations on DRC platform
 */
contract DRCWalletStorage is OwnerContract {
    using SafeMath for uint256;
    
    /**
     * account description
     */
    struct Account {
        string name;
        uint256 balance;
        uint256 frozen;
        // address walletAddr;
    }

    /**
     * Deposit data storage
     */
    // struct DepositRepository {
    //     uint256 balance;
    //     uint256 frozen;
    //     WithdrawWallet[] withdrawWallets;
    //     // mapping (bytes32 => address) withdrawWallets;
    // }

    // mapping (address => DepositRepository) depositRepos;
    mapping (address => Account) accounts;
    mapping (address => bool) public frozenAccount;
    uint256 public size;

    
    /**
	 * @dev add deposit contract address for the default withdraw wallet
     *
     * @param _wallet the default withdraw wallet address
     * @param _name the wallet owner's name
     * @param _value the balance of the wallet need to be stored in this contract
	 */
    function addAccount(address _wallet, string _name, uint256 _value) onlyOwner public returns (bool) {
        require(_wallet != address(0));
        
        accounts[_wallet].balance = _value;
        accounts[_wallet].frozen = 0;
        accounts[_wallet].name = _name;

        size = size.add(1);
        return true;
    }
    
    /**
	 * @dev remove deposit contract address from storage
     *
     * @param _wallet the corresponding deposit address 
	 */
    function removeAccount(address _wallet) onlyOwner public returns (bool) {
        require(_wallet != address(0));
        
        delete accounts[_wallet];
        delete frozenDeposits[_wallet];
        
        size = size.sub(1);
        return true;
    }

    /**
	 * @dev increase balance of this deposit address
     *
     * @param _wallet the corresponding wallet address 
     * @param _value the amount that the balance will be increased
	 */
    function increaseBalance(address _wallet, uint256 _value) public returns (bool) {
        require(_deposit != address(0));
        uint256 _balance = accounts[_wallet].balance;
        accounts[_wallet].balance = _balance.add(_value);
        return true;
    }

    /**
	 * @dev decrease balance of this deposit address
     *
     * @param _wallet the corresponding wallet address 
     * @param _value the amount that the balance will be decreased
	 */
    function decreaseBalance(address _wallet, uint256 _value) public returns (bool) {
        require(_deposit != address(0));
        uint256 _balance = accounts[_wallet].balance;
        accounts[_wallet].balance = _balance.sub(_value);
        return true;
    }

    /**
	 * @dev freeze the tokens in the deposit address
     *
     * @param _wallet the wallet address
     * @param _freeze to freeze or release
     * @param _value the amount of tokens need to be frozen
	 */
    function freezeTokens(address _wallet, bool _freeze, uint256 _value) onlyOwner public returns (bool) {
        require(_wallet != address(0));
        // require(_value <= balanceOf(_deposit));
        
        frozenDeposits[_wallet] = _freeze;
        uint256 _frozen = accounts[_wallet].frozen;
        uint256 _balance = accounts[_wallet].balance;
        uint256 freezeAble = _balance.sub(_frozen);
        if (_freeze) {
            if (_value > freezeAble) {
                _value = freezeAble;
            }
            accounts[_wallet].frozen = _frozen.add(_value);
        } else {
            if (_value > _frozen) {
                _value = _frozen;
            }
            accounts[_wallet].frozen = _frozen.sub(_value);
        }

        return true;
    }

    /**
	 * @dev freeze the tokens in the deposit address
     *
     * @param _wallet the wallet address
     * @param _value the amount of tokens need to be frozen
	 */
    function releaseTokens(address _wallet, uint256 _value) onlyOwner public returns (bool) {
        
    }

    /**
	 * @dev get the balance of the deposit account
     *
     * @param _wallet the wallet address
	 */
    function isExisted(address _wallet) public view returns (bool) {
        require(_wallet != address(0));
        return (accounts[_wallet].balance != 0);
    }

    /**
	 * @dev get the wallet name for the deposit address
     *
     * @param _deposit the deposit address
	 */
    function walletName(address _wallet) onlyOwner public view returns (string) {
        require(_wallet != address(0));
        return accounts[_wallet].name;
    }

    /**
	 * @dev get the balance of the deposit account
     *
     * @param _wallet the deposit address
	 */
    function balanceOf(address _wallet) public view returns (uint256) {
        require(_wallet != address(0));
        return accounts[_wallet].balance;
    }

    /**
	 * @dev get the frozen amount of the deposit address
     *
     * @param _wallet the deposit address
	 */
    function frozenAmount(address _wallet) public view returns (uint256) {
        require(_wallet != address(0));
        return accounts[_wallet].frozen;
    }
}