use ekubo::interfaces::core::{PoolKey, SwapParameters};
use starknet::ContractAddress;

#[derive(Drop, Serde)]
struct FlashSwapParams {
    amount_from: u128,
    routes: Array<Route>,
}

#[derive(Copy, Drop, Serde, starknet::Event)]
struct FlashSwapResult {
    token: ContractAddress,
    gains: u128,
}


#[derive(Copy, Drop, Serde)]
struct Route {
    pool_key: PoolKey,
    token_from: ContractAddress,
    token_to: ContractAddress
}
