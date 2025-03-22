module swap {
    struct Swap has store {
        token_a: vector<u8>,
        token_b: vector<u8>,
        fee: u8,
    }

    public fun execute_swap(amount_in: u64): u64 {
        let fee = 1;
        return (amount_in * (100 - fee)) / 100;
    }
}
