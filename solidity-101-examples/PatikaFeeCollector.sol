
pragma solidity ^0.8.7;

contract FeeCollector{
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    receive () external payable {
        balance += msg.value;
    }

    function withdraw(uint amount, address payable destAddress) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(amount <= balance, "Insufficient funds");
        destAddress.transfer(amount);
        balance -= amount;
    }
}