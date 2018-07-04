pragma solidity ^0.4.23;

contract Dog {
    function say() public returns (string); // declare header
}

contract Jindo is Dog {
    function say() public returns (string) { // declare header + body
        return "walwal!";
    }    
}