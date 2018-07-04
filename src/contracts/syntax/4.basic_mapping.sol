pragma solidity ^0.4.23;

contract BankContract {
    mapping(address => uint) public balances;
    
    function deposit(uint _amount) public {
        balances[msg.sender] += _amount;
    }
}


contract MappingUser {
    function saveMoney(address _addr, uint _money) public returns (uint) {
        BankContract bank = BankContract(_addr);
        bank.deposit(_money);
        return bank.balances(msg.sender);
    }
}