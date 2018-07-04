pragma solidity ^0.4.23;

contract ExampleContract {
    uint id = 3;
    
    function getSomething(uint _id) public view returns (uint) {
        return 3+_id;
    }
    
    function getSomething2(uint _id) public view returns (uint) {
        return 3-_id;
    }
}

contract ExampleInterface {
    function getSomething(uint _id) public view returns (uint);
}

contract MyContract {
    address ExampleInterfaceAddress = 0x692a70d2e424a56d2c6c27aa97d1a86395877b3a;
    
    // ExampleContract examp = ExampleContract(ExampleInterfaceAddress);
    ExampleInterface exampleContract = ExampleInterface(ExampleInterfaceAddress); // 형변환….

    function someFunction() public view returns (uint){
        uint some = exampleContract.getSomething(1);
        return some;
    }
}