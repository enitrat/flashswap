use flashswap::utils::compute_gains;
use ekubo::types::{delta::Delta, i129::i129};
use debug::PrintTrait;

#[test]
fn test_compute_gains() {
    // USDC -> ABC: +1660, -1 (we owe 1660USDC, ekubo owes is 1ABC)
    // .... intermediate steps
    // DEF -> USDC: -10, +1670
    // In the end: all the intermediate steps cancel each other, and we're owed the benefit
    let first_delta = Delta {
        amount0: i129 { mag: 1660, sign: true }, amount1: i129 { mag: 1, sign: false }
    };

    let second_delta = Delta {
        amount0: i129 { mag: 10, sign: true }, amount1: i129 { mag: 1670, sign: false }
    };

    let gains = compute_gains(
        first_delta, second_delta, is_first_token1: false, is_last_token1: true
    );

    assert(gains.mag == 10, 'gains mag should be 10');
    assert(gains.sign == false, 'gains sign should be minus');
}
