pragma solidity ^0.4.19;

contract FallbackContract {
    uint public x;    
    
    function() public {
        x = 1;
    }
    
    function a() public {
        x = 2;
    }
}

contract FallbackWithPayableContract {
    
    uint public x;
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function() public payable {
        
    }
    
    function a(uint _a) {
        x = _a;
    }

    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
}

contract CallerContract {
    
    constructor() payable {
        
    }
    
    function callFunc1(FallbackContract fc) public returns (bool) {
        return fc.call(bytes4(keccak256("a()")));
    }
    
    function callFunc2(FallbackWithPayableContract fpc, uint _a) public {
       fpc.call(bytes4(keccak256("a(uint)")), _a);
       fpc.send(1 ether);
    }
}