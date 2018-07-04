pragma solidity ^0.4.16;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract calculator {
    string aa = "abc";
    string bb = "def";
    uint public a = 1;
    uint public b = 2;
    uint public c;
    
    using SafeMath for uint;
    
    function add() public {
        c = SafeMath.add(a, b);
    } 
}

library Search {    
    function indexOf(uint[] storage self, uint value) public view returns (uint) { 
        for (uint i = 0; i < self.length; i++)
            if (self[i] == value) return i;
        return uint(-1);
    }
}

contract basic_array_indexOf {
    using Search for uint[];
    uint[] data;
    
    function append(uint value) public {
        data.push(value);
    }
    
    function replace(uint _old, uint _new) public {
        uint index = data.indexOf(_old);
        if (index == uint(-1))
            data.push(_new);
        else
            data[index] = _new;
    }

}

