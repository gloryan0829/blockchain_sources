pragma solidity ^0.4.23;

// import local file & remote file..
//import "./basic-2.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/ethereum/dapp-bin/library/stringUtils.sol";

// Single line comment


/**
 * multi line comment
 **/



/// @title rectangle
contract basic {
 
 uint8 public a;
 uint64[] public originArr = [1,2,3];
 using StringUtils for string;
 
/** This is the NatSpec
 * @dev Calculates a rectangle's surface and perimeter 
 * @param a Width of the rectangle
 * @param b Height of the rectangle
 * @return x The calculated surface
 * @return y The calculate perimeter
 */
 function rectangle(uint a, uint b) public pure returns (uint x, uint y) {
     x = a * b;
     y = 2 * (a + b);
     return (x, y);
 }
 
 function dataLocation() public view returns (uint64[], uint64[]) {
     
     uint64[] storage storArr = originArr;
     
     uint64[] memory memArr = originArr;
     
     return (storArr, memArr);
 }

 function memberOfAddress(address _address, string _type) public returns (uint) {
     
     address addr = address(_address);
     
     if (_type.equal("balance")) 
         return addr.balance;
     else if (StringUtils.equal(_type, "transfer")) {
         addr.transfer(0);
         return 1;
     }
     else return 0;
 }
 
}


contract C {
    uint[] x; // 상태 변수는 storage 저장된다.

    // memoryArray 는 memory 에 저장된다.
    function f(uint[] memoryArray) public {
        x = memoryArray; // works, 전체 array 데이타가 x 로 복사된다.
        var y = x; // works, 포인터로서 참조만 한다.
        y[7]; // fine
        y.length = 2; // fine, x 의 길이도 수정된다.
        delete x; // fine, array 가 지워지며 y 또한 반영된다.
        // 다음은 동작하지 않는다. 스토리지에 임시 저장소를 새로 만들어야 하는데,
        // 이미 allocated 된 공간이 있기 때문이다.
        // y = memoryArray;
        // 이미 초기화 되었기 때문에 다음도 실행되지 않는다.
        // delete y;
        g(x); // 상태변수 to storage. 참조만 일어난다.
        h(x); // 상태변수(storage) to memory. 복사가 일어난다.
    }

    function g(uint[] storage storageArray) internal {}
    function h(uint[] memoryArray) public {}
}


contract anotherContract {
    uint public a = 0;
    
    function go(uint256 _a) public {
        a = _a;
    }
}