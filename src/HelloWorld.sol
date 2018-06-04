pragma solidity ^0.4.19;

import "github.com/willitscale/solidity-util/lib/Strings.sol";

contract HelloWorldAbstract {
    using Strings for string;
    function whatisYourName(string name) public ;
    function sayYourName() public view returns (string);
}

contract HelloWorld is HelloWorldAbstract {
    string public greeting;
    string private name;

    constructor() public{
        greeting = "Hi!";
        name = "Anonymous";
    }

    modifier commonFunc() {
        _;
    }

    function whatisYourName(string _name) public commonFunc {
        name = _name;
    }

    function sayYourName() public view returns (string) {
        return name;
    }

    function setGreeting(string _greeting) public commonFunc {
        greeting = _greeting;
    }

    function sayHello() public view returns(string) {
        return greeting.concat(" ").concat(name);
    }

}
