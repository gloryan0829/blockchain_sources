pragma solidity ^0.4.16;
pragma experimental "v0.5.0";

contract Scoping {

    uint g = 0;

    function globalScope() public {
        uint g = 0;
        g = g;
    }
    
    function localScope() public {
        
        uint i = 0;
        while (i++ < 1) {
            uint a = 0;
        }
        
        for(uint j=0; j<2; j++) {
            // uint a = j; Error
        }
    }
    
    // 0.5.0 accepted..
    function scopeDivide() public {
        {
            uint a = 0;
        }
        {
            uint a = 0;
        }
    }
    
}