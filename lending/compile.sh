#!/bin/bash

echo "==========================================="
echo "🚀 AIMB Lending & Borrowing Contract Compiler"
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

# Buat folder output
ETHEREUM_DIR="$OUTPUT_DIR/ethereum"
SOLANA_DIR="$OUTPUT_DIR/solana"
APTOS_DIR="$OUTPUT_DIR/aptos"
SUI_DIR="$OUTPUT_DIR/sui"
TON_DIR="$OUTPUT_DIR/ton"

mkdir -p "$ETHEREUM_DIR" "$SOLANA_DIR" "$APTOS_DIR" "$SUI_DIR" "$TON_DIR"

# Baca file .sync
OWNER=$(grep "owner:" "$INPUT_FILE" | cut -d '"' -f2)
LOAN_ASSET=$(grep "loanAsset:" "$INPUT_FILE" | cut -d '"' -f2)
COLLATERAL=$(grep "collateral:" "$INPUT_FILE" | cut -d '"' -f2)
ORACLE_ETH=$(grep '"ETH":' "$INPUT_FILE" | cut -d '"' -f4)
ORACLE_BTC=$(grep '"BTC":' "$INPUT_FILE" | cut -d '"' -f4)
ORACLE_USDC=$(grep '"USDC":' "$INPUT_FILE" | cut -d '"' -f4)
MAX_LTV_ETH=$(grep '"ETH":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
MAX_LTV_BTC=$(grep '"BTC":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
MAX_LTV_USDC=$(grep '"USDC":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
LIQ_THRESHOLD_ETH=$(grep '"ETH":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
LIQ_THRESHOLD_BTC=$(grep '"BTC":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
LIQ_THRESHOLD_USDC=$(grep '"USDC":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
INTEREST_RATE_BASE=$(grep "interestRateBase:" "$INPUT_FILE" | awk -F ': ' '{print $2}')
INTEREST_RATE_DYNAMIC=$(grep "interestRateDynamic:" "$INPUT_FILE" | awk -F ': ' '{print $2}')

# Tampilkan Informasi
echo "📝 Nama Kontrak  : $CONTRACT_NAME"
echo "🔹 Owner         : $OWNER"
echo "🔹 Loan Asset    : $LOAN_ASSET"
echo "🔹 Collateral    : $COLLATERAL"
echo "🔹 Oracle ETH    : $ORACLE_ETH"
echo "🔹 Oracle BTC    : $ORACLE_BTC"
echo "🔹 Oracle USDC   : $ORACLE_USDC"
echo "🔹 Max LTV ETH   : $MAX_LTV_ETH%"
echo "🔹 Max LTV BTC   : $MAX_LTV_BTC%"
echo "🔹 Max LTV USDC  : $MAX_LTV_USDC%"
echo "🔹 Liq Threshold ETH : $LIQ_THRESHOLD_ETH%"
echo "🔹 Liq Threshold BTC : $LIQ_THRESHOLD_BTC%"
echo "🔹 Liq Threshold USDC: $LIQ_THRESHOLD_USDC%"
echo "🔹 Interest Base  : $INTEREST_RATE_BASE%"
echo "🔹 Interest Dynamic: $INTEREST_RATE_DYNAMIC"
echo "📁 Output Folder : $OUTPUT_DIR"
echo "-------------------------------------------"

# 💡 Solidity untuk Ethereum
SOL_FILE="$ETHEREUM_DIR/$CONTRACT_NAME.sol"
cat <<EOL > "$SOL_FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    address public owner = $OWNER;
    string public loanAsset = "$LOAN_ASSET";
    
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
        require(borrows[user] > deposits[user] * $LIQ_THRESHOLD_ETH / 100, "Not eligible for liquidation");
        borrows[user] = 0;
    }
}
EOL
echo "✅ Solidity Smart Contract dibuat di $SOL_FILE"

# 💡 Rust untuk Solana
RUST_FILE="$SOLANA_DIR/$CONTRACT_NAME.rs"
cat <<EOL > "$RUST_FILE"
use anchor_lang::prelude::*;

#[program]
pub mod ${CONTRACT_NAME,,} {
    use super::*;

    #[account]
    pub struct LendingAccount {
        pub owner: Pubkey,
        pub deposit: u64,
        pub borrow: u64,
    }

    #[derive(Accounts)]
    pub struct Deposit<'info> {
        #[account(mut)]
        pub lending_account: Account<'info, LendingAccount>,
    }

    pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
        let account = &mut ctx.accounts.lending_account;
        account.deposit += amount;
        Ok(())
    }

    pub fn borrow(ctx: Context<Deposit>, amount: u64) -> Result<()> {
        let account = &mut ctx.accounts.lending_account;
        account.borrow += amount;
        Ok(())
    }
}
EOL
echo "✅ Rust Smart Contract dibuat di $RUST_FILE"

# 💡 Move untuk Aptos
MOVE_FILE_APTOS="$APTOS_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_APTOS"
module ${CONTRACT_NAME,,} {
    struct LendingAccount {
        owner: address,
        deposit: u64,
        borrow: u64,
    }

    public fun deposit(amount: u64) {
        let account = LendingAccount {
            owner: signer(),
            deposit: amount,
            borrow: 0,
        };
    }

    public fun borrow(amount: u64) {
        let account = LendingAccount {
            owner: signer(),
            deposit: 0,
            borrow: amount,
        };
    }
}
EOL
echo "✅ Move Smart Contract untuk Aptos dibuat di $MOVE_FILE_APTOS"

# 💡 Move untuk Sui
MOVE_FILE_SUI="$SUI_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_SUI"
module ${CONTRACT_NAME,,} {
    struct LendingAccount has store {
        owner: address,
        deposit: u64,
        borrow: u64,
    }

    public fun deposit(owner: address, amount: u64) {
        let account = LendingAccount {
            owner: owner,
            deposit: amount,
            borrow: 0,
        };
    }

    public fun borrow(owner: address, amount: u64) {
        let account = LendingAccount {
            owner: owner,
            deposit: 0,
            borrow: amount,
        };
    }
}
EOL
echo "✅ Move Smart Contract untuk Sui dibuat di $MOVE_FILE_SUI"

# 💡 FunC untuk TON
FUNC_FILE="$TON_DIR/$CONTRACT_NAME.fc"
cat <<EOL > "$FUNC_FILE"
;; TON Lending Contract
global deposit
global borrow
global liquidate

void deposit(amount) {
    require(amount >= 1)
    data (deposits caller += amount)
}

void borrow(amount) {
    require(amount >= 1)
    data (borrows caller += amount)
}

void liquidate(user) {
    require(borrows user > deposits user * $LIQ_THRESHOLD_ETH / 100)
    data (borrows user = 0)
}
EOL
echo "✅ FunC Smart Contract untuk TON dibuat di $FUNC_FILE"

echo "==========================================="
echo "🎉 Semua smart contract lending & borrowing berhasil dikompilasi!"
echo "🔍 Cek folder '$OUTPUT_DIR/' untuk melihat hasilnya."
echo "===========================================" 
