use ekubo::types::{delta::Delta, i129::i129};
use starknet::ContractAddress;
fn compute_gains(
    first_delta: Delta, last_delta: Delta, is_first_token1: bool, is_last_token1: bool
) -> i129 {
    let mut gains: i129 = Zeroable::zero();

    if is_first_token1 {
        gains = gains + first_delta.amount1;
    } else {
        gains = gains + first_delta.amount0;
    }

    if is_last_token1 {
        gains = gains + last_delta.amount1;
    } else {
        gains = gains + last_delta.amount0;
    }

    gains
}

fn is_token_1(token_from: ContractAddress, token_to: ContractAddress) -> bool {
    let token_from:felt252 = token_from.into();
    let token_from:u256 = token_from.into();
    let token_to:felt252 = token_to.into();
    let token_to:u256 = token_to.into();
    token_from< token_to
}
