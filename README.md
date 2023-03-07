# EVM Token Bonding Curve and Swap

This is an implementation of the RLY token bonding curve written for EVM chains.

The deploy mechanism is based off of Uniswap v3 deterministic deploys and Uniswap v2 style swapping methods.

A curve with formula `a = 3b + 2` – where a is the price of a single bonded `token b` (denominated in amount of `token a`) and b is the amount of `token b` that's been swapped out of this curve – starts at a price of `2 token A in required to get 1 token B out` when 0 `token b` has been exchanged and increases by `3 token A to get 1 token B out` for every 1 `token b` that's swapped out

Under the hood it uses the integral of the price formula to calculate the amount of `token a` locked in the curve and uses that to determine the spot price and the amount of destination token to emit

Pool tokens and withdrawals of pool tokens are intentionally disabled so that liquidity can't be removed from the swap outside of the `swap` method. If more liquidity is required, a second curve can be initialized with the same slope and an appropriately set start price (e.g. the end price of the previous curve). Fees are also disabled.

See https://github.com/Uniswap/v3-core for the inspiration behind the deploy process. https://github.com/Uniswap/v2-core for the core swap method. Finally https://github.com/Uniswap/v2-periphery for the router.

# Running tests

Make sure you have a [foundry](https://github.com/foundry-rs/foundry) local install and run `git submodule update --init --recursive` to get the submodule dependencies and then run `forge test` in the root directory
