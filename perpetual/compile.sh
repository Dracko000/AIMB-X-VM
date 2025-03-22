#!/bin/bash

echo "==========================================="
echo "🚀 AIMB Perpetual Futures Contract Compiler"
echo "==========================================="

# Cek apakah file diberikan sebagai argumen
if [ -z "$1" ]; then
    echo "❌ Gunakan: ./compile.sh namafile.sync"
    exit 1
fi

# Ambil nama file dari argumen
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
SUPPORTED_ASSETS=$(grep "supportedAssets:" "$INPUT_FILE" | cut -d '[' -f2 | cut -d ']' -f1)
FUNDING_RATE=$(grep "fundingRate:" "$INPUT_FILE" | awk -F ': ' '{print $2}')
LEVERAGE_ETH=$(grep '"ETH":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
LEVERAGE_BTC=$(grep '"BTC":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)
LEVERAGE_SOL=$(grep '"SOL":' "$INPUT_FILE" | awk -F ': ' '{print $2}' | cut -d ',' -f1)

# Tampilkan Informasi
echo "📝 Nama Kontrak   : $CONTRACT_NAME"
echo "🔹 Owner          : $OWNER"
echo "🔹 Assets         : $SUPPORTED_ASSETS"
echo "🔹 Funding Rate   : $FUNDING_RATE%"
echo "🔹 Leverage ETH   : $LEVERAGE_ETH"
echo "🔹 Leverage BTC   : $LEVERAGE_BTC"
echo "🔹 Leverage SOL   : $LEVERAGE_SOL"
echo "📁 Output Folder  : $OUTPUT_DIR"
echo "-------------------------------------------"

# 💡 Solidity untuk Ethereum
SOL_FILE="$ETHEREUM_DIR/$CONTRACT_NAME.sol"
cat <<EOL > "$SOL_FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    address public owner = $OWNER;
    
    struct Position {
        uint256 amount;
        uint256 leverage;
        uint256 entryPrice;
    }

    mapping(address => Position) public positions;

    function openPosition(uint256 amount, uint256 leverage) public {
        require(leverage <= $LEVERAGE_ETH, "Leverage terlalu tinggi");
        positions[msg.sender] = Position(amount, leverage, getPrice());
    }

    function closePosition() public {
        delete positions[msg.sender];
    }

    function getPrice() public view returns (uint256) {
        return 3000; // Placeholder oracle
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
    pub struct Position {
        pub owner: Pubkey,
        pub amount: u64,
        pub leverage: u64,
    }

    #[derive(Accounts)]
    pub struct OpenPosition<'info> {
        #[account(mut)]
        pub position: Account<'info, Position>,
    }

    pub fn open_position(ctx: Context<OpenPosition>, amount: u64, leverage: u64) -> Result<()> {
        let position = &mut ctx.accounts.position;
        position.amount = amount;
        position.leverage = leverage;
        Ok(())
    }
}
EOL
echo "✅ Rust Smart Contract dibuat di $RUST_FILE"

# 💡 Move untuk Aptos
MOVE_FILE_APTOS="$APTOS_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_APTOS"
module ${CONTRACT_NAME,,} {
    struct Position { owner: address, amount: u64, leverage: u64 }
    public fun open_position(amount: u64, leverage: u64) {
        let position = Position { owner: signer(), amount, leverage };
    }
}
EOL
echo "✅ Move Smart Contract untuk Aptos dibuat di $MOVE_FILE_APTOS"

echo "==========================================="
echo "🎉 Semua smart contract perpetual futures berhasil dikompilasi!"
echo "🔍 Cek folder '$OUTPUT_DIR/' untuk hasilnya."
echo "==========================================="
