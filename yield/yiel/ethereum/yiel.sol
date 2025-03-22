// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract yiel {
    string public rewardToken = "YIELD";
    uint256 public rewardRate = 0.1                  // Reward 10% per tahun;
    uint256 public lockupPeriod = 30                  // Waktu lock-up dalam hari;
    uint256 public withdrawalFee = 0.005              // 0.5% fee untuk penarikan awal;
    address public owner;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public startTimes;

    constructor() {
        owner = msg.sender;
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Staking amount must be greater than 0");
        stakes[msg.sender] += amount;
        startTimes[msg.sender] = block.timestamp;
    }

    function unstake() public {
        require(stakes[msg.sender] > 0, "No active stake");
        
        uint256 stakedAmount = stakes[msg.sender];
        uint256 duration = block.timestamp - startTimes[msg.sender];
        uint256 reward = (stakedAmount * rewardRate / 100) * (duration / 365 days);

        uint256 finalAmount = duration < lockupPeriod ? stakedAmount - (stakedAmount * withdrawalFee / 100) : stakedAmount;
        stakes[msg.sender] = 0;

        payable(msg.sender).transfer(finalAmount);
    }
}
