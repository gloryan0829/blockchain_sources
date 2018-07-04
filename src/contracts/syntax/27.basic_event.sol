pragma solidity ^0.4.23;

contract EventContract {
    event Transfer(address indexed _from, address indexed _to, uint value);
    
    function transfer(address _from, address _to, uint _value) public {
        // something transfer logic...
        
        emit Transfer(_from, _to, _value);
    }
}

