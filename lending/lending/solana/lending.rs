use anchor_lang::prelude::*;

#[program]
pub mod lending {
    use super::*;

    #[account]
    pub struct LendingAccount {
        pub owner: Pubkey,
        pub deposit: u64,
        pub borrow: u64,
    }

    #[derive(Accounts)]
    pub struct Deposit<'info> {
        #[account(mut)]
        pub lending_account: Account<'info, LendingAccount>,
    }

    pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
        let account = &mut ctx.accounts.lending_account;
        account.deposit += amount;
        Ok(())
    }

    pub fn borrow(ctx: Context<Deposit>, amount: u64) -> Result<()> {
        let account = &mut ctx.accounts.lending_account;
        account.borrow += amount;
        Ok(())
    }
}
