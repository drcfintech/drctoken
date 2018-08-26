pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './OwnerContract.sol';
import './ReleaseToken.sol';


contract AuthorizedReleaseToken is ReleaseToken {
    /**
     * @dev freeze the amount of tokens of an account
     *
     * @param _target the owner of some amount of tokens
     * @param _value the amount of the tokens
     * @param _frozenEndTime the end time of the lock period, unit is second
     * @param _releasePeriod the locking period, unit is second
     */
    function freeze(address _target, uint256 _value, uint256 _frozenEndTime, uint256 _releasePeriod) onlyOwner public returns (bool) {
        require(allowance(_target, this) >= _value);
        super.freeze(_target, _value, _frozenEndTime, _releasePeriod);
    }
}