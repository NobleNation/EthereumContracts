pragma solidity ^0.4.18;

import './SovToken.sol';
import './Crowdsale.sol';

contract SovTokenCrowdsale is Crowdsale {
  uint private constant TIME_UNIT = 86400;    // in seconds - set at 60 (1 min) for testing and change to 86400 (1 day) for release
  uint private constant TOTAL_TIME = 91;
  uint private constant RATE = 1000;
  uint256 private constant START_TIME = 1519128000;
  uint256 private constant HARD_CAP = 100000000*1000000000000000000;    // in wei - 100K Eth
  
  //please update the following addresses before deployment
  address private constant WALLET = address(0);
  address private constant POOL = address(0);

  function SovTokenCrowdsale() public
        Crowdsale(START_TIME, START_TIME + (TIME_UNIT * TOTAL_TIME), RATE, WALLET, new SovToken(START_TIME + (TIME_UNIT * TOTAL_TIME)))
  {    }
  
  // low level token purchase function
  function buyTokens(address beneficiary) public payable 
  {
    require(beneficiary != address(0));
    require(validPurchase());
    
    uint256 weiAmount = msg.value;

    // validate if hardcap reached
    require(weiRaised.add(weiAmount) < HARD_CAP);

    // calculate token amount to be created
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    // for every token given away, half a token is minted to the treasury pool
    token.mint(POOL, tokens/2);

    forwardFunds();
  }

  // Overriden to calculate bonuses
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) 
  {
    uint256 tokens =  weiAmount.mul(rate);
    uint256 bonus = 100;

    // determine bonus according to pre-sale period age
    if (now >= endTime)
      bonus = 0;
    else if (now <= startTime + (7 * TIME_UNIT))
      bonus += 75;
    else if (now <= startTime + (14 * TIME_UNIT))
      bonus += 65;
    else if (now <= startTime + (21 * TIME_UNIT))
      bonus += 55;
    else if (now <= startTime + (28 * TIME_UNIT))
      bonus += 45;
    else if (now <= startTime + (39 * TIME_UNIT))
      bonus += 35;
    else if (now <= startTime + (70 * TIME_UNIT))
      bonus = 0;
    else if (now <= startTime + (77 * TIME_UNIT))
      bonus += 10;
    else if (now <= startTime + (84 * TIME_UNIT))
      bonus += 5;
    else
      bonus = 100;

    tokens = tokens * bonus / 100;

    bonus = 100;
    
    //determine applicable amount bonus
    // 1 - 10 ETH 10%, >10 ETH 20%
    if (weiAmount >= 1000000000000000000 && weiAmount < 10000000000000000000)
      bonus += 10;
    else if (weiAmount >= 10000000000000000000)
      bonus += 20;

    tokens = tokens * bonus / 100;
      
    return tokens;
  }  
  
  
  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) 
  {
      bool isPreSale = now >= startTime && now <= startTime + (39 * TIME_UNIT);
      bool isIco = now > startTime + (70 * TIME_UNIT) && now <= endTime;
      bool withinPeriod = isPreSale || isIco;
      bool nonZeroPurchase = msg.value != 0;
      return withinPeriod && nonZeroPurchase;
  }
}

