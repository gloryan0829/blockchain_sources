pragma solidity ^0.4.23;

contract A {
    
    function a(uint _in) public pure returns (uint) {
        return _in;
    }
    
    function a(uint _in, uint _in2) public pure returns (uint, uint) {
        return (_in, _in2);
    }
    
}

contract externalB {
    function f(A _in) external pure returns (A) {
        return _in;
    }
    
    // function f(address _in) external pure returns (address) {
    //     return _in;
    // }
}

contract internalB {
    function f(A _in) internal pure returns (A) {
        return _in;
    }
    
    function f(address _in) internal pure returns (address) {
        return _in;
    }
}