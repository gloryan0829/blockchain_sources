pragma solidity ^0.4.23;

contract A {
    
    // bug?
    function func1(uint) public pure returns (uint a, uint b) {
        return (3, 4);
    }
    
    function func2(uint _in, uint _in2) public pure returns (uint, uint) {
        return (_in, _in2);
    }
    
}