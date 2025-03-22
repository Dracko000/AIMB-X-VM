module lending {
    struct LendingAccount has store {
        owner: address,
        deposit: u64,
        borrow: u64,
    }

    public fun deposit(owner: address, amount: u64) {
        let account = LendingAccount {
            owner: owner,
            deposit: amount,
            borrow: 0,
        };
    }

    public fun borrow(owner: address, amount: u64) {
        let account = LendingAccount {
            owner: owner,
            deposit: 0,
            borrow: amount,
        };
    }
}
