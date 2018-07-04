pragma solidity ^0.4.16;

contract viewpureContract {
    
    uint c = 1;
    
    function f(uint a, uint b) public view returns (uint) {
        return a + b + c + 1 days;
    }
    
    function d(uint a, uint b) public pure returns (uint) {
        return a + b + 1 weeks;
    }
    
}