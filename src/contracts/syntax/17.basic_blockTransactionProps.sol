pragma solidity ^0.4.23;

contract A {
    
    function getBlockHash(uint _blockNumber) public view returns (bytes32) {
        return blockhash(_blockNumber);
    }
    
    function getGasleft() public view returns (uint) {
        return gasleft();
    }
    
    function blockInfo() public view returns (address) {
        return block.coinbase;
        // block.difficulty (uint) , block.gaslimit (uint), block.number (uint)
    }
    
    function msgInfo() public view returns (address) {
        return msg.sender; 
        // msg.value(uint), msg.data (bytes) , msg.value (uint) etc...
    }
    
    function txInfo() public view returns (address) {
        return tx.origin;
        // tx.gasprive (uint) 
    }
    
}