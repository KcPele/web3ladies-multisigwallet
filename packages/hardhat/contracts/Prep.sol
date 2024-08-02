//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract CodeAlong {
	//chat app
	//users
	//1. create user
	//2. update user
	//3 delete his or her account
	//friends
	//1. create a message
	//2. read a message
	//end to end encrption

	uint256 public totalUsers;
	struct UserData {
		uint256 id;
		string username;
		uint256 userAge;
		address userAddress;
	}

	struct Message {
		string messageString;
		uint256 timeStamp;
		address sender;
		address recipient;
	}

	mapping(address => UserData) public user;
	//------sender ------------receiver----- messages
	mapping(address => mapping(address => Message[])) messages;

	//events
	event MessageSent(address sender, address recipient);
	event CreateUser(address userAddress, string username, uint256 userAge);

	//Gbemi
	//write a function that creates a new user
	function createUser(string calldata _username, uint256 _userAge) external {
		require(
			user[msg.sender].userAddress == address(0),
			"User already exists"
		);
		totalUsers += 1;
		user[msg.sender] = UserData({
			userAddress: msg.sender,
			username: _username,
			userAge: _userAge,
			id: totalUsers
		});

		emit CreateUser(msg.sender, _username, _userAge);
	}

	//Akande
	//write function to update a user
	function updateUser(string calldata _username, uint256 _userAge) external {
		UserData storage _user = user[msg.sender];
		//check if the user exist
		require(_user.id > 0, "User does not exist");
		_user.username = _username;
		_user.userAge = _userAge;
	}

	// Simi
	// Create message
	function createMessage(address _recipient, string memory _message) public {
		Message memory newMessage = Message({
			messageString: _message,
			timeStamp: block.timestamp,
			sender: msg.sender,
			recipient: _recipient
		});

		messages[msg.sender][_recipient].push(newMessage);
		emit MessageSent(msg.sender, _recipient);
	}

	// function to delete a user
	function deleteUser() external {
		UserData storage _user = user[msg.sender];
		//check if the user exist
		require(_user.id > 0, "User does not exist");

		delete (user[msg.sender]);
	}
}
