use ekubo::interfaces::core::{PoolKey, SwapParameters};
use starknet::ContractAddress;

#[derive(Drop, Serde)]
struct FlashSwapParams {
    token_from: ContractAddress,
    initial_pool_key: PoolKey,
    initial_params: SwapParameters,
    routes: Array<Route>,
}

#[derive(Copy, Drop, Serde, starknet::Event)]
struct FlashSwapResult {
    token: ContractAddress,
    gains: u128,
}


#[derive(Drop, Serde)]
struct Route {
    pool_key: PoolKey,
    route_parameters: RouteParameters,
    token_from: ContractAddress,
    token_to: ContractAddress
}

#[derive(Copy, Drop, Serde)]
struct RouteParameters {
    is_token1: bool,
    sqrt_ratio_limit: u256,
    skip_ahead: u32,
}

