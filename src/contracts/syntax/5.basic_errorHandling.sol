pragma solidity ^0.4.23;

contract A {
    
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function func1(uint _a) public view returns (uint) {
        require(msg.sender == owner, "this msg.sender is not available..");
        return _a;
    }
    
    function func2(uint _a) public view returns (uint) {
        assert(msg.sender == owner);
        return _a;
    }
    
    function func3(uint _a) public view returns (uint) {
        if (msg.sender != owner)
            revert("this msg.sender is not available...");
        
        return _a;
    }
    
} // Look at the source of SafeMath made by OpenZeppelin

