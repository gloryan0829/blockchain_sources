pragma solidity ^0.4.23;

// case1
contract ancestorA {
    
    constructor() public {}
    
    function a() public pure returns (uint) {
        return uint(1);
    }
    
    function a(uint _x) {}
    
}

contract ancestorB {
    
    constructor() public {}
    
    function a() public pure returns (uint) {
        return uint(2);
    }    
}

contract person is ancestorB, ancestorA {
    constructor() public {}
    
    
    function a(uint _x, uint _y) public pure returns (uint) {
        return (_x + _y);
    }
}


// case 2
contract owned {
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
}

contract motal is owned {
    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }
}

contract Config {
    function lookup(uint id) public returns (address);
}

contract NameReg {
    function register(string name) public;
    function unregister() public;
}

contract named is owned, motal {
    Config config;
    constructor(string name) {
        config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
        NameReg(config.lookup(1)).register(name);
    }
    
    function kill() public {
        if(msg.sender == owner){
            NameReg(config.lookup(1)).unregister();
            motal.kill();
        }
        
    }
}

// case 3
contract Base {
    
    uint x;
    
    constructor(uint _x)
        public 
    {
        x = _x;
    }
    
}

contract A1 is Base(3) {
    constructor(uint _y)
        public
    {
        
    }
}

contract A2 is Base {
    constructor(uint _y) Base (_y ** _y)
        public
    {
        
    }
}