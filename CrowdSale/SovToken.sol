pragma solidity ^0.4.18;

import './ERC20.sol';

contract SovToken is MintableToken {
  string public name = "SOVEREIGN";
  string public symbol = "SVT";
  uint256 public decimals = 18;

  uint256 private _tradeableDate = now;
  
  //please update the following addresses before deployment
  address private constant CONVERT_ADDRESS = address(0); 
  address private constant POOL = address(0);
  
  event Burn(address indexed burner, uint256 value);

  function SovToken(uint256 tradeDate) public
  {
    _tradeableDate = tradeDate;
  }

  function transfer(address _to, uint256 _value) public returns (bool) 
  {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    
    // reject transaction if the transfer is before tradeable date and
    // the transfer is not from or to the pool
    if (now < _tradeableDate && (_to != POOL || msg.sender != POOL))
        return false;
    
    // if the transfer address is the conversion address - burn the tokens
    if (_to == CONVERT_ADDRESS)
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
