pragma solidity ^0.4.23;

contract AdoptContract {
	
	struct dogInfo {
		string dogBreed;
		uint8 dogAge;
		string ownerId;
		string ownerLocation; 
	}

	mapping(uint => dogInfo);

	constructor() pulbic {

	}
}