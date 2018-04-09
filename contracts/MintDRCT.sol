pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './OwnerContract.sol';
import './Autonomy.sol';
import './DRCToken.sol';


contract MintDRCT is OwnerContract, Autonomy {
    using SafeMath for uint256;

    uint256 public TOTAL_SUPPLY_CAP = 1000000000E18;

    address[] internal mainAccounts = [
        0xaD5CcBE3aaB42812aa05921F0513C509A4fb5b67, // tokensale
        0xBD37616a455f1054644c27CC9B348CE18D490D9b, // community
        0x4D9c90Cc719B9bd445cea9234F0d90BaA79ad629, // foundation
        0x21000ec96084D2203C978E38d781C84F497b0edE  // miscellaneous
    ];

    uint8[] internal mainPercentages = [30, 40, 15, 15];

    mapping (address => uint) internal accountCaps;

    /**
     * @dev set capacity limitation for every main accounts
     *
     */    
    function initialCaps() onlyOwner public returns (bool) {
        for (uint i = 0; i < mainAccounts.length; i = i.add(1)) {
            accountCaps[mainAccounts[i]] = TOTAL_SUPPLY_CAP * mainPercentages[i] / 100; 
        }

        return true;
    } 
    
    /**
     * @dev Mint DRC Tokens from one specific wallet addresses
     *
     * @param _ind uint8 the main account index
     * @param _value uint256 the amounts of tokens to be minted
     */
    function mintUnderCap(uint _ind, uint256 _value) onlyOwner public returns (bool) {
        require(_ind < mainAccounts.length);
        address accountAddr = mainAccounts[_ind];
        uint256 accountBalance = DRCToken(ownedContract).balanceOf(accountAddr);
        require(_value <= accountCaps[accountAddr].sub(accountBalance));

        return DRCToken(ownedContract).mint(accountAddr, _value);
    }

    /**
     * @dev Mint DRC Tokens from serveral specific wallet addresses
     *
     * @param _values uint256 the amounts of tokens to be minted
     */
    function mintAll(uint256[] _values) onlyOwner public returns (bool) {
        require(_values.length == mainAccounts.length);

        bool res = true;
        for(uint i = 0; i < _values.length; i.add(1)) {
            res = mintUnderCap(i, _values[i]) && res;
        }
         
        return res;
    }

    /**
     * @dev Mint DRC Tokens from serveral specific wallet addresses upto cap limitation
     *
     */
    function mintUptoCap() onlyOwner public returns (bool) {
        bool res = true;
        for(uint i = 0; i < mainAccounts.length; i.add(1)) {
            require(DRCToken(ownedContract).balanceOf(mainAccounts[i]) == 0);
            res = DRCToken(ownedContract).mint(mainAccounts[i], accountCaps[mainAccounts[i]]) && res;
        }
         
        return res;
    }

    /**
     * @dev raise the supply capacity of one specific wallet addresses
     *
     * @param _ind uint the main account index
     * @param _value uint256 the amounts of tokens to be added to capacity limitation
     */
    function raiseCap(uint _ind, uint256 _value) onlyCongress public returns (bool) {
        require(_ind < mainAccounts.length);
        require(_value > 0);

        accountCaps[mainAccounts[_ind]] = accountCaps[mainAccounts[_ind]].add(_value);
        return true;
    }
    
    /**
     * @dev query the main account address of one type
     *
     * @param _ind the index of the main account
     */
    function getMainAccount(uint _ind) public view returns (address) {
        require(_ind < mainAccounts.length);
        return mainAccounts[_ind];
    }
    
    /**
     * @dev query the supply capacity of one type of main account
     *
     * @param _ind the index of the main account
     */
    function getAccountCap(uint _ind) public view returns (uint256) {
        require(_ind < mainAccounts.length);
        return accountCaps[mainAccounts[_ind]];
    }

    /**
     * @dev set one type of main account to another address
     *
     * @param _ind the main account index
     * @param _newAddr address the new main account address
     */
    function setMainAccount(uint _ind, address _newAddr) public returns (bool) {
        require(_ind < mainAccounts.length);
        require(_newAddr != address(0));

        mainAccounts[_ind] = _newAddr;
        return true;
    }
}