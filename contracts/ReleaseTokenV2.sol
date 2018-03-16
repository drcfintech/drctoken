pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './ReleaseToken.sol';


contract ReleaseTokenV2 is ReleaseToken {
    mapping (address => uint256) oldBalances;
    mapping (address => address) public releaseAddrs;
    
   
    /**
     * @dev set the new endtime of the released time of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _oldEndTime the original endtime for the lock period
     * @param _newEndTime the new endtime for the lock period
     */
    function setNewEndtime(address _target, uint256 _oldEndTime, uint256 _newEndTime) public returns (bool) {
        require(_target != address(0));
        require(_oldEndTime > 0 && _newEndTime > 0);

        uint256 len = frozenAccounts.length;
        uint256 i = 0;
        while (i < len) {
            address frozenAddr = frozenAccounts[i];
            if (frozenAddr == _target) {
                uint256 timeRecLen = frozenTimes[frozenAddr].length;
                uint256 j = 0;
                while (j < timeRecLen) {
                    TimeRec storage timePair = frozenTimes[frozenAddr][j];
                    if (_oldEndTime == timePair.endTime) {
                        uint256 duration = timePair.releasePeriodEndTime.sub(timePair.endTime);
                        timePair.endTime = _newEndTime;
                        timePair.releasePeriodEndTime = timePair.endTime.add(duration);                        
                        
                        return true;
                    }

                    j = j.add(1);
                }

                return false;
            }

            i = i.add(1);
        }

        return false;
    }

    /**
     * @dev set the new released period length of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _origEndTime the original endtime for the lock period
     * @param _duration the new releasing period
     */
    function setNewReleasePeriod(address _target, uint256 _origEndTime, uint256 _duration) public returns (bool) {
        require(_target != address(0));
        require(_origEndTime > 0 && _duration > 0);

        uint256 len = frozenAccounts.length;
        uint256 i = 0;
        while (i < len) {
            address frozenAddr = frozenAccounts[i];
            if (frozenAddr == _target) {
                uint256 timeRecLen = frozenTimes[frozenAddr].length;
                uint256 j = 0;
                while (j < timeRecLen) {
                    TimeRec storage timePair = frozenTimes[frozenAddr][j];
                    if (_origEndTime == timePair.endTime) {
                        timePair.releasePeriodEndTime = _origEndTime.add(_duration);
                        return true;
                    }

                    j = j.add(1);
                }

                return false;
            }

            i = i.add(1);
        }

        return false;
    }

    /**
     * @dev set the new released period length of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _releaseTo the address that will receive the released tokens
     */
    function setReleasedAddress(address _target, address _releaseTo) public {
        require(_target != address(0));
        require(_releaseTo != address(0));

        releaseAddrs[_target] = _releaseTo;
    }

    /**
     * @dev get the locked stages of an account
     *
     * @param _target the owner of some amount of tokens
     */
    function getLockedStages(address _target) public view returns (uint) {
        require(_target != address(0));

        uint256 len = frozenAccounts.length;
        uint256 i = 0;
        while (i < len) {
            address frozenAddr = frozenAccounts[i];
            if (frozenAddr == _target) {
                return frozenTimes[frozenAddr].length;               
            }

            i = i.add(1);
        }

        return 0;
    }

    /**
     * @dev get the endtime of the locked stages of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _num the stage number of the releasing period
     */
    function getEndTimeOfStage(address _target, uint _num) public view returns (uint256) {
        require(_target != address(0));

        uint256 len = frozenAccounts.length;
        uint256 i = 0;
        while (i < len) {
            address frozenAddr = frozenAccounts[i];
            if (frozenAddr == _target) {
                TimeRec storage timePair = frozenTimes[frozenAddr][_num];                
                return timePair.endTime;               
            }

            i = i.add(1);
        }

        return 0;
    }

    /**
     * @dev get the remain unrleased tokens of the locked stages of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _num the stage number of the releasing period
     */
    function getRemainOfStage(address _target, uint _num) public view returns (uint256) {
        require(_target != address(0));

        uint256 len = frozenAccounts.length;
        uint256 i = 0;
        while (i < len) {
            address frozenAddr = frozenAccounts[i];
            if (frozenAddr == _target) {
                TimeRec storage timePair = frozenTimes[frozenAddr][_num];                
                return timePair.remain;               
            }

            i = i.add(1);
        }

        return 0;
    }

    /**
     * @dev get the remain releasing period of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _num the stage number of the releasing period
     */
    function getRemainReleaseTimeOfStage(address _target, uint _num) public view returns (uint256) {
        require(_target != address(0));

        uint256 len = frozenAccounts.length;
        uint256 i = 0;
        while (i < len) {
            address frozenAddr = frozenAccounts[i];
            if (frozenAddr == _target) {
                TimeRec storage timePair = frozenTimes[frozenAddr][_num];  
                if (timePair.releasePeriodEndTime == timePair.endTime || now <= timePair.endTime ) {
                    return (timePair.releasePeriodEndTime.sub(timePair.endTime));
                }    

                if (timePair.releasePeriodEndTime < now) {
                    return 0;
                }

                return (timePair.releasePeriodEndTime.sub(now));               
            }

            i = i.add(1);
        }

        return 0;
    }

    /**
     * @dev get the remain original tokens belong to an account before this time locking
     *
     * @param _target the owner of some amount of tokens
     */
    function gatherOldBalanceOf(address _target) public returns (uint256) {
        require(_target != address(0));
        require(frozenTimes[_target].length == 0); // no freeze action on this address

        // store the original balance if this the new freeze
        uint256 origBalance = owned.balanceOf(_target);
        if (origBalance > 0) {
            oldBalances[_target] = origBalance;
        }

        return origBalance;
    }

    /**
     * @dev get all the remain original tokens belong to a serial of accounts before this time locking
     *
     * @param _targets the owner of some amount of tokens
     */
    function gatherAllOldBalanceOf(address[] _targets) public returns (uint256) {
        require(_targets.length != 0);
        
        uint256 res = 0;
        for (uint256 i = 0; i < _targets.length; i = i.add(1)) {
            require(_targets[i] != address(0));
            res = res.add(gatherOldBalanceOf(_targets[i]));
        }

        return res;
    }
    
    /**
     * @dev freeze the amount of tokens of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _value the amount of the tokens
     * @param _frozenEndTime the end time of the lock period, unit is second
     * @param _releasePeriod the locking period, unit is second
     */
    function freeze(address _target, uint256 _value, uint256 _frozenEndTime, uint256 _releasePeriod) onlyOwner public returns (bool) {
        if (frozenTimes[_target].length == 0) {
            gatherOldBalanceOf(_target);
        }
        return super.freeze(_target, _value, _frozenEndTime, _releasePeriod);
    }    

    /**
     * @dev release the locked tokens owned by an account, which are the tokens
     * that belong to this account before being locked.
     * this need the releasing-to address has already been set.
     *
     * @param _target the account address that hold an amount of locked tokens
     */
    function releaseOldBalanceOf(address _target) onlyOwner public returns (bool) {
        require(_target != address(0));
        require(releaseAddrs[_target] != address(0));

        // check firstly that the allowance of this contract from _target account has been set
        assert(owned.allowance(_target, this) > 0);

        // we got some amount need to be released
        if (oldBalances[_target] > 0) {
            bool freezeStatus = owned.frozenAccount(_target);
            owned.freezeAccount(_target, false);
            if (!owned.transferFrom(_target, releaseAddrs[_target], oldBalances[_target])) {
                return false;
            }

            // in this situation, the account should be still in original locked status
            owned.freezeAccount(_target, freezeStatus);
        }

        return true;
    }    

    /**
     * @dev release the locked tokens owned by an account with several stages
     * this need the contract get approval from the account by call approve() in the token contract
     * and also need the releasing-to address has already been set.
     *
     * @param _target the account address that hold an amount of locked tokens
     */
    function releaseByStage(address _target) onlyOwner public returns (bool) {
        require(_target != address(0));

        return releaseWithStage(_target, releaseAddrs[_target]);
    }    
}