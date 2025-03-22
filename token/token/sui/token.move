module token {
    struct Token has store {
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        total_supply: u64,
    }

    public fun init() {
        let token = Token {
            name: b"MyToken",
            symbol: b"MTK",
            decimals: 18,,
            total_supply: 1000000,
        };
    }
}
