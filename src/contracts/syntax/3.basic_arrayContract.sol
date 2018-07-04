pragma solidity ^0.4.23;

contract ArrayContract {
    uint[2] fixedArray; // globalStaticArray
    string[5] stringArray;
    
    uint[] dynamicUintArray = [1,2,3]; //globalDinamicallyArray
    
    function localAreaFunc() public view returns (uint[]) {
        uint[] x = dynamicUintArray;
        // delete dynamicUintArray; //x is the var of reference type
        return x;
    }
    
    function memoryVarFunc(uint[] memory paramArr) public view returns (uint[]){
        uint[] memory x = paramArr;
        delete paramArr; // x is not the var of reference type ... just value...
        return x;
    }
    
}


contract ArrayExample {
    
    uint32[3] globalStaticArray = [1, 2, 3];
    uint8[] globalDinamicallyArray = new uint8[](7);
       
    // uint8[3] globalErrorArray= [1234, 5678, 9011];
    
    function arrayExample() {
        // uint8[3] localStaticArray = [1, 2, 3]; // Error
        // uint8[3] localErrorArray = new uint8[](localStaticArray.length); // Error
        
        uint8[3] memory localMemoryArray = [1, 2, 3]; // OK
        uint8[] memory localMemoryArray2 = new uint8[](localMemoryArray.length); // OK
        
        // local array는 다른 storage array를 참조하거나 memory array로 선언하여 사용하여야 함.
        uint8[] localDinamicallyArray = globalDinamicallyArray; // OK
    }
}