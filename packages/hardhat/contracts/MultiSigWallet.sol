// SPDX-License-Identifier: MIT
// Real money here 0x2d2F7893164049374fc7683c3A248584f4ADB9b8 base
// withdrawal contract 0xFa3E3aABbF8C3B20ec363f15A31cc9782F635dD5
// helper 0x3D10A21cCfEE3d970a49d09b0562A7502c251991
pragma solidity >=0.8.0 <0.9.0;
error MultiSigWallet__OwnersRequired();
error MultiSigWallet__InvalidConfirmationNumber();
error MultiSigWallet__InvalidOwner();
error MultiSigWallet__OwnerNotUnique();
error MultiSigWallet__NotOwner();
error MultiSigWallet__TxDoesNotExist();
error MultiSigWallet__TxAlreadyExecuted();
error MultiSigWallet__TxAllreadyConfirmed();
error MultiSigWallet__CannotExecuteTx();
error MultiSigWallet__TxNotConfirmed();
error MultiSigWallet__CreatorCannotConfirm();
contract MultiSigWallet {
	event Deposit(address indexed sender, uint256 amount, uint256 balance);
	event SubmitTransaction(
		address indexed owner,
		uint256 indexed txIndex,
		address indexed to,
		uint256 value,
		bytes data
	);
	event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
	event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
	event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

	address[] public owners;
	mapping(address => bool) public isOwner;
	uint256 public numConfirmationsRequired;

	struct Transaction {
		address to;
		uint256 value;
		bytes data;
		bool executed;
		uint256 numConfirmations;
		address creator;
	}

	// mapping from tx index => owner => bool
	mapping(uint256 => mapping(address => bool)) public isConfirmed;

	Transaction[] public transactions;

	modifier onlyOwner() {
		if (!isOwner[msg.sender]) {
			revert MultiSigWallet__NotOwner();
		}
		_;
	}

	modifier txExists(uint256 _txIndex) {
		if (_txIndex >= transactions.length) {
			revert MultiSigWallet__TxDoesNotExist();
		}
		_;
	}

	modifier notExecuted(uint256 _txIndex) {
		if (transactions[_txIndex].executed) {
			revert MultiSigWallet__TxAlreadyExecuted();
		}
		_;
	}

	modifier notConfirmed(uint256 _txIndex) {
		if (isConfirmed[_txIndex][msg.sender]) {
			revert MultiSigWallet__TxAllreadyConfirmed();
		}
		_;
	}

	constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
		if (_owners.length <= 0) {
			revert MultiSigWallet__OwnersRequired();
		}
		if (
			_numConfirmationsRequired <= 0 &&
			_numConfirmationsRequired > _owners.length
		) {
			revert MultiSigWallet__InvalidConfirmationNumber();
		}

		for (uint256 i = 0; i < _owners.length; ) {
			address owner = _owners[i];

			if (owner == address(0)) {
				revert MultiSigWallet__InvalidOwner();
			}
			if (isOwner[owner]) {
				revert MultiSigWallet__OwnerNotUnique();
			}

			isOwner[owner] = true;
			owners.push(owner);

			unchecked {
				++i;
			}
		}

		numConfirmationsRequired = _numConfirmationsRequired;
	}

	receive() external payable {
		emit Deposit(msg.sender, msg.value, address(this).balance);
	}

	fallback() external payable {}

	function submitTransaction(
		address _to,
		uint256 _value,
		bytes memory _data
	) public onlyOwner {
		uint256 txIndex = transactions.length;

		transactions.push(
			Transaction({
				to: _to,
				value: _value,
				data: _data,
				executed: false,
				numConfirmations: 0,
				creator: msg.sender
			})
		);

		emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
	}

	function confirmTransaction(
		uint256 _txIndex
	)
		public
		onlyOwner
		txExists(_txIndex)
		notExecuted(_txIndex)
		notConfirmed(_txIndex)
	{
		Transaction storage transaction = transactions[_txIndex];
		//prevent transaction confirmation by the same owner
		if (transaction.creator == msg.sender) {
			revert MultiSigWallet__CreatorCannotConfirm();
		}
		transaction.numConfirmations += 1;
		isConfirmed[_txIndex][msg.sender] = true;

		emit ConfirmTransaction(msg.sender, _txIndex);
	}

	function executeTransaction(
		uint256 _txIndex
	) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
		Transaction storage transaction = transactions[_txIndex];

		if (transaction.numConfirmations < numConfirmationsRequired) {
			revert MultiSigWallet__CannotExecuteTx();
		}

		transaction.executed = true;

		(bool success, ) = transaction.to.call{ value: transaction.value }(
			transaction.data
		);
		require(success, "tx failed");

		emit ExecuteTransaction(msg.sender, _txIndex);
	}

	function revokeConfirmation(
		uint256 _txIndex
	) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
		Transaction storage transaction = transactions[_txIndex];

		if (!isConfirmed[_txIndex][msg.sender]) {
			revert MultiSigWallet__TxNotConfirmed();
		}

		transaction.numConfirmations -= 1;
		isConfirmed[_txIndex][msg.sender] = false;

		emit RevokeConfirmation(msg.sender, _txIndex);
	}

	function getOwners() public view returns (address[] memory) {
		return owners;
	}

	function getTransactionCount() public view returns (uint256) {
		return transactions.length;
	}

	function getTransaction(
		uint256 _txIndex
	)
		public
		view
		returns (
			address to,
			uint256 value,
			bytes memory data,
			bool executed,
			uint256 numConfirmations
		)
	{
		Transaction storage transaction = transactions[_txIndex];

		return (
			transaction.to,
			transaction.value,
			transaction.data,
			transaction.executed,
			transaction.numConfirmations
		);
	}
	function getAlltransactions() external view returns (Transaction[] memory) {
		return transactions;
	}
}

contract Help {
	function getData() public pure returns (bytes memory) {
		return abi.encodeWithSignature("withdraw()");
	}
}

contract Withdraw {
	address public owner;

	constructor() {
		owner = msg.sender;
	}
	function withdraw() public payable {
		payable(owner).transfer(address(this).balance);
	}

	receive() external payable {}
	fallback() external payable {}
}
