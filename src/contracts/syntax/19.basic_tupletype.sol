pragma solidity > 0.4.23 < 0.5.0;

contract A {
    uint[] data;
    uint[] a;
    uint[] b;
    
    function f() public pure returns (uint, bool, uint) {
        return (0, true, 3);
    }
    
    function g() public {
     
        uint xVal;
        (uint x, bool bVal, uint y) = f();
        xVal = x;
        bool returnB = bVal;
        
        (x, y) = (y, x); // swap var
        
        (a[0],,) = f();
        (b[0],,b[1]) = f();
        
    }
}

contract cryptoKitty {
    function getKitty(uint tokenId) public view returns (uint, uint, uint); // dna
}