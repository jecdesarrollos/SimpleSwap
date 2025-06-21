# SimpleSwap
Implementation of a UniswapV2 style contract as assignment for the ETH-KIPU MODULE 3. The contract is written in Solidity ^0.8.27 and uses OpenZeppelin libraries.
ERC20 - safeERC20 - IERC20 - MATH 

## 📜 Description

`SimpleSwap.sol` is a smart contract that allows users to perform three main actions on a pair of ERC20 tokens:
1.  **Add Liquidity:** User can deposit a pair of tokens to become Liquidity Provider (LP).
2.  **Remove Liquidity:** LP can withdraw his share of the tokens from the pool.
3.  **Swap Tokens:** Users can trade one token for the other.

A key feature of this implementation is that the `SimpleSwap` contract itself functions as a real, transferable **ERC20 LP Token**, representing a provider's share in the liquidity pool.

## ✨ Key Features

-   **ERC20 - ERC20 Liquidity Pools:** Create liquidity pools for any pair of ERC20 tokens.
-   **ERC20 LP Token:** Mints a standard and transferable ERC20 token ("SLP") to liquidity providers.
-   **Proportional Liquidity Logic:** Uses sqrt(x*y) for initial liquidity calculation.
-   **0.3% Trading Fee:** A 0.3% fee is applied to every swap, which is accrued by the liquidity providers.
-   **Slippage Protection:** All liquidity and swap functions include minimum amount parameters to protect users from price volatility.
-   **Deadline Protection:** All transactions have a 'deadline' parameter.
-   **Emergency Fund Recovery:** Includes owneronly functions just in case.

## 📁 Contracts

The project contains the following contracts:

-   `SimpleSwap.sol`: The core AMM pair contract. It inherits from OpenZeppelin's `ERC20` and `Ownable`.
-   `MyTokenA.sol` and `MyTokenB.sol`: ERC20 tokens used for testing and deployment.
-   `Math.sol`: A direct copy of the `Math` library from Uniswap V2, used for its gas-efficient square root function.
-   `SwapVerifier.sol`: The verifier contract provided by the course instructor to test the functionality.

## 📝 Implementation Notes

### `swapExactTokensForTokens` Return Value

The assignment's written specification mentioned that `swapExactTokensForTokens` should return a `uint[] memory amounts`. However, the provided `SwapVerifier.sol` contract expects this function to have **no return value**.

This implementation follows the `SwapVerifier.sol` as the technical source of truth. Therefore, the function signature is `... external;` to ensure compatibility and successful verification.

## 🚀 Getting Started

### Prerequisites

-   [Node.js](https://nodejs.org/en/)
-   [Foundry](https://getfoundry.sh/) or [Hardhat](https://hardhat.org/)

### Installation & Deployment

1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/jecdesarrollos/your-new-repo-name.git](https://github.com/jecdesarrollos/your-new-repo-name.git)
    cd your-new-repo-name
    ```

2.  **Install dependencies (if using Hardhat):**
    ```sh
    npm install
    ```

3.  **Set up environment variables:**
    Create a `.env` file and add your `SEPOLIA_RPC_URL` and `PRIVATE_KEY`.

4.  **Deploy the contracts:**
    ```sh
    # Example using Hardhat
    npx hardhat run scripts/deploy.js --network sepolia
    ```

## ✍️ Author

**Jorge Enrique Cabrera - 2025-EDP-TTPM-M3**

-   GitHub: [@jecdesarrollos](https://github.com/jecdesarrollos)
