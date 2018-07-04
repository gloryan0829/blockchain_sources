pragma solidity ^0.4.23;

contract A {
    // currency unit
    
    // 1 wei;
    // 1 szabo;
    // 1 finney;
    // 1 ether;
    
    // // date unit
    // 1 seconds;
    // 1 minutes;
    // 1 hours;
    // 1 days;
    // 1 weeks;
    // 1 years; // it will be deprecated...
    function addNowAndDay() public view returns (uint) {
        return now + 1 days;
    }
}