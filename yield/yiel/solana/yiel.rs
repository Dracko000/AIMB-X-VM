use anchor_lang::prelude::*;

#[program]
pub mod yiel {
    use super::*;

    #[account]
    pub struct FarmingAccount {
        pub owner: Pubkey,
        pub stake_amount: u64,
        pub start_time: i64,
    }

    #[derive(Accounts)]
    pub struct Stake<'info> {
        #[account(mut)]
        pub farming_account: Account<'info, FarmingAccount>,
    }

    pub fn stake(ctx: Context<Stake>, amount: u64) -> Result<()> {
        let account = &mut ctx.accounts.farming_account;
        account.stake_amount += amount;
        account.start_time = Clock::get()?.unix_timestamp;
        Ok(())
    }
}
