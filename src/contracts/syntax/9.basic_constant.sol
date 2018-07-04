pragma solidity ^0.4.23;

contract constantContract {
    uint constant x = 10**10 + 10;
    string constant text = "abc";
    bytes32 constant hashedString = keccak256("abc");
    
    function a() public pure returns (uint, string, bytes32) {
        // text = "3"; assigned constant value.....during compilation...
        return (x, text, hashedString);
    }
}