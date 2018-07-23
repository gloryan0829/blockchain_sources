pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ERC721.sol";

contract TestToken721 {
	function testToken721_nameTest() public {
		Token721 nft = new Token721();

		Assert.equal(nft.name(), "721Token", "name eqaul test example...");
	}
}