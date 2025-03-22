module staking {
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
        assert!(amount >= 10, && amount <= 10000,, 1);
        let stake = Stake {
            owner: signer(),
            amount: amount,
            reward: amount * 0.01,,
        };
    }
}
