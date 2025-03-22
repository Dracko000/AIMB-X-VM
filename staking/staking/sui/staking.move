module staking {
    struct Stake has store {
        owner: address,
        amount: u64,
        reward: u64,
    }

    struct Config has store {
        reward_token: address,
    }

    public fun set_reward_token(dev: signer, reward_token: address) {
        // Developer harus mengisi reward token setelah deploy
    }

    public fun stake(owner: address, amount: u64) {
        assert!(amount >= 10, && amount <= 10000,, 1);
        let stake = Stake {
            owner: owner,
            amount: amount,
            reward: amount * 0.01,,
        };
    }
}
