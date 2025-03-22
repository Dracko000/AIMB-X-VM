#!/bin/bash

echo "==========================================="
echo "🚀 AIMB Smart Contract Compiler"
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

# Buat folder output dengan nama sesuai file .sync
ETHEREUM_DIR="$OUTPUT_DIR/ethereum"
SOLANA_DIR="$OUTPUT_DIR/solana"
APTOS_DIR="$OUTPUT_DIR/aptos"
SUI_DIR="$OUTPUT_DIR/sui"
TON_DIR="$OUTPUT_DIR/ton"

mkdir -p "$ETHEREUM_DIR" "$SOLANA_DIR" "$APTOS_DIR" "$SUI_DIR" "$TON_DIR"

# Baca file .sync
NAME=$(grep "name:" "$INPUT_FILE" | cut -d '"' -f2)
TOKEN=$(grep "token:" "$INPUT_FILE" | cut -d '"' -f2)
REWARD_RATE=$(grep "rewardRate:" "$INPUT_FILE" | awk -F ': ' '{print $2}')
MIN_STAKE=$(grep "minStake:" "$INPUT_FILE" | awk -F ': ' '{print $2}')
MAX_STAKE=$(grep "maxStake:" "$INPUT_FILE" | awk -F ': ' '{print $2}')

# Tampilkan Informasi
echo "📝 Nama Kontrak  : $CONTRACT_NAME"
echo "🔹 Token Staking : $TOKEN"
echo "🔹 Reward Rate   : $REWARD_RATE"
echo "🔹 Min Stake     : $MIN_STAKE"
echo "🔹 Max Stake     : $MAX_STAKE"
echo "📁 Output Folder : $OUTPUT_DIR"
echo "-------------------------------------------"

# 💡 Solidity untuk Ethereum (Reward Token Dinamis)
SOL_FILE="$ETHEREUM_DIR/$CONTRACT_NAME.sol"
cat <<EOL > "$SOL_FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    string public token = "$TOKEN";
    address public rewardToken; // Developer harus mengatur ini setelah deploy
    uint256 public rewardRate = $REWARD_RATE;
    uint256 public minStake = $MIN_STAKE;
    uint256 public maxStake = $MAX_STAKE;
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
EOL
echo "✅ Solidity Smart Contract dibuat di $SOL_FILE"

# 💡 Rust untuk Solana (Reward Token Dinamis)
RUST_FILE="$SOLANA_DIR/$CONTRACT_NAME.rs"
cat <<EOL > "$RUST_FILE"
use anchor_lang::prelude::*;

#[program]
pub mod ${CONTRACT_NAME,,} {
    use super::*;

    #[account]
    pub struct StakeAccount {
        pub owner: Pubkey,
        pub amount: u64,
        pub reward: u64,
    }

    #[account]
    pub struct Config {
        pub reward_token: Pubkey,
    }

    #[derive(Accounts)]
    pub struct Stake<'info> {
        #[account(mut)]
        pub stake_account: Account<'info, StakeAccount>,
    }

    pub fn set_reward_token(ctx: Context<Stake>, reward_token: Pubkey) -> Result<()> {
        let config = &mut ctx.accounts.stake_account;
        config.reward_token = reward_token;
        Ok(())
    }

    pub fn stake(ctx: Context<Stake>, amount: u64) -> Result<()> {
        let stake = &mut ctx.accounts.stake_account;
        stake.amount += amount;
        stake.reward += amount * $REWARD_RATE;
        Ok(())
    }
}
EOL
echo "✅ Rust Smart Contract dibuat di $RUST_FILE"

# 💡 Move untuk Aptos (Reward Token Dinamis)
MOVE_FILE_APTOS="$APTOS_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_APTOS"
module ${CONTRACT_NAME,,} {
    struct Stake {
        owner: address,
        amount: u64,
        reward: u64,
    }

    struct Config {
        reward_token: address,
    }

    public fun set_reward_token(dev: signer, reward_token: address) {
        // Developer harus mengisi reward token setelah deploy
    }

    public fun stake(amount: u64) {
        assert!(amount >= $MIN_STAKE && amount <= $MAX_STAKE, 1);
        let stake = Stake {
            owner: signer(),
            amount: amount,
            reward: amount * $REWARD_RATE,
        };
    }
}
EOL
echo "✅ Move Smart Contract untuk Aptos dibuat di $MOVE_FILE_APTOS"

# 💡 Move untuk Sui (Reward Token Dinamis)
MOVE_FILE_SUI="$SUI_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_SUI"
module ${CONTRACT_NAME,,} {
    struct Stake has store {
        owner: address,
        amount: u64,
        reward: u64,
    }

    struct Config has store {
        reward_token: address,
    }

    public fun set_reward_token(dev: signer, reward_token: address) {
        // Developer harus mengisi reward token setelah deploy
    }

    public fun stake(owner: address, amount: u64) {
        assert!(amount >= $MIN_STAKE && amount <= $MAX_STAKE, 1);
        let stake = Stake {
            owner: owner,
            amount: amount,
            reward: amount * $REWARD_RATE,
        };
    }
}
EOL
echo "✅ Move Smart Contract untuk Sui dibuat di $MOVE_FILE_SUI"

# 💡 FunC untuk TON (Reward Token Dinamis)
FUNC_FILE="$TON_DIR/$CONTRACT_NAME.fc"
cat <<EOL > "$FUNC_FILE"
;; TON Staking Contract

global stake
global claim_rewards
global set_reward_token

;; Data storage
data (min_stake $MIN_STAKE)
data (max_stake $MAX_STAKE)
data (reward_rate $REWARD_RATE)
data (reward_token null)

void set_reward_token(new_reward_token) {
    data (reward_token = new_reward_token)
}

void stake(amount) {
    require(amount >= min_stake && amount <= max_stake)
    data (stakes caller += amount)
    data (rewards caller += amount * reward_rate)
}

void claim_rewards() {
    require(reward_token != null)
    data (caller_rewards = rewards caller)
    send(caller, caller_rewards)
}
EOL
echo "✅ FunC Smart Contract untuk TON dibuat di $FUNC_FILE"

echo "==========================================="
echo "🎉 Semua smart contract berhasil dikompilasi!"
echo "🔍 Cek folder '$OUTPUT_DIR/' untuk melihat hasilnya."
echo "==========================================="
