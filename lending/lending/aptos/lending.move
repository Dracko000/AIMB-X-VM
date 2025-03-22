module lending {
    struct LendingAccount {
        owner: address,
        deposit: u64,
        borrow: u64,
    }

    public fun deposit(amount: u64) {
        let account = LendingAccount {
            owner: signer(),
            deposit: amount,
            borrow: 0,
        };
    }

    public fun borrow(amount: u64) {
        let account = LendingAccount {
            owner: signer(),
            deposit: 0,
            borrow: amount,
        };
    }
}
