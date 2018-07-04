pragma solidity ^0.4.16;

library Set {
    struct Data {
        mapping(uint => bool) flags;
    }
    
    function insert(Data storage self, uint value) 
        public 
        returns (bool) 
    {
        if (self.flags[value])
            return false;
        
        self.flags[value] = true;
        return true;
    }
    
    function remove(Data storage self, uint value)
        public
        returns (bool)
    {
        if(!self.flags[value])
            return false;
    
        self.flags[value] = false;
        return true;
    }
    
    function contains(Data storage self, uint value)
        public
        view
        returns (bool)
    {
        return self.flags[value];
    }
    
}

contract SetContract {
    using Set for Set.Data;
    Set.Data data;
    
    function register(uint _value) 
        public
    {
        require(data.insert(_value));
    }
    
    function remove(uint _value)
        public
    {
        require(data.remove(_value));
    }
}