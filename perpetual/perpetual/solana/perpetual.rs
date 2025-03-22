use anchor_lang::prelude::*;

#[program]
pub mod perpetual {
    use super::*;

    #[account]
    pub struct Position {
        pub owner: Pubkey,
        pub amount: u64,
        pub leverage: u64,
    }

    #[derive(Accounts)]
    pub struct OpenPosition<'info> {
        #[account(mut)]
        pub position: Account<'info, Position>,
    }

    pub fn open_position(ctx: Context<OpenPosition>, amount: u64, leverage: u64) -> Result<()> {
        let position = &mut ctx.accounts.position;
        position.amount = amount;
        position.leverage = leverage;
        Ok(())
    }
}
