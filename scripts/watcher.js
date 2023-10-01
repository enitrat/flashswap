const ETH =0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
const USDT = 0x68f5c6a61780768455de69077e07e89787839bf8166decfbf92b645209c0fb8;
const POOL_ETHUSDT = {
  token0: 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7,
  token1: 0x68f5c6a61780768455de69077e07e89787839bf8166decfbf92b645209c0fb8,
  fee: 170141183460469235273462165868118016,
  tick_spacing: 1000,
  extension: 0,
};

const POOL_USDCUSDT = {
  token0: 0x53c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8,
  token1: 0x68f5c6a61780768455de69077e07e89787839bf8166decfbf92b645209c0fb8,
  fee: 34028236692093847977029636859101184,
  tick_spacing: 200,
  extension: 0,
};

const POOL_ETHUSDC = {
  token0: 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7,
  token1: 0x53c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8,
  fee: 170141183460469235273462165868118016,
  tick_spacing: 1000,
};

async function fetchRates() {
  try {
    const response = await fetch(
      "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"
    );
    const data = await response.json();
    return {
      ETH: data["ethereum"].usd,
    };
  } catch (error) {
    console.error("Error fetching ETH/USDC rate:", error);
    return null;
  }
}

async function fetchETH_USDTPrice() {
  try {
    const url =
      "https://alpha-mainnet.starknet.io/feeder_gateway/call_contract?blockNumber=pending";
    const body = {
      contract_address:
        "0x00000005dd3d2f4429af886cd1a3b08289dbcea99a294197e9eb43b0e0325b4b",
      entry_point_selector:
        "0x63ecb4395e589622a41a66715a0eac930abc9f0b92c0b1dcda630adfb2bf2d",
      calldata: [
        "2087021424722619777119509474943472645767659996348769578120564519014510906823",
        "2368576823837625528275935341135881659748932889268308403712618244410713532584",
        "170141183460469235273462165868118016",
        "1000",
        "0",
      ],
    };
    console.log(JSON.stringify(body));
    const response = await fetch(url, {
      method: "POST",
      body: JSON.stringify(body),
      headers: {
        "Content-Type": "application/json",
      },
    });
    const data = await response.json();
    console.log(data);
    const [low, high] = data.result.slice(0, 2);
    console.log(low, high);
    const sqrt_ratio = (Number(high) + Number(low) / 2 ** 128) * 1000000;
    const price = sqrt_ratio * sqrt_ratio;
    console.log(price);
    return price;
  } catch (error) {
    console.error("Error fetching ETH/USDC rate:", error);
    return null;
  }
}

async function main() {
  const offchain_rate = await fetchRates();
  const onchain_rate = await fetchETH_USDTPrice();
  // check if arbirtrage is possible by more than 0.8%

  if (offchain_rate && offchain_rate > 1.008 * onchain_rate) {
    //Possible
    const amount_from = 10 * 10**18;
    const route_1 = {
        pool_key: POOL_ETHUSDT,
        token_from:
    }
  }
}

main();
