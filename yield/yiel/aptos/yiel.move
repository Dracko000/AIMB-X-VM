module yiel {
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
