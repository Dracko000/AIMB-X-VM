use anchor_lang::prelude::*;

#[program]
pub mod token {
    use super::*;

    #[derive(Accounts)]
    pub struct MintToken<'info> {
        #[account(init, payer = user, mint::decimals = 18,)]
        pub mint: Account<'info, Mint>,
        #[account(mut)]
        pub user: Signer<'info>,
        pub system_program: Program<'info, System>,
    }

    pub fn mint(ctx: Context<MintToken>, amount: u64) -> Result<()> {
        let mint = &mut ctx.accounts.mint;
        mint.supply += amount;
        Ok(())
    }
}
