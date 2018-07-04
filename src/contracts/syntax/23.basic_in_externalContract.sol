pragma solidity ^0.4.23;

// general external Contract Call Example..
contract InfoProvider {
    function info() public payable returns (uint) {
        return 100;
    }
    
} 

contract InfoConsumer {
    InfoProvider ip;
    
    function setInfoProvider(address addr) public {
        ip = InfoProvider(addr);
    }
    
    function callInfo() public view returns (uint) {
        return ip.info.value(msg.value)(); 
    }
    
    // internal call recursive
    function factorial(uint n) public returns (uint) {
        if (n <= 1)
            return 1;
        else
            return n * factorial(n-1);
    }
}
