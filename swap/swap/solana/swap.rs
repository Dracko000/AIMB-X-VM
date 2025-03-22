use anchor_lang::prelude::*;

#[program]
pub mod swap {
    use super::*;

    #[derive(Accounts)]
    pub struct Swap<'info> {
        #[account(mut)]
        pub sender: Signer<'info>,
    }

    pub fn swap(ctx: Context<Swap>, amount_in: u64) -> Result<()> {
        let fee = 1;
        let amount_out = amount_in * (100 - fee) / 100;
        msg!("Swapped {} tokens, received {}", amount_in, amount_out);
        Ok(())
    }
}
