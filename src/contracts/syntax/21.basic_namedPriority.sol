pragma solidity ^0.4.0;

contract C {    
    function f(uint _key, uint _val) public {}    
    
    function g() public {        
        f({_val: 2, _key: 3}); 
        f(2, 3);
    }
}
