pragma solidity ^0.4.23;

contract D {
  uint public n;
  address public sender;

  function callSetN(address _e, uint _n) {
    _e.call(bytes4(keccak256("setN(uint256)")), _n); // E's storage is set, D is not modified 
  }

  function delegatecallSetN(address _e, uint _n) {
    _e.delegatecall(bytes4(sha3("setN(uint256)")), _n); // D's storage is set, E is not modified 
  }
}

contract E {
  uint public n;
  address public sender;

  function setN(uint _n) {
    n = _n;
    sender = msg.sender;
  }
}
