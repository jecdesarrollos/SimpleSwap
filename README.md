**SimpleSwap - Solidity Project**

**Description**

This project is a simplified, Uniswap V2-style Automated Market Maker (AMM) built as a final assignment for a Solidity course. The core SimpleSwap.sol contract allows users to create liquidity pools for ERC20 token pairs, swap tokens, and provide/remove liquidity.

A key architectural feature of this implementation is that SimpleSwap.sol is a self-contained contract. It does not inherit from OpenZeppelin's ERC20 standard. Instead, it natively implements the required ERC20 functionality for its Liquidity Provider (LP) tokens. This design gives the contract the necessary control to interact with the course's SwapVerifier.

**Core Features**

ERC20-ERC20 Liquidity Pools: Supports the creation of liquidity pools for any pair of ERC20 tokens.

Native LP Tokens: The contract itself acts as the LP token, tracking providers' shares in the pool.

MINIMUM_LIQUIDITY Protection: Implements the standard protection mechanism by minting a small, permanent amount of liquidity to the zero address upon pool creation to increase the cost of initial price manipulation.

Fee-less Swaps: Swaps are calculated using the pure constant product formula (x * y = k) without any additional protocol fees, as per the assignment requirements.

Custom Errors: Uses custom errors instead of require strings for optimized gas usage and modern Solidity best practices.

Deadline Protection: All state-changing functions include a deadline parameter to protect users from unfavorable transaction execution due to network delays.

**Contracts Overview**

**SimpleSwap.sol:** The core AMM and LP token contract.

**SimpleSwap_flattened.sol:** Flattened source used for deployment and verification

**MyTokenA.sol & MyTokenB.sol:** Simple ERC20 token contracts used for testing. They include a public mint function.

**SwapVerifier.sol:** The instructor-provided contract used to run a series of automated checks against the SimpleSwap implementation.

**ISimpleSwap.sol:** The interface that the SimpleSwap contract must adhere to.

**Math.sol:** A library for performing square root calculations, based on the Uniswap V2 implementation.

**standard-json-input.json:** Contains the full compiler configuration and input details used for contract verification on Sepolia via Etherscan's Standard JSON Input.

**compiler_config.json:** Stores the Solidity compiler version and optimization settings used during contract compilation.

**Functions Interface (API)**

This section details the main functions a front-end or external contract would interact with.

**addLiquidity**

Adds liquidity to an ERC20-ERC20 pair.

function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

**Parameters:**

tokenA, tokenB: The addresses of the pair's tokens.

amountADesired, amountBDesired: The amount of each token the user wishes to deposit.

amountAMin, amountBMin: The minimum amounts to deposit, providing slippage protection.

to: The address that will receive the LP tokens.

deadline: A Unix timestamp after which the transaction will revert.

**Returns:**

amountA, amountB: The actual amounts of tokens deposited.

liquidity: The amount of LP tokens minted to the to address.

**removeLiquidity**
Removes liquidity from a pair by burning LP tokens.

function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB);

**Parameters:**

tokenA, tokenB: The addresses of the pair's tokens.

liquidity: The amount of LP tokens to burn.

amountAMin, amountBMin: The minimum amounts of underlying tokens to receive.

to: The address that will receive the withdrawn tokens.

deadline: A Unix timestamp after which the transaction will revert.

**Returns:**

amountA, amountB: The actual amounts of tokens withdrawn.

**swapExactTokensForTokens**

Swaps an exact amount of an input token for as many output tokens as possible.

function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external;

**Parameters:**

amountIn: The exact amount of input tokens to swap.

amountOutMin: The minimum amount of output tokens the user will accept.

path: An array of two token addresses: [inputToken, outputToken].

to: The address that will receive the output tokens.

deadline: A Unix timestamp after which the transaction will revert.

**getAmountOut (View)**

Calculates the amount of output tokens received for a given input amount.

function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
) public pure returns (uint256 amountOut);

**Parameters:**

amountIn: The amount of input tokens.

reserveIn, reserveOut: The current reserves of the input and output tokens in the pair.

**Returns:**

amountOut: The calculated amount of output tokens.

**Verification Steps**

To successfully verify the SimpleSwap contract, the SwapVerifier must be used on a clean, undeployed state. The following steps must be followed exactly:

Deploy Contracts:
Deploy all four contracts (MyTokenA, MyTokenB, SwapVerifier, SimpleSwap) to a fresh network environment (e.g., after reloading the Remix VM). 

Mint Initial Tokens:
The end-user account (EOA) must mint a supply of test tokens to itself. For the test, mint at least 1000e18 of both MyTokenA and MyTokenB to your primary account.

Fund the SwapVerifier:
The SwapVerifier requires its own balance of tokens to run the tests. Transfer the full amount of tokens minted in the previous step from your EOA to the SwapVerifier's address.

Execute Verification:
Call the verify function on the SwapVerifier contract with the required parameters (addresses, amounts, and author name). If all steps are followed correctly on a clean state, the transaction will succeed, confirming that the SimpleSwap implementation has passed all checks.

**Deployed Addresses**

Final deployment addresses on the Sepolia testnet.

Contract Address SimpleSwap 0xB6F592571fc0bf98443812e2906933D1cBCA9b03

MyTokenA 0xcadc59c17bca1b52bfe93a33c945575fefe585bd

MyTokenB 0xda4631dd3f48d9c059ba30f77159cd921177ffc6

SwapVerifier 0x9f8f02dab384dddf1591c3366069da3fb0018220

Successful verification transaction: 0x77843ee2e4b6cd032b455ea618fe9c7c78c2a6a70213a297a9807786485e05a4

**Author
Jorge Enrique Cabrera**
