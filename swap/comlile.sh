#!/bin/bash

echo "==========================================="
echo "🚀 AIMB Smart Contract Compiler for DeFi Swap"
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

# Buat folder output berdasarkan nama file
ETHEREUM_DIR="$OUTPUT_DIR/ethereum"
SOLANA_DIR="$OUTPUT_DIR/solana"
APTOS_DIR="$OUTPUT_DIR/aptos"
SUI_DIR="$OUTPUT_DIR/sui"
TON_DIR="$OUTPUT_DIR/ton"

mkdir -p "$ETHEREUM_DIR" "$SOLANA_DIR" "$APTOS_DIR" "$SUI_DIR" "$TON_DIR"

# Baca file .sync
TOKEN_A=$(grep "tokenA:" "$INPUT_FILE" | cut -d '"' -f2)
TOKEN_B=$(grep "tokenB:" "$INPUT_FILE" | cut -d '"' -f2)
FEE=$(grep "fee:" "$INPUT_FILE" | awk -F ': ' '{print $2}')

# Tampilkan Informasi
echo "📝 Nama Kontrak  : $CONTRACT_NAME"
echo "🔹 Token A       : $TOKEN_A"
echo "🔹 Token B       : $TOKEN_B"
echo "🔹 Swap Fee      : $FEE%"
echo "📁 Output Folder : $OUTPUT_DIR"
echo "-------------------------------------------"

# 💡 Generate Solidity untuk Ethereum
SOL_FILE="$ETHEREUM_DIR/$CONTRACT_NAME.sol"
cat <<EOL > "$SOL_FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    address public tokenA = address(0x$TOKEN_A);
    address public tokenB = address(0x$TOKEN_B);
    uint256 public fee = $FEE;

    event Swap(address indexed sender, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    function swap(address tokenIn, uint256 amountIn) public {
        require(tokenIn == tokenA || tokenIn == tokenB, "Invalid token");
        address tokenOut = tokenIn == tokenA ? tokenB : tokenA;
        uint256 amountOut = amountIn * (100 - fee) / 100;
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }
}
EOL
echo "✅ Solidity Smart Contract dibuat di $SOL_FILE"

# 💡 Generate Rust untuk Solana
RUST_FILE="$SOLANA_DIR/$CONTRACT_NAME.rs"
cat <<EOL > "$RUST_FILE"
use anchor_lang::prelude::*;

#[program]
pub mod ${CONTRACT_NAME,,} {
    use super::*;

    #[derive(Accounts)]
    pub struct Swap<'info> {
        #[account(mut)]
        pub sender: Signer<'info>,
    }

    pub fn swap(ctx: Context<Swap>, amount_in: u64) -> Result<()> {
        let fee = $FEE;
        let amount_out = amount_in * (100 - fee) / 100;
        msg!("Swapped {} tokens, received {}", amount_in, amount_out);
        Ok(())
    }
}
EOL
echo "✅ Rust Smart Contract dibuat di $RUST_FILE"

# 💡 Generate Move untuk Aptos
MOVE_FILE_APTOS="$APTOS_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_APTOS"
module ${CONTRACT_NAME,,} {
    struct Swap has store {
        token_a: vector<u8>,
        token_b: vector<u8>,
        fee: u8,
    }

    public fun execute_swap(amount_in: u64): u64 {
        let fee = $FEE;
        return (amount_in * (100 - fee)) / 100;
    }
}
EOL
echo "✅ Move Smart Contract untuk Aptos dibuat di $MOVE_FILE_APTOS"

# 💡 Generate Move untuk Sui
MOVE_FILE_SUI="$SUI_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_SUI"
module ${CONTRACT_NAME,,} {
    struct Swap has store {
        token_a: vector<u8>,
        token_b: vector<u8>,
        fee: u8,
    }

    public fun execute_swap(amount_in: u64): u64 {
        let fee = $FEE;
        return (amount_in * (100 - fee)) / 100;
    }
}
EOL
echo "✅ Move Smart Contract untuk Sui dibuat di $MOVE_FILE_SUI"

# 💡 Generate FunC untuk TON
FUNC_FILE="$TON_DIR/$CONTRACT_NAME.fc"
cat <<EOL > "$FUNC_FILE"
;; TON Swap Contract
global execute_swap

data (fee $FEE)

void execute_swap(int amount_in) {
    return amount_in * (100 - fee) / 100;
}
EOL
echo "✅ FunC Smart Contract untuk TON dibuat di $FUNC_FILE"

echo "==========================================="
echo "🎉 Semua smart contract berhasil dikompilasi!"
echo "🔍 Cek folder '$OUTPUT_DIR/' untuk melihat hasilnya."
echo "==========================================="
