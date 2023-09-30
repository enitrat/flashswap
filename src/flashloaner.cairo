use ekubo::interfaces::core::{PoolKey, SwapParameters};
use starknet::ContractAddress;
use openzeppelin::token::erc20::interface::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
use flashswap::model::{FlashSwapParams, Route, FlashSwapResult};

#[starknet::interface]
trait IFlashLoanerTest<TContractState> {
    fn flashloan_swap(
        ref self: TContractState, flashswap_params: FlashSwapParams
    ) -> FlashSwapResult;

    fn locked(ref self: TContractState, id: u32, data: Array<felt252>) -> Array<felt252>;
    fn upgrade(ref self: TContractState, new_implementation: starknet::ClassHash);
}


#[starknet::contract]
mod FlashLoanerTest {
    use openzeppelin::token::erc20::interface::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use starknet::ContractAddress;
    use ekubo::interfaces::core::{ICoreDispatcher, ICoreDispatcherTrait, SwapParameters, PoolKey};
    use starknet::{get_caller_address};
    use ekubo::types::{delta::Delta, i129::i129};
    use starknet::get_contract_address;
    use flashswap::model::{FlashSwapParams, Route, FlashSwapResult};
    use flashswap::utils::compute_gains;
    use integer::BoundedInt;

    const RECEIVER: felt252 = 0x0079D9CB40139969C1af50CfeBc7a246761c423dfa4e045af2777Ef571f292Bf;


    #[storage]
    struct Storage {
        owner: ContractAddress,
        ekubo_core: ContractAddress,
    }

    // #[event]
    // #[derive(Drop, starknet::Event)]
    // enum Event {
    //     FlashSwapResult: FlashSwapResult,
    // }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, ekubo_core: ContractAddress) {
        self.owner.write(owner);
        self.ekubo_core.write(ekubo_core);
    }

    #[external(v0)]
    impl FlashLoanerTestImpl of super::IFlashLoanerTest<ContractState> {
        fn flashloan_swap(
            ref self: ContractState, flashswap_params: FlashSwapParams
        ) -> FlashSwapResult {
            // assert(get_caller_address() == self.owner.read(), 'only owner');

            // Serialize the params to pass to the callback
            let mut arr: Array<felt252> = ArrayTrait::new();
            Serde::<FlashSwapParams>::serialize(@flashswap_params, ref arr);
            let r = ICoreDispatcher { contract_address: self.ekubo_core.read() }.lock(arr);

            // Deserialize the result from the callback
            let mut data = r.span();
            let mut result: FlashSwapResult = Serde::<FlashSwapResult>::deserialize(ref data)
                .expect('DESERIALIZE_RESULT_FAILED');
            // self.emit(result);
            result
        }

        /// Internally swaps token on Ekubo. Doesn't require any token transfers, since
        /// the swap is done on Ekubo's core contract only, which tracks pending
        /// balances internally and doesn't trigger token transfers.
        /// # Arguments
        /// * `id` - Ekubo internal identifier.
        /// * `data` - Data passed to the callback. Expected to be deserializable into FlashSwapParams.
        fn locked(ref self: ContractState, id: u32, data: Array<felt252>) -> Array<felt252> {
            let caller = get_caller_address();
            let ekubo_core = self.ekubo_core.read();
            assert(caller == ekubo_core, 'UNAUTHORIZED_CALLBACK');

            let mut data_span = data.span();
            let params = Serde::<FlashSwapParams>::deserialize(ref data_span).unwrap();

            // Start with the first swap with amounts calculated off-chain

            // Let's consider a swap of X USDC -> ETH -> wstETH -> USDC
            // USDC -> ETH (1) -> wstETH (2) -> USDC (3)
            // (1) USDC: +X, ETH: -Y,
            // (2) ETH: +Y, wstETH: -Z,
            // (3) wstETH: +Z, USDC: -S (X + benefits)
            // Result: USDC: -benefits

            // Each swap generates a "delta", but does not trigger any token transfers.
            // A negative delta indicates you are owed tokens. A positive delta indicates core owes you tokens.

            // The delta of the last swap should be -(X + benefits) USDC. The flashswap arbitrage is a success if S+X < 0.
            // You can simply withdraw tokens from ekubo without ever needing to transfer tokens to ekubo.
            // We need to explicitly pass the amount of the first swap. After that, we only use the output from the previous step.

            let first_route: Route = (*params.routes[0]);
            let token_from = first_route.token_from;

            let (first_delta, last_delta, is_first_token1, is_last_token1) = execute_routes(
                @self, params.amount_from, params.routes.span()
            );

            let gains = compute_gains(first_delta, last_delta, is_first_token1, is_last_token1);

            // A false sign means that Ekubo owes us tokens that we can withdraw
            assert(gains.sign == false, 'NEGATIVE_GAINS');

            // To take a negative delta out of core, do (assuming token0 for token1):
            ICoreDispatcher { contract_address: ekubo_core }
                .withdraw(token_from, RECEIVER.try_into().unwrap(), gains.mag);

            // Data returned from the hook
            let mut arr: Array<felt252> = ArrayTrait::new();
            let result = FlashSwapResult { token: token_from, gains: gains.mag, };
            Serde::<FlashSwapResult>::serialize(@result, ref arr);
            arr
        }

        fn upgrade(ref self: ContractState, new_implementation: starknet::ClassHash) {
            assert(get_caller_address() == RECEIVER.try_into().unwrap(), 'UNAUTHORIZED_UPGRADE');
            starknet::syscalls::replace_class_syscall(new_implementation);
        }
    // fn set_ekubo_core(ref self: ContractState, ekubo_core: ContractAddress) {
    //     assert(get_caller_address() == OWNER.try_into().unwrap(), 'UNAUTHORIZED_CALL');
    //     self.ekubo_core.write(ekubo_core)
    // }
    }

    fn execute_routes(
        self: @ContractState, amount_from: u128, mut routes: Span<Route>
    ) -> (Delta, Delta, bool, bool) {
        let mut last_delta: Delta = Zeroable::zero();
        let mut first_delta: Delta = Zeroable::zero();
        let mut i = 0;
        let mut is_output_token1 = false;
        let mut is_first_token1 = false;
        loop {
            if i == routes.len() {
                break;
            }
            let route: Route = *routes[i];
            let is_from_token1 = route.pool_key.token1 == route.token_from;
            // The swap amount is the output of the previous swap. We use it
            // as input to avoid any debt to the ekubo protocol.

            // First iteration: use the amount_from parameter to determine sizing
            let swap_amt = if last_delta.amount0.sign && i != 0 {
                i129 { mag: last_delta.amount0.mag, sign: true }
            } else if i != 0 {
                i129 { mag: last_delta.amount1.mag, sign: true }
            } else {
                is_first_token1 = is_from_token1;
                i129 { mag: amount_from, sign: true }
            };
            last_delta = ICoreDispatcher { contract_address: self.ekubo_core.read() }
                .swap(
                    route.pool_key,
                    SwapParameters {
                        amount: swap_amt,
                        is_token1: is_from_token1,
                        sqrt_ratio_limit: BoundedInt::<u256>::max(),
                        skip_ahead: 0
                    }
                );
            if i == 0 {
                first_delta = last_delta;
            }
            //is_token1 refers to the token that is being swapped out. if is_token1 is false (means token0 -> token1) then the last output of the rout is token1
            is_output_token1 = !is_from_token1;
            i += 1;
        };
        (first_delta, last_delta, is_first_token1, is_output_token1)
    }
}
