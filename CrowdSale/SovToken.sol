pragma solidity ^0.4.18;

import './ERC20.sol';

contract SovToken is MintableToken {
  string public name = "SOVTOKEN";
  string public symbol = "SVT";
  uint256 public decimals = 18;

  uint256 private tradeableDate = now;
  address private convertAddress = address(0);
  address private internalPool = address(0);
}
