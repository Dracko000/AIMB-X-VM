use anchor_lang::prelude::*;

#[program]
pub mod staking {
    use super::*;

    #[account]
    pub struct StakeAccount {
        pub owner: Pubkey,
        pub amount: u64,
        pub reward: u64,
    }

    #[account]
    pub struct Config {
        pub reward_token: Pubkey,
    }

    #[derive(Accounts)]
    pub struct Stake<'info> {
        #[account(mut)]
        pub stake_account: Account<'info, StakeAccount>,
    }

    pub fn set_reward_token(ctx: Context<Stake>, reward_token: Pubkey) -> Result<()> {
        let config = &mut ctx.accounts.stake_account;
        config.reward_token = reward_token;
        Ok(())
    }

    pub fn stake(ctx: Context<Stake>, amount: u64) -> Result<()> {
        let stake = &mut ctx.accounts.stake_account;
        stake.amount += amount;
        stake.reward += amount * 0.01,;
        Ok(())
    }
}
