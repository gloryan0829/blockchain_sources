pragma solidity ^0.4.23;

// http://solidity.readthedocs.io/en/v0.4.24/miscellaneous.html#order
contract A {
    
    function func1() public pure returns (uint) {
        return 1+2<<4**3%3;
    }
    
    function func2() public pure returns (uint) {
        return (1+2)<<((4**3)%3);
    }
}