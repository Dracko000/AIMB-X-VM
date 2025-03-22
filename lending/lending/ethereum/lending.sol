// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract lending {
    address public owner = 0xAdminAddress;
    string public loanAsset = "USDT";
    
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    function deposit(uint256 amount) public {
        deposits[msg.sender] += amount;
    }

    function borrow(uint256 amount) public {
        require(deposits[msg.sender] > 0, "No collateral");
        borrows[msg.sender] += amount;
    }

    function liquidate(address user) public {
        require(borrows[user] > deposits[user] * "chainlink:ETH/USD"
{ "ETH"
{ "ETH" / 100, "Not eligible for liquidation");
        borrows[user] = 0;
    }
}
