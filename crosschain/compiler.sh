#!/bin/bash

# Direktori output
OUTPUT_DIR="compiled_contracts"

# Hardcoded LayerZero relayer untuk setiap blockchain
ETHEREUM_RELAYER="0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675"
ARBITRUM_RELAYER="0x3c2269811836af69497E5F486A85D7316753cf62"
SOLANA_RELAYER="J5vXNkH5x4VQzCG7rE1sFqYzrkjL4uVX6Py5TnLSnX"
APTOS_RELAYER="0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675"
SUI_RELAYER="0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675"
TON_RELAYER="0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675"

# Pastikan direktori output ada
mkdir -p "$OUTPUT_DIR/ethereum"
mkdir -p "$OUTPUT_DIR/solana"
mkdir -p "$OUTPUT_DIR/aptos"
mkdir -p "$OUTPUT_DIR/sui"
mkdir -p "$OUTPUT_DIR/ton"

# Loop semua file .sync
for FILE in *.sync; do
    CONTRACT_NAME=$(basename "$FILE" .sync)

    # Solidity (Ethereum & Arbitrum)
    SOL_FILE="$OUTPUT_DIR/ethereum/$CONTRACT_NAME.sol"
    cat <<EOL > "$SOL_FILE"
pragma solidity ^0.8.0;

contract $CONTRACT_NAME {
    address public relayer = address($ETHEREUM_RELAYER);
}
EOL

    # Solana (Rust)
    SOLANA_FILE="$OUTPUT_DIR/solana/$CONTRACT_NAME.rs"
    cat <<EOL > "$SOLANA_FILE"
pub const RELAYER: &str = "$SOLANA_RELAYER";

pub struct $CONTRACT_NAME {
    pub relayer: &'static str,
}

impl $CONTRACT_NAME {
    pub fn new() -> Self {
        Self { relayer: RELAYER }
    }
}
EOL

    # Aptos (Move)
    APTOS_FILE="$OUTPUT_DIR/aptos/$CONTRACT_NAME.move"
    cat <<EOL > "$APTOS_FILE"
module $CONTRACT_NAME {
    use LayerZero::Relayer;
    
    public fun get_relayer(): address {
        @${APTOS_RELAYER}
    }
}
EOL

    # Sui (Move)
    SUI_FILE="$OUTPUT_DIR/sui/$CONTRACT_NAME.move"
    cat <<EOL > "$SUI_FILE"
module $CONTRACT_NAME {
    const RELAYER: address = @${SUI_RELAYER};
}
EOL

    # TON (FunC)
    TON_FILE="$OUTPUT_DIR/ton/$CONTRACT_NAME.fc"
    cat <<EOL > "$TON_FILE"
data (layerzero_relayer "${TON_RELAYER}")
EOL

    echo "✅ Smart contract '$CONTRACT_NAME' berhasil dikompilasi dengan relayer LayerZero!"
done

echo "🎉 Semua smart contract selesai dikompilasi dengan alamat relayer!"
