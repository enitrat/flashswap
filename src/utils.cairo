use ekubo::types::{delta::Delta, i129::i129};
fn compute_gains(
    first_delta: Delta, last_delta: Delta, is_first_token1: bool, is_last_token1: bool
) -> i129{
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
