pragma solidity ^0.4.23;

contract A {
    
    address owner;
    
    constructor () public payable {
        owner = msg.sender;
    }
    
    function () payable {
        require(msg.value == 5 ether);
    }
    
    function balanceOf(address _addr) public view returns (uint) {
        return _addr.balance;
    }
    
    function contractBalanceOf() public view returns (uint) {
        return this.balance;
    }
    
    function contractAddress() public view returns (address) {
        return this;
    }
    
    function selfdestruct() external {
        require(msg.sender == owner);
        selfdestruct(owner);
        //suicide(owner);
    }
    
}