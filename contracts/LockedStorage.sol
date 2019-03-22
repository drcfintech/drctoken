pragma solidity ^ 0.4.23;


import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Claimable.sol";
import "./Withdrawable.sol";


/**
 * contract that manage the wallet operations on DRC platform
 */
contract LockedStorage is Withdrawable, Claimable {
  using SafeMath for uint256;

  /**
   * account description
   */
  struct Account {
    string name;
    uint256 balance;
    uint256 frozen;
  }

  // record lock time period and related token amount
  struct TimeRec {
    uint256 amount;
    uint256 remain;
    uint256 endTime;
    uint256 releasePeriodEndTime;
  }

  mapping(address => Account) accounts;
  mapping(address => bool) public frozenAccounts;
  address[] accountAddresses;
  mapping(address => TimeRec[]) frozenTimes;

  uint256 public size;


  /**
   * @dev add deposit contract address for the default withdraw wallet
   *
   * @param _wallet the default withdraw wallet address
   * @param _name the wallet owner's name
   * @param _value the balance of the wallet need to be stored in this contract
   */
  function addAccount(address _wallet, string _name, uint256 _value) onlyOwner public returns(bool) {
    require(_wallet != address(0));

    accounts[_wallet].balance = _value;
    accounts[_wallet].frozen = 0;
    accounts[_wallet].name = _name;

    accountAddresses.push(_wallet);
    size = size.add(1);
    return true;
  }

  /**
   * @dev remove an address from the account address list
   *
   * @param _wallet the account address in the list
   */
  function removeAccountAddress(address _wallet) internal returns(bool) {
    uint i = 0;
    for (; i < accountAddresses.length; i = i.add(1)) {
      if (accountAddresses[i] == _wallet) {
        break;
      }
    }

    if (i >= accountAddresses.length) {
      return false;
    }

    while (i < accountAddresses.length.sub(1)) {
      accountAddresses[i] = accountAddresses[i.add(1)];
      i = i.add(1);
    }

    delete accountAddresses[accountAddresses.length.sub(1)];
    accountAddresses.length = accountAddresses.length.sub(1);
    return true;
  }

  /**
   * @dev remove deposit contract address from storage
   *
   * @param _wallet the corresponding deposit address 
   */
  function removeAccount(address _wallet) onlyOwner public returns(bool) {
    require(_wallet != address(0));

    delete accounts[_wallet];
    delete frozenAccounts[_wallet];
    removeAccountAddress(_wallet);

    size = size.sub(1);
    return true;
  }

  /**
   * @dev add a time record of one account
   *
   * @param _target the account that holds a list of time records which record the freeze period     
   * @param _value the amount of the tokens
   * @param _frozenEndTime the end time of the lock period, unit is second
   * @param _releasePeriod the locking period, unit is second
   */
  function addLockedTime(address _target,
    uint256 _value,
    uint256 _frozenEndTime,
    uint256 _releasePeriod) public onlyOwner returns(bool) {
    require(_target != address(0));

    TimeRec[] storage lockedTimes = frozenTimes[_target];
    lockedTimes.push(TimeRec(_value, _value, _frozenEndTime, _frozenEndTime.add(_releasePeriod)));

    return true;
  }

  /**
   * @dev remove a time records from the time records list of one account
   *
   * @param _target the account that holds a list of time records which record the freeze period
   * @param _ind the account address index
   */
  function removeLockedTime(address _target, uint _ind) public returns(bool) {
    require(_target != address(0));

    TimeRec[] storage lockedTimes = frozenTimes[_target];
    require(_ind < lockedTimes.length);

    uint256 i = _ind;
    while (i < lockedTimes.length.sub(1)) {
      lockedTimes[i] = lockedTimes[i.add(1)];
      i = i.add(1);
    }

    delete lockedTimes[lockedTimes.length.sub(1)];
    lockedTimes.length = lockedTimes.length.sub(1);
    return true;
  }

  /**
   * @dev increase balance of this deposit address
   *
   * @param _wallet the corresponding wallet address 
   * @param _value the amount that the balance will be increased
   */
  function increaseBalance(address _wallet, uint256 _value) public returns(bool) {
    require(_wallet != address(0));
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
  function decreaseBalance(address _wallet, uint256 _value) public returns(bool) {
    require(_wallet != address(0));
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
  function freezeTokens(address _wallet, bool _freeze, uint256 _value) onlyOwner public returns(bool) {
    require(_wallet != address(0));
    // require(_value <= balanceOf(_deposit));

    frozenAccounts[_wallet] = _freeze;
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
   * @dev get the balance of the deposit account
   *
   * @param _wallet the wallet address
   */
  function isExisted(address _wallet) public view returns(bool) {
    require(_wallet != address(0));
    return (accounts[_wallet].balance != 0);
  }

  /**
   * @dev get the wallet name for the deposit address
   *
   * @param _wallet the deposit address
   */
  function walletName(address _wallet) onlyOwner public view returns(string) {
    require(_wallet != address(0));
    return accounts[_wallet].name;
  }

  /**
   * @dev get the balance of the deposit account
   *
   * @param _wallet the deposit address
   */
  function balanceOf(address _wallet) public view returns(uint256) {
    require(_wallet != address(0));
    return accounts[_wallet].balance;
  }

  /**
   * @dev get the frozen amount of the deposit address
   *
   * @param _wallet the deposit address
   */
  function frozenAmount(address _wallet) public view returns(uint256) {
    require(_wallet != address(0));
    return accounts[_wallet].frozen;
  }

  /**
   * @dev get the account address by index
   *
   * @param _ind the account address index
   */
  function addressByIndex(uint256 _ind) public view returns(address) {
    return accountAddresses[_ind];
  }

  /**
   * @dev set the new endtime of the released time of an account
   *
   * @param _target the owner of some amount of tokens
   * @param _ind the stage index of the locked stage
   * @param _newEndTime the new endtime for the lock period
   */
  function changeEndTime(address _target, uint256 _ind, uint256 _newEndTime) onlyOwner public returns(bool) {
    require(_target != address(0));
    require(_newEndTime > 0);

    if (isExisted(_target)) {
      TimeRec storage timePair = frozenTimes[_target][_ind];
      timePair.endTime = _newEndTime;

      return true;
    }

    return false;
  }

  /**
   * @dev set the new released period end time of an account
   *
   * @param _target the owner of some amount of tokens
   * @param _ind the stage index of the locked stage
   * @param _newReleaseEndTime the new endtime for the releasing period
   */
  function setNewReleaseEndTime(address _target, uint256 _ind, uint256 _newReleaseEndTime) onlyOwner public returns(bool) {
    require(_target != address(0));
    require(_newReleaseEndTime > 0);

    if (isExisted(_target)) {
      TimeRec storage timePair = frozenTimes[_target][_ind];
      timePair.releasePeriodEndTime = _newReleaseEndTime;

      return true;
    }

    return false;
  }

  /**
   * @dev decrease the remaining locked amount of an account
   *
   * @param _target the owner of some amount of tokens
   * @param _ind the stage index of the locked stage
   */
  function decreaseRemainLockedOf(address _target, uint256 _ind, uint256 _value) onlyOwner public returns(bool) {
    require(_target != address(0));

    if (isExisted(_target)) {
      TimeRec storage timePair = frozenTimes[_target][_ind];
      timePair.remain = timePair.remain.sub(_value);

      return true;
    }

    return false;
  }

  /**
   * @dev get the locked stages of an account
   *
   * @param _target the owner of some amount of tokens
   */
  function lockedStagesNum(address _target) public view returns(uint) {
    require(_target != address(0));
    return (isExisted(_target) ? frozenTimes[_target].length : 0);
  }

  /**
   * @dev get the endtime of the locked stages of an account
   *
   * @param _target the owner of some amount of tokens
   * @param _ind the stage index of the locked stage
   */
  function endTimeOfStage(address _target, uint _ind) public view returns(uint256) {
    require(_target != address(0));

    if (isExisted(_target)) {
      TimeRec memory timePair = frozenTimes[_target][_ind];
      return timePair.endTime;
    }

    return 0;
  }

  /**
   * @dev get the remain unrleased tokens of the locked stages of an account
   *
   * @param _target the owner of some amount of tokens
   * @param _ind the stage index of the locked stage
   */
  function remainOfStage(address _target, uint _ind) public view returns(uint256) {
    require(_target != address(0));

    if (isExisted(_target)) {
      TimeRec memory timePair = frozenTimes[_target][_ind];
      return timePair.remain;
    }

    return 0;
  }

  /**
   * @dev get the remain unrleased tokens of the locked stages of an account
   *
   * @param _target the owner of some amount of tokens
   * @param _ind the stage index of the locked stage
   */
  function amountOfStage(address _target, uint _ind) public view returns(uint256) {
    require(_target != address(0));

    if (isExisted(_target)) {
      TimeRec memory timePair = frozenTimes[_target][_ind];
      return timePair.amount;
    }

    return 0;
  }

  /**
   * @dev get the remain releasing period end time of an account
   *
   * @param _target the owner of some amount of tokens
   * @param _ind the stage index of the locked stage
   */
  function releaseEndTimeOfStage(address _target, uint _ind) public view returns(uint256) {
    require(_target != address(0));

    if (isExisted(_target)) {
      TimeRec memory timePair = frozenTimes[_target][_ind];
      return timePair.releasePeriodEndTime;
    }

    return 0;
  }
}