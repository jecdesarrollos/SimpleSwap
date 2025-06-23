// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// External Imports
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Local Imports
import {ISimpleSwap} from "./ISimpleSwap.sol";
import {Math} from "./Math.sol";

/// @title Uniswap v2 Style Smart Contract for swapping ERC20 tokens.
/// @author Jorge Enrique Cabrera
/// @notice This contract allows for the creation of liquidity pools, swapping of tokens,
/// and functions as its own ERC20 Liquidity Provider (LPT) token.
contract SimpleSwap is Ownable, ISimpleSwap, ERC20 {
    using SafeERC20 for IERC20;

    /// @notice Mapping from a sorted token pair to their reserves.
    /// @dev Access is always via reserves[token0][token1] where token0 is the lower address.
    mapping(address => mapping(address => PairReserves)) public reserves;

    /// @notice Struct to hold the reserves for a token pair.
    struct PairReserves {
        uint256 reserveA; // Corresponds to the reserve of the token with the lower address (_token0)
        uint256 reserveB; // Corresponds to the reserve of the token with the higher address (_token1)
    }

    /// @notice Emitted when liquidity is added to a pair.
    event LiquidityAdded(
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    /// @notice Emitted when liquidity is removed from a pair.
    event LiquidityRemoved(
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    /// @notice Emitted when a token swap occurs.
    event Swapped(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        address indexed to
    );

    /// @notice Sets the initial owner of the contract and initializes the LPT token.
    /// @param initialOwner The address that will become the owner of the contract.
    constructor(address initialOwner)
        Ownable(initialOwner)
        ERC20("SimpleSwap LPToken", "LPT")
    {}

    /// @notice Special function to receive ETH sent accidentally to the contract.
    receive() external payable {}

    /**
     * @notice Sorts two token addresses to ensure a canonical representation of a pair.
     * @dev The pair is always represented as (lower_address, higher_address).
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * @return token0 The token with the lexicographically lower address.
     * @return token1 The token with the lexicographically higher address.
     */
    function _sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "SimpleSwap: IDENTICAL_TOKENS");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
    }

    /// @notice Adds liquidity to an ERC-20 to ERC-20 pair, minting LP tokens for the provider.
    /// @param tokenA The address of one of the tokens in the pair.
    /// @param tokenB The address of the other token in the pair.
    /// @param amountADesired The desired amount of tokenA to add.
    /// @param amountBDesired The desired amount of tokenB to add.
    /// @param amountAMin The minimum amount of tokenA to add, for slippage protection.
    /// @param amountBMin The minimum amount of tokenB to add, for slippage protection.
    /// @param to The address that will receive the minted LP tokens.
    /// @param deadline A timestamp by which the transaction must be executed.
    /// @return amountA The actual amount of tokenA that was added to the pool.
    /// @return amountB The actual amount of tokenB that was added to the pool.
    /// @return liquidity The amount of LP tokens that were minted.
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        override
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        require(block.timestamp <= deadline, "SimpleSwap: EXPIRED");
        (address _token0, address _token1) = _sortTokens(tokenA, tokenB);
        PairReserves storage pair = reserves[_token0][_token1];
        uint256 reserve0 = pair.reserveA;
        uint256 reserve1 = pair.reserveB;
        uint256 totalLiquiditySupply = totalSupply();

        if (totalLiquiditySupply == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            uint256 amountBOptimal = (amountADesired * reserve1) / reserve0;
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "SimpleSwap: UNDER_B_MIN"
                );
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint256 amountAOptimal = (amountBDesired * reserve0) / reserve1;
                require(
                    amountAOptimal >= amountAMin,
                    "SimpleSwap: UNDER_A_MIN"
                );
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        }
        require(amountA >= amountAMin, "SimpleSwap: UNDER_A_MIN");
        require(amountB >= amountBMin, "SimpleSwap: UNDER_B_MIN");

        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        if (totalLiquiditySupply == 0) {
            liquidity = Math.sqrt(amountA * amountB);
            require(liquidity > 0, "SimpleSwap: ZERO_INIT_LIQ");
        } else {
            uint256 liquidity0 = (amountA * totalLiquiditySupply) / reserve0;
            uint256 liquidity1 = (amountB * totalLiquiditySupply) / reserve1;
            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        }

        if (tokenA == _token0) {
            pair.reserveA += amountA;
            pair.reserveB += amountB;
        } else {
            pair.reserveA += amountB;
            pair.reserveB += amountA;
        }
        _mint(to, liquidity);

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB, liquidity);
    }

    /// @notice Removes liquidity from a pair by burning the user's LP tokens.
    /// @param tokenA The address of one of the tokens in the pair.
    /// @param tokenB The address of the other token in the pair.
    /// @param liquidity The amount of LP tokens to burn.
    /// @param amountAMin The minimum amount of tokenA to receive, for slippage protection.
    /// @param amountBMin The minimum amount of tokenB to receive, for slippage protection.
    /// @param to The address that will receive the underlying tokens.
    /// @param deadline A timestamp by which the transaction must be executed.
    /// @return amountA The actual amount of tokenA received.
    /// @return amountB The actual amount of tokenB received.
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external override returns (uint256 amountA, uint256 amountB) {
        require(block.timestamp <= deadline, "SimpleSwap: EXPIRED");
        (address _token0, address _token1) = _sortTokens(tokenA, tokenB);
        PairReserves storage pair = reserves[_token0][_token1];

        uint256 totalLiquiditySupply = totalSupply();
        uint256 balance = balanceOf(msg.sender);
        require(
            liquidity > 0 && liquidity <= balance,
            "SimpleSwap: INVALID_LIQUIDITY"
        );

        amountA =
            (liquidity * (tokenA == _token0 ? pair.reserveA : pair.reserveB)) /
            totalLiquiditySupply;
        amountB =
            (liquidity * (tokenB == _token0 ? pair.reserveB : pair.reserveA)) /
            totalLiquiditySupply;

        require(amountA >= amountAMin, "SimpleSwap: UNDER_A_MIN");
        require(amountB >= amountBMin, "SimpleSwap: UNDER_B_MIN");

        _burn(msg.sender, liquidity);

        if (tokenA == _token0) {
            pair.reserveA -= amountA;
            pair.reserveB -= amountB;
        } else {
            pair.reserveA -= amountB;
            pair.reserveB -= amountA;
        }

        IERC20(tokenA).safeTransfer(to, amountA);
        IERC20(tokenB).safeTransfer(to, amountB);

        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB, liquidity);
    }

    /// @notice Swaps an exact amount of input tokens for as many output tokens as possible.
    /// @dev The path is restricted to a length of 2 (direct swaps only).
    /// @param amountIn The exact amount of input tokens to send.
    /// @param amountOutMin The minimum amount of output tokens expected, for slippage protection.
    /// @param path An array of token addresses representing the swap route. [inputToken, outputToken].
    /// @param to The address that will receive the output tokens.
    /// @param deadline A timestamp by which the transaction must be executed.
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override {
        require(block.timestamp <= deadline, "SimpleSwap: EXPIRED");
        require(path.length == 2, "SimpleSwap: INVALID_PATH");

        address tokenIn = path[0];
        address tokenOut = path[1];
        (address _token0, address _token1) = _sortTokens(tokenIn, tokenOut);
        PairReserves storage pair = reserves[_token0][_token1];

        uint256 reserveIn;
        uint256 reserveOut;
        if (tokenIn == _token0) {
            reserveIn = pair.reserveA;
            reserveOut = pair.reserveB;
        } else {
            reserveIn = pair.reserveB;
            reserveOut = pair.reserveA;
        }

        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "SimpleSwap: LOW_OUTPUT");

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).safeTransfer(to, amountOut);

        if (tokenIn == _token0) {
            pair.reserveA += amountIn;
            pair.reserveB -= amountOut;
        } else {
            pair.reserveA -= amountOut;
            pair.reserveB += amountIn;
        }

        emit Swapped(tokenIn, tokenOut, amountIn, amountOut, to);
    }

    /// @notice Calculates the amount of output tokens received for a given input amount.
    /// @dev Includes a 0.3% trading fee, consistent with Uniswap V2.
    /// @param amountIn The amount of input tokens.
    /// @param reserveIn The reserve of the input token in the pool.
    /// @param reserveOut The reserve of the output token in the pool.
    /// @return amountOut The calculated amount of output tokens.
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override returns (uint256 amountOut) {
        require(amountIn > 0, "SimpleSwap: ZERO_INPUT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "SimpleSwap: INSUFFICIENT_LIQUIDITY"
        );

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    /// @notice Returns the instantaneous price of a token pair, calculated from reserves.
    /// @dev The price is returned as a fixed-point number, scaled by 1e18.
    /// @param tokenA The address of the first token.
    /// @param tokenB The address of the second token.
    /// @return price The price of tokenA in terms of tokenB, scaled by 1e18.
    function getPrice(address tokenA, address tokenB)
        external
        view
        override
        returns (uint256 price)
    {
        (address _token0, address _token1) = _sortTokens(tokenA, tokenB);
        PairReserves storage pair = reserves[_token0][_token1];
        uint256 reserve0 = pair.reserveA;
        uint256 reserve1 = pair.reserveB;
        require(reserve0 > 0 && reserve1 > 0, "SimpleSwap: NO_LIQUIDITY");

        if (tokenA == _token0) {
            price = (reserve1 * 1e18) / reserve0;
        } else {
            price = (reserve0 * 1e18) / reserve1;
        }
    }

    // --- Emergency Recovery Functions ---

    /// @notice Allows the contract owner to withdraw any ETH accidentally sent to this contract.
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "SimpleSwap: NO_ETH_TO_WITHDRAW");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "SimpleSwap: ETH_TRANSFER_FAILED");
    }

    /// @notice Allows the contract owner to recover any arbitrary ERC20 token accidentally sent to this contract.
    /// @param tokenAddress The address of the ERC20 token to recover.
    function recoverERC20(address tokenAddress) external onlyOwner {
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        require(tokenBalance > 0, "SimpleSwap: NO_TOKENS_TO_RECOVER");
        IERC20(tokenAddress).safeTransfer(owner(), tokenBalance);
    }
}
