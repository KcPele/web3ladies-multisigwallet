// hi boss I'm here

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//mercy

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";

contract YourContract {
	// State Variables
	address public immutable owner;
	string public greeting = "Building Unstoppable Apps!!!";
	bool public premium = false;
	uint256 public totalCounter = 0;
	uint256 public totalUsers = 0;
	struct User {
		uint256 id;
		address userAddress;
		string name;
		uint age;
	}

	mapping(address => User) public userByAddress;

	//event for crud operations
	event UserCreated(uint256 id, address userAddress, string name, uint age);
	event UserUpdated(uint256 id, address userAddress, string name, uint age);
	event UserDeleted(uint256 id, address userAddress, string name, uint age);

	// Events: a way to emit log statements from smart contract that can be listened to by external parties
	event GreetingChange(
		address indexed greetingSetter,
		string newGreeting,
		bool premium,
		uint256 value
	);

	// Constructor: Called once on contract deployment
	// Check packages/hardhat/deploy/00_deploy_your_contract.ts
	constructor(address _owner) {
		owner = _owner;
	}

	function setGreeting(string memory _newGreeting) public payable {
		// Print data to the hardhat chain console. Remove when deploying to a live network.
		console.log(
			"Setting new greeting '%s' from %s",
			_newGreeting,
			msg.sender
		);

		// Change state variables
		greeting = _newGreeting;
		totalCounter += 1;

		// msg.value: built-in global variable that represents the amount of ether sent with the transaction
		if (msg.value > 0) {
			premium = true;
		} else {
			premium = false;
		}

		// emit: keyword used to trigger an event
		emit GreetingChange(msg.sender, _newGreeting, msg.value > 0, msg.value);
	}

	//crud operations
	function createUser(string memory _name, uint _age) public {
		//prevent creating already existing user
		require(
			userByAddress[msg.sender].userAddress == address(0),
			"User already exists"
		);
		User memory newUser = User(totalUsers, msg.sender, _name, _age);
		userByAddress[msg.sender] = newUser;
		totalUsers += 1;
		emit UserCreated(
			newUser.id,
			newUser.userAddress,
			newUser.name,
			newUser.age
		);
	}

	function updateUser(string memory _name, uint _age) public {
		User storage user = userByAddress[msg.sender];
		user.name = _name;
		user.age = _age;
		emit UserUpdated(user.id, user.userAddress, user.name, user.age);
	}

	function deleteUser() public {
		User memory user = userByAddress[msg.sender];
		require(user.userAddress != address(0), "User does not exist");
		require(
			user.userAddress == msg.sender,
			"You are not the owner of this user"
		);
		delete userByAddress[msg.sender];
		emit UserDeleted(user.id, user.userAddress, user.name, user.age);
	}

	// read operations
	function getUser(address _add) external view returns (User memory) {
		return userByAddress[_add];
	}

	receive() external payable {}
}
