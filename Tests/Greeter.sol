pragma solidity ^0.4.24;

contract Greeter {
	string greeting;

	function greet() public view returns (string) {
		return greeting;
	}
}
