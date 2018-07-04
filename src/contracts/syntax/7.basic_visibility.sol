pragma solidity ^0.4.23;

contract Coffee {
    uint private coffeeDrankCount = 0;
    
    function coffeeDrank() internal {
        coffeeDrankCount++;
    }
}

contract Mocha is Coffee {
    uint private mochaDrankCount = 0;

    function mochaDrank() public {
        mochaDrankCount++;
        coffeeDrank();
    }
}

// example1 : public, getter
contract A {
    uint public data = 1;
    
    function f() public pure returns (bool) {
        return true;
    }
    
}

contract B {
    
    struct Data {
        uint a;
        bytes4 b;
        mapping (uint => string) map;
    }
    
    mapping (address => Data) public data;

    constructor() public {
        data[msg.sender].a = 1;
        data[msg.sender].b = bytes4(keccak256("admin"));
        data[msg.sender].map[0] = "Hi!";
    }
    
    function getMap(address _addr, uint _index) public view returns (string) {
        return data[_addr].map[_index];
    }
}

contract Caller is B {
    A a = new A();
    
    function f() public view returns (uint) {
        uint local = a.data();
        return local;
    }
    
    function _call() public view returns (bool) {
        return a.f();
    }
}

// example2 : private, internal, external

contract C {
    uint private a = 1;
    uint internal b = 2;
    uint public c;
    
    function _xy() private {
        uint c = a + b;
    }
    
    function _zy() public view returns (uint) {
        c = a + b;
        return c;
    }
    
    function _yy() external view returns (uint) {
        return b - a;
    }
}

contract K is C {
    
    constructor() {
        //a = 1; error
        b = 3;    
    }
    
    function caller() public view returns (uint) {
        // _xy(); error
        // _yy(); error
        return _zy();
    }
}