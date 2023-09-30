mod mainnet {
    use ekubo::interfaces::core::{PoolKey, SwapParameters};
    use starknet::ContractAddress;

    fn USDT() -> ContractAddress {
        0x68f5c6a61780768455de69077e07e89787839bf8166decfbf92b645209c0fb8.try_into().unwrap()
    }

    fn USDC() -> ContractAddress {
        0x53c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8.try_into().unwrap()
    }

    fn ETH() -> ContractAddress {
        0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7.try_into().unwrap()
    }

    fn empty_ext() -> ContractAddress {
        0.try_into().unwrap()
    }
    fn pool_usdc_usdt_0_3() -> PoolKey {
        PoolKey {
            token0: USDC(),
            token1: USDT(),
            fee: 1020847100762815411640772995208708096,
            tick_spacing: 5982,
            extension: empty_ext()
        }
    }


    fn pool_usdc_usdt_0_05() -> PoolKey {
        PoolKey {
            token0: USDC(),
            token1: USDT(),
            fee: 170141183460469235273462165868118016,
            tick_spacing: 1000,
            extension: empty_ext()
        }
    }

    fn pool_usdc_usdt_0_01() -> PoolKey {
        PoolKey {
            token0: USDC(),
            token1: USDT(),
            fee: 34028236692093847977029636859101184,
            tick_spacing: 200,
            extension: empty_ext()
        }
    }

    fn pool_eth_usdc_0_3() -> PoolKey {
        PoolKey {
            token0: ETH(),
            token1: USDC(),
            fee: 1020847100762815411640772995208708096,
            tick_spacing: 19802,
            extension: empty_ext()
        }
    }

    fn pool_eth_usdc_0_05() -> PoolKey {
        PoolKey {
            token0: ETH(),
            token1: USDC(),
            fee: 170141183460469235273462165868118016,
            tick_spacing: 1000,
            extension: empty_ext()
        }
    }
}

mod testnet {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use ekubo::interfaces::core::{PoolKey, SwapParameters};
    use starknet::ContractAddress;

    fn USDT() -> ContractAddress {
        0x68f5c6a61780768455de69077e07e89787839bf8166decfbf92b645209c0fb8.try_into().unwrap()
    }

    fn USDC() -> ContractAddress {
        0x5a643907b9a4bc6a55e9069c4fd5fd1f5c79a22470690f75556c4736e34426.try_into().unwrap()
    }

    fn ETH() -> ContractAddress {
        0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7.try_into().unwrap()
    }

    fn EKUBO_CORE() -> ContractAddress {
        0x031e8a7ab6a6a556548ac85cbb8b5f56e8905696e9f13e9a858142b8ee0cc221.try_into().unwrap()
    }

    fn empty_ext() -> ContractAddress {
        0.try_into().unwrap()
    }
    fn pool_eth_usdc_0_05() -> PoolKey {
        PoolKey {
            token0: USDC(),
            token1: ETH(),
            fee: 170141183460469235273462165868118016,
            tick_spacing: 1000,
            extension: empty_ext()
        }
    }
}
