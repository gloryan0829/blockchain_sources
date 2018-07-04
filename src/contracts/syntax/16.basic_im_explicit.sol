pragma solidity ^0.4.16;

contract SetContract {
    
    //explicit
    int8 y = -3;
    uint8 x = uint8(y);
    
    uint32 a = 0x12345678;
    uint16 b = uint16(a);
    
    uint16 c = 0xffff;
    bytes32 d = bytes32(uint256(c));
    
    //implicit
    int16 k = -4;
    int32 m = k;
    
    uint32 aa = 0x12345678;
    uint32 bb = aa;
    
}