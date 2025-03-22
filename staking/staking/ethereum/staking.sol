// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract staking {
    string public token = "STK";
    address public rewardToken; // Developer harus mengatur ini setelah deploy
    uint256 public rewardRate = 0.01,;
    uint256 public minStake = 10,;
    uint256 public maxStake = 10000,;
    address public owner;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public rewards;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setRewardToken(address _rewardToken) public onlyOwner {
        rewardToken = _rewardToken; // Developer harus mengisi ini secara manual
    }

    function stake(uint256 amount) public {
        require(amount >= minStake && amount <= maxStake, "Stake amount out of range");
        stakes[msg.sender] += amount;
    }

    function claimRewards() public {
        require(rewardToken != address(0), "Reward token not set");
        rewards[msg.sender] += stakes[msg.sender] * rewardRate;
    }
}
