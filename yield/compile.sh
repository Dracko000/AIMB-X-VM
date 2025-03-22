#!/bin/bash

echo "==========================================="
echo "🚀 AIMB Yield Farming & Liquidity Mining Compiler"
echo "==========================================="

# Cek apakah argumen diberikan
if [ -z "$1" ]; then
    echo "❌ Gunakan: ./compile.sh namafile.sync"
    exit 1
fi

# Ambil nama file dari argumen tanpa ekstensi
INPUT_FILE="$1"
CONTRACT_NAME=$(basename "$INPUT_FILE" .sync)
OUTPUT_DIR="$CONTRACT_NAME"

# Pastikan file .sync ada
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ File '$INPUT_FILE' tidak ditemukan."
    exit 1
fi

# Buat folder output untuk berbagai blockchain
ETHEREUM_DIR="$OUTPUT_DIR/ethereum"
SOLANA_DIR="$OUTPUT_DIR/solana"
APTOS_DIR="$OUTPUT_DIR/aptos"
SUI_DIR="$OUTPUT_DIR/sui"
TON_DIR="$OUTPUT_DIR/ton"

mkdir -p "$ETHEREUM_DIR" "$SOLANA_DIR" "$APTOS_DIR" "$SUI_DIR" "$TON_DIR"

# Baca konfigurasi dari .sync
REWARD_TOKEN=$(grep "rewardToken:" "$INPUT_FILE" | cut -d '"' -f2)
STAKING_TOKENS=$(grep "stakingTokens:" "$INPUT_FILE" | cut -d '"' -f2)
REWARD_RATE=$(grep "rewardRate:" "$INPUT_FILE" | awk -F ': ' '{print $2}')
LOCKUP_PERIOD=$(grep "lockupPeriod:" "$INPUT_FILE" | awk -F ': ' '{print $2}')
WITHDRAWAL_FEE=$(grep "withdrawalFee:" "$INPUT_FILE" | awk -F ': ' '{print $2}')

echo "📝 Nama Kontrak  : $CONTRACT_NAME"
echo "🔹 Reward Token  : $REWARD_TOKEN"
echo "🔹 Staking Tokens: $STAKING_TOKENS"
echo "🔹 Reward Rate   : $REWARD_RATE"
echo "🔹 Lockup Period : $LOCKUP_PERIOD hari"
echo "🔹 Withdrawal Fee: $WITHDRAWAL_FEE"
echo "📁 Output Folder : $OUTPUT_DIR"
echo "-------------------------------------------"

# 💡 Solidity Smart Contract untuk Ethereum
SOL_FILE="$ETHEREUM_DIR/$CONTRACT_NAME.sol"
cat <<EOL > "$SOL_FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    string public rewardToken = "$REWARD_TOKEN";
    uint256 public rewardRate = $REWARD_RATE;
    uint256 public lockupPeriod = $LOCKUP_PERIOD;
    uint256 public withdrawalFee = $WITHDRAWAL_FEE;
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
EOL
echo "✅ Solidity Smart Contract dibuat di $SOL_FILE"

# 💡 Rust Smart Contract untuk Solana
RUST_FILE="$SOLANA_DIR/$CONTRACT_NAME.rs"
cat <<EOL > "$RUST_FILE"
use anchor_lang::prelude::*;

#[program]
pub mod ${CONTRACT_NAME,,} {
    use super::*;

    #[account]
    pub struct FarmingAccount {
        pub owner: Pubkey,
        pub stake_amount: u64,
        pub start_time: i64,
    }

    #[derive(Accounts)]
    pub struct Stake<'info> {
        #[account(mut)]
        pub farming_account: Account<'info, FarmingAccount>,
    }

    pub fn stake(ctx: Context<Stake>, amount: u64) -> Result<()> {
        let account = &mut ctx.accounts.farming_account;
        account.stake_amount += amount;
        account.start_time = Clock::get()?.unix_timestamp;
        Ok(())
    }
}
EOL
echo "✅ Rust Smart Contract dibuat di $RUST_FILE"

# 💡 Move Smart Contract untuk Aptos & Sui
MOVE_FILE_APTOS="$APTOS_DIR/$CONTRACT_NAME.move"
MOVE_FILE_SUI="$SUI_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_APTOS"
module ${CONTRACT_NAME,,} {
    struct FarmingAccount {
        owner: address,
        stake_amount: u64,
        start_time: u64,
    }

    public fun stake(amount: u64) {
        let account = FarmingAccount {
            owner: signer(),
            stake_amount: amount,
            start_time: 0,
        };
    }
}
EOL
echo "✅ Move Smart Contract untuk Aptos & Sui dibuat"

echo "==========================================="
echo "🎉 Semua smart contract yield farming berhasil dikompilasi!"
echo "🔍 Cek folder '$OUTPUT_DIR/' untuk melihat hasilnya."
echo "==========================================="
