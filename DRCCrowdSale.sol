pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol';
import './DRCTestToken.sol';


interface myToken {
    function transfer(address receiver, uint amount) public returns (bool);
}

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract DRCCrowdsale is RefundableCrowdsale {
  using SafeMath for uint256;

  uint256 public cap;
  
  // The token being sold
  myToken public tokenToSale;

  function DRCCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super._processPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}
