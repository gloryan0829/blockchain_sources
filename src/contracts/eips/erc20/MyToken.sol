pragma solidity ^0.4.24;

import "./StandardToken.sol";


contract MyToken is StandardToken {

  string public constant name = "GameToken"; // solium-disable-line uppercase
  string public constant symbol = "GTK"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 1e10 * (10 ** uint256(decimals));

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
}
