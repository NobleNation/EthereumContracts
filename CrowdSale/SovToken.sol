pragma solidity ^0.4.18;

import './ERC20.sol';

contract SovToken is CappedToken 
{
  string public name = "Sovereign";
  string public symbol = "SVT";
  uint256 public decimals = 18;

  uint256 private _tradeableDate = now;
  address private _convertAddress = address(0);
  address private _internalPool = address(0);
  
  uint constant TIME_UNIT = 86400;
  uint256 constant START_TIME = 1519128000;
  uint constant TOTAL_TIME = 91;
  uint256 constant HARD_CAP = 100000;
  
  event Burn(address indexed burner, uint256 value);

  function SovToken() CappedToken(HARD_CAP)
  {
    _tradeableDate = START_TIME + (TIME_UNIT * TOTAL_TIME);
    _convertAddress = 0x9376B2Ff3E68Be533bAD507D99aaDAe7180A8175;
    _internalPool = 0xD642d610B5EEF8aAaC0605302F2933b834124aFA;
  }
  
  function transfer(address _to, uint256 _value) public returns (bool) 
  {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // reject transaction if the transfer is before tradeable date and
    // the transfer is not from or to the pool
    if (now < _tradeableDate && (_to != _internalPool || msg.sender != _internalPool))
     return false;

    // if the transfer address is the conversion address - burn the tokens
    if (_to == _convertAddress)
    {   
      address burner = msg.sender;
      balances[burner] = balances[burner].sub(_value);
      totalSupply_ = totalSupply_.sub(_value);
      Burn(burner, _value);
      Transfer(msg.sender, _to, _value);
      return true;
    }
    else
    {
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }
  }
}
