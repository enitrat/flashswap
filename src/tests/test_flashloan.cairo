// use openzeppelin::token::erc20::interface::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
// use debug::PrintTrait;
// use flashswap::common_pools::testnet;
// #[test]
// #[fork("GOERLI_LATEST")]
// fn test_snforge_fork() {
//     let eth = IERC20CamelDispatcher { contract_address: testnet::ETH() };
//     let balance = eth.balanceOf(testnet::ETH());
//     balance.print()
// }

use snforge_std::start_mock_call;
use snforge_std::{declare, ContractClassTrait};
use flashswap::flashloaner::{IFlashLoanerTestDispatcher, IFlashLoanerTestDispatcherTrait};
use flashswap::common_pools::testnet;
use ekubo::types::{i129::i129, delta::Delta};
use flashswap::mocks::mock_ekubo;
use ekubo::interfaces::core::{PoolKey, SwapParameters};
use flashswap::model::{FlashSwapParams, Route};
use snforge_std::start_prank;


use debug::PrintTrait;


#[test]
fn test_flashloan_contract() {
    let mock_ekubo = declare('MockEkubo');
    let mock_ekubo_address = mock_ekubo.deploy(@ArrayTrait::new()).unwrap();

    let addr = starknet::get_contract_address();

    let contract = declare('FlashLoanerTest');
    let mut constructor_calldata = array![addr.into(), mock_ekubo_address.into()];
    let flashswap_address = contract.deploy(@constructor_calldata).unwrap();
    mock_ekubo_address.print();
    flashswap_address.print();

    // Create a Dispatcher object that will allow interacting with the deployed contract
    let dispatcher = IFlashLoanerTestDispatcher { contract_address: flashswap_address };

    // Values don't matter as swap results are hardcoded per token.
    let initial_pool_key = PoolKey {
        token0: testnet::USDC(),
        token1: testnet::ETH(),
        fee: 3000,
        tick_spacing: 100,
        extension: 0.try_into().unwrap()
    };
    let amount_from = 1000;

    let mut routes: Array<Route> = Default::default();
    routes
        .append(
            Route {
                pool_key: PoolKey {
                    token0: testnet::USDC(),
                    token1: testnet::ETH(),
                    fee: 3000,
                    tick_spacing: 100,
                    extension: 0.try_into().unwrap()
                },
                token_from: testnet::ETH(),
                token_to: testnet::USDT(),
            }
        );
    routes
        .append(
            Route {
                pool_key: PoolKey {
                    token0: testnet::ETH(),
                    token1: testnet::USDT(),
                    fee: 3000,
                    tick_spacing: 100,
                    extension: 0.try_into().unwrap()
                },
                token_from: testnet::ETH(),
                token_to: testnet::USDT(),
            }
        );
    routes
        .append(
            Route {
                pool_key: PoolKey {
                    token0: testnet::USDT(),
                    token1: testnet::USDC(),
                    fee: 3000,
                    tick_spacing: 100,
                    extension: 0.try_into().unwrap()
                },
                token_from: testnet::USDT(),
                token_to: testnet::USDC(),
            }
        );

    let mut params = FlashSwapParams { amount_from, routes: routes, };

    start_prank(dispatcher.contract_address, mock_ekubo_address);
    dispatcher.flashloan_swap(params);
}
