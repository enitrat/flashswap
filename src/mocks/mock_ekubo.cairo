use ekubo::interfaces::core::{
    ILocker, ICore, ICoreDispatcher, ICoreDispatcherTrait, SwapParameters, PoolKey
};
use ekubo::types::{delta::Delta, i129::i129};
use starknet::ContractAddress;

trait IMockEkuboTrait<TStorage> {
    fn lock(ref self: TStorage, data: Array<felt252>) -> Array<felt252>;
    fn swap(ref self: TStorage, pool_key: PoolKey, params: SwapParameters) -> Delta;
    fn withdraw(
        ref self: TStorage, token_address: ContractAddress, recipient: ContractAddress, amount: u128
    );
}

#[starknet::contract]
mod MockEkubo {
    use ekubo::interfaces::core::{
        ILocker, ILockerDispatcher, ILockerDispatcherTrait, ICore, ICoreDispatcher,
        ICoreDispatcherTrait, SwapParameters, PoolKey
    };
    use ekubo::types::{delta::Delta, i129::i129};
    use flashswap::common_pools::testnet;
    use starknet::ContractAddress;


    #[storage]
    struct Storage {}

    #[external(v0)]
    impl MockEkuboImpl of super::IMockEkuboTrait<ContractState> {
        fn lock(ref self: ContractState, data: Array<felt252>) -> Array<felt252> {
            let caller = starknet::get_caller_address();
            let res = ILockerDispatcher { contract_address: caller }.locked(0, data);
            res
        }

        fn swap(ref self: ContractState, pool_key: PoolKey, params: SwapParameters) -> Delta {
            if (pool_key.token0 == testnet::USDC() && pool_key.token1 == testnet::ETH()) {
                return Delta {
                    amount0: i129 { mag: 1660, sign: true }, amount1: i129 { mag: 1, sign: false }
                };
            }

            if (pool_key.token0 == testnet::ETH() && pool_key.token1 == testnet::USDT()) {
                return Delta {
                    amount0: i129 { mag: 1, sign: true }, amount1: i129 { mag: 1670, sign: false }
                };
            }

            if (pool_key.token0 == testnet::USDT() && pool_key.token1 == testnet::USDC()) {
                return Delta {
                    amount0: i129 { mag: 1670, sign: true },
                    amount1: i129 { mag: 1680, sign: false }
                };
            }

            panic_with_felt252('unsupported pool key')
        }

        fn withdraw(
            ref self: ContractState,
            token_address: ContractAddress,
            recipient: ContractAddress,
            amount: u128
        ) {// do nothing
        }
    }
}
