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
SYMBOL=$(grep "symbol:" "$INPUT_FILE" | cut -d '"' -f2)
DECIMALS=$(grep "decimals:" "$INPUT_FILE" | awk -F ': ' '{print $2}')
TOTAL_SUPPLY=$(grep "totalSupply:" "$INPUT_FILE" | awk -F ': ' '{print $2}')

# Tampilkan Informasi
echo "📝 Nama Kontrak  : $CONTRACT_NAME"
echo "🔹 Token Name    : $NAME"
echo "🔹 Symbol        : $SYMBOL"
echo "🔹 Decimals      : $DECIMALS"
echo "🔹 Total Supply  : $TOTAL_SUPPLY"
echo "📁 Output Folder : $OUTPUT_DIR"
echo "-------------------------------------------"

# 💡 Generate Solidity untuk Ethereum
SOL_FILE="$ETHEREUM_DIR/$CONTRACT_NAME.sol"
cat <<EOL > "$SOL_FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    string public name = "$NAME";
    string public symbol = "$SYMBOL";
    uint8 public decimals = $DECIMALS;
    uint256 public totalSupply = $TOTAL_SUPPLY;

    mapping(address => uint256) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
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
    pub struct MintToken<'info> {
        #[account(init, payer = user, mint::decimals = $DECIMALS)]
        pub mint: Account<'info, Mint>,
        #[account(mut)]
        pub user: Signer<'info>,
        pub system_program: Program<'info, System>,
    }

    pub fn mint(ctx: Context<MintToken>, amount: u64) -> Result<()> {
        let mint = &mut ctx.accounts.mint;
        mint.supply += amount;
        Ok(())
    }
}
EOL
echo "✅ Rust Smart Contract dibuat di $RUST_FILE"

# 💡 Generate Move untuk Aptos
MOVE_FILE_APTOS="$APTOS_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_APTOS"
module ${CONTRACT_NAME,,} {
    struct Token has store {
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        total_supply: u64,
    }

    public fun init() {
        let token = Token {
            name: b"$NAME",
            symbol: b"$SYMBOL",
            decimals: $DECIMALS,
            total_supply: $TOTAL_SUPPLY,
        };
    }
}
EOL
echo "✅ Move Smart Contract untuk Aptos dibuat di $MOVE_FILE_APTOS"

# 💡 Generate Move untuk Sui
MOVE_FILE_SUI="$SUI_DIR/$CONTRACT_NAME.move"
cat <<EOL > "$MOVE_FILE_SUI"
module ${CONTRACT_NAME,,} {
    struct Token has store {
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        total_supply: u64,
    }

    public fun init() {
        let token = Token {
            name: b"$NAME",
            symbol: b"$SYMBOL",
            decimals: $DECIMALS,
            total_supply: $TOTAL_SUPPLY,
        };
    }
}
EOL
echo "✅ Move Smart Contract untuk Sui dibuat di $MOVE_FILE_SUI"

# 💡 Generate FunC untuk TON
FUNC_FILE="$TON_DIR/$CONTRACT_NAME.fc"
cat <<EOL > "$FUNC_FILE"
;; TON Token Contract
global get_name
global get_symbol
global get_decimals
global get_total_supply

;; Data storage
data (name "$NAME")
data (symbol "$SYMBOL")
data (decimals $DECIMALS)
data (total_supply $TOTAL_SUPPLY)

;; Getter functions
void get_name() { return name }
void get_symbol() { return symbol }
void get_decimals() { return decimals }
void get_total_supply() { return total_supply }
EOL
echo "✅ FunC Smart Contract untuk TON dibuat di $FUNC_FILE"

echo "==========================================="
echo "🎉 Semua smart contract berhasil dikompilasi!"
echo "🔍 Cek folder '$OUTPUT_DIR/' untuk melihat hasilnya."
echo "==========================================="
