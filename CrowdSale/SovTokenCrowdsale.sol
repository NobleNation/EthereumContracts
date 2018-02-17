ragma solidity ^0.4.18;

import './SovToken.sol';
import './Crowdsale.sol';

contract SovTokenCrowdsale is Crowdsale {
  //address of internal pool
  address private internalPool = address(0);
  address private convertAddress = address(0);
  uint constant TIME_UNIT = 60;    // in seconds - set at 60 (1 min) for testing and change to 86400 (1 day) for release

}
