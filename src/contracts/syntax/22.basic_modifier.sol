pragma solidity ^0.4.23;

contract ModifierTest {
    uint public a = 1;
    
    // modifier checkOneToTwo {
    //     require(a == 1);
    //     _;
    //     require(a == 2);
    // }
    
    modifier changeTwo {
        a = 2;
        _;
    }
    
    modifier changeThree {
        a = 3;
        _;
    }
    
    modifier argModifier(uint _a) {
        //_a=10;
        require(_a == 1, "not equal ~ ");
        _;
    }
    
    function func() public changeThree changeTwo {
        //a = 2;
    }
    
    function func2(uint _a) public argModifier(_a) pure returns (uint) {
        return _a; 
    } 
}