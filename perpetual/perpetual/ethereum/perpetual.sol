// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract perpetual {
    address public owner = 0xAdminAddress;
    
    struct Position {
        uint256 amount;
        uint256 leverage;
        uint256 entryPrice;
    }

    mapping(address => Position) public positions;

    function openPosition(uint256 amount, uint256 leverage) public {
        require(leverage <= "chainlink:ETH/USD"
{ "ETH"
{ "ETH", "Leverage terlalu tinggi");
        positions[msg.sender] = Position(amount, leverage, getPrice());
    }

    function closePosition() public {
        delete positions[msg.sender];
    }

    function getPrice() public view returns (uint256) {
        return 3000; // Placeholder oracle
    }
}
