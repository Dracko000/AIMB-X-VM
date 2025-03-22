module perpetual {
    struct Position { owner: address, amount: u64, leverage: u64 }
    public fun open_position(amount: u64, leverage: u64) {
        let position = Position { owner: signer(), amount, leverage };
    }
}
