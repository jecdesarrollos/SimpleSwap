// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ISimpleSwap.sol";
import "./Math.sol";

/// @title SimpleSwap
/// @author Jorge Enrique Cabrera
/// @notice A self-contained Uniswap V2-style Automated Market Maker contract.
contract SimpleSwap is Ownable, ISimpleSwap {
    using SafeERC20 for IERC20;

    // =============================================================
    //                      STATE & CONSTANTS
    // =============================================================

    /// @notice The name of the Liquidity Provider (LP) token.
    string public constant name = "SimpleSwap LPToken";
    /// @notice The symbol of the Liquidity Provider (LP) token.
    string public constant symbol = "LPT";
    /// @notice The decimals of the Liquidity Provider (LP) token.
    uint8 public constant decimals = 18;
    /// @notice The total supply of LP tokens.
    uint256 public totalSupply;
    
    /// @notice A mapping from an account to its LP token balance.
    mapping(address => uint256) public balanceOf;
    /// @notice A mapping from an owner to a spender to the spender's allowance.
    mapping(address => mapping(address => uint256)) public allowance;

    /// @notice The minimum amount of liquidity burned upon pool creation.
    /// @dev This protects against initial liquidity provider price manipulation attacks.
    uint256 public constant MINIMUM_LIQUIDITY = 1e3;

    /// @notice Mapping from a sorted token pair to their reserves.
    /// @dev Access is always via `reserves[token0][token1]` where token0 is the lower address.
    mapping(address => mapping(address => PairReserves)) public reserves;

    /// @notice Struct to hold the reserves for a token pair.
    struct PairReserves {
        uint256 reserveA; // Corresponds to the reserve of the token with the lower address (_token0)
        uint256 reserveB; // Corresponds to the reserve of the token with the higher address (_token1)
    }

    // =============================================================
    //                        CUSTOM ERRORS
    // =============================================================
    error SimpleSwap__IdenticalTokens();
    error SimpleSwap__Expired();
    error SimpleSwap__InsufficientAmountA();
    error SimpleSwap__InsufficientAmountB();
    error SimpleSwap__InsufficientOutputAmount();
    error SimpleSwap__InsufficientLiquidity();
    error SimpleSwap__InvalidLiquidity();
    error SimpleSwap__ZeroInitialLiquidity();
    error SimpleSwap__InvalidPath();
    error SimpleSwap__ZeroInputAmount();
    error SimpleSwap__NoEthToWithdraw();
    error SimpleSwap__EthTransferFailed();
    error SimpleSwap__NoTokensToRecover();
    error SimpleSwap__InsufficientBalance();
    error SimpleSwap__InsufficientAllowance();

    // =============================================================
    //                            EVENTS
    // =============================================================

    /// @notice Emitted when an approval is made.
    /// @param owner The address which granted the approval.
    /// @param spender The address which was approved to spend the tokens.
    /// @param value The amount of tokens approved.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Emitted when tokens are transferred.
    /// @param from The address from which tokens were sent.
    /// @param to The address to which tokens were sent.
    /// @param value The amount of tokens transferred.
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /// @notice Emitted when liquidity is added to a pair.
    /// @param tokenA The address of one of the tokens in the pair.
    /// @param tokenB The address of the other token in the pair.
    /// @param amountA The amount of tokenA added.
    /// @param amountB The amount of tokenB added.
    /// @param liquidity The amount of LP tokens minted.
    event LiquidityAdded(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @notice Emitted when liquidity is removed from a pair.
    /// @param tokenA The address of one of the tokens in the pair.
    /// @param tokenB The address of the other token in the pair.
    /// @param amountA The amount of tokenA returned.
    /// @param amountB The amount of tokenB returned.
    /// @param liquidity The amount of LP tokens burned.
    event LiquidityRemoved(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @notice Emitted when a token swap occurs.
    /// @param tokenIn The address of the token being sent to the pool.
    /// @param tokenOut The address of the token being received from the pool.
    /// @param amountIn The amount of `tokenIn` sent.
    /// @param amountOut The amount of `tokenOut` received.
    /// @param to The final recipient of the output tokens.
    event Swapped(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut, address indexed to);

    // =============================================================
    //                           MODIFIERS
    // =============================================================

    /// @notice The transaction is executed before the deadline.
    /// @param deadline The timestamp by which the transaction must be executed.
    modifier checkDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert SimpleSwap__Expired();
        _;
    }

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    /// @notice Sets the initial owner of the contract.
    /// @param initialOwner The address that will become the owner of the contract.
    constructor(address initialOwner) Ownable(initialOwner) {}

    // =============================================================
    //                      LOGIC FUNCTIONS
    // =============================================================

    /// @inheritdoc ISimpleSwap
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
        checkDeadline(deadline)
        returns (uint256 amountA, uint256 amountB, uint256 liquidity)
    {
        (address _token0, address _token1) = _sortTokens(tokenA, tokenB);
        PairReserves storage pair = reserves[_token0][_token1];
        uint256 reserve0 = pair.reserveA;
        uint256 reserve1 = pair.reserveB;
        uint256 currentTotalSupply = totalSupply;

        if (currentTotalSupply == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            uint256 amountBOptimal = (amountADesired * reserve1) / reserve0;
            if (amountBOptimal <= amountBDesired) {
                if (amountBOptimal < amountBMin) revert SimpleSwap__InsufficientAmountB();
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint256 amountAOptimal = (amountBDesired * reserve0) / reserve1;
                if (amountAOptimal < amountAMin) revert SimpleSwap__InsufficientAmountA();
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        }
        
        if (amountA < amountAMin) revert SimpleSwap__InsufficientAmountA();
        if (amountB < amountBMin) revert SimpleSwap__InsufficientAmountB();

        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        if (currentTotalSupply == 0) {
            liquidity = Math.sqrt(amountA * amountB);
            if (liquidity <= MINIMUM_LIQUIDITY) revert SimpleSwap__ZeroInitialLiquidity();
            liquidity = liquidity - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); 
        } else {
            uint256 liquidity0 = (amountA * currentTotalSupply) / reserve0;
            uint256 liquidity1 = (amountB * currentTotalSupply) / reserve1;
            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        }

        _updateReserves(tokenA, tokenB, int256(amountA), int256(amountB));
        _mint(to, liquidity);

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB, liquidity);
    }

    /// @inheritdoc ISimpleSwap
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external override checkDeadline(deadline) returns (uint256 amountA, uint256 amountB) {
        (address _token0, address _token1) = _sortTokens(tokenA, tokenB);
        PairReserves storage pair = reserves[_token0][_token1];
        
        if (liquidity == 0 || liquidity > balanceOf[msg.sender]) revert SimpleSwap__InvalidLiquidity();

        uint256 currentTotalSupply = totalSupply;
        amountA = (liquidity * pair.reserveA) / currentTotalSupply;
        amountB = (liquidity * pair.reserveB) / currentTotalSupply;

        _burn(msg.sender, liquidity);

        if (tokenA != _token0) (amountA, amountB) = (amountB, amountA);
        
        if (amountA < amountAMin) revert SimpleSwap__InsufficientAmountA();
        if (amountB < amountBMin) revert SimpleSwap__InsufficientAmountB();
        
        if (tokenA == _token0) {
            _updateReserves(tokenA, tokenB, -int256(amountA), -int256(amountB));
        } else {
            _updateReserves(tokenA, tokenB, -int256(amountB), -int256(amountA));
        }

        IERC20(tokenA).safeTransfer(to, amountA);
        IERC20(tokenB).safeTransfer(to, amountB);

        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB, liquidity);
    }

    /// @inheritdoc ISimpleSwap
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override checkDeadline(deadline) {
        if (path.length != 2) revert SimpleSwap__InvalidPath();
        
        address tokenIn = path[0];
        address tokenOut = path[1];
        
        (uint256 reserveIn, uint256 reserveOut) = _getReservesByTokens(tokenIn, tokenOut);
        
        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        if (amountOut < amountOutMin) revert SimpleSwap__InsufficientOutputAmount();

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        
        _updateReserves(tokenIn, tokenOut, int256(amountIn), -int256(amountOut));

        IERC20(tokenOut).safeTransfer(to, amountOut);

        emit Swapped(tokenIn, tokenOut, amountIn, amountOut, to);
    }

    // =============================================================
    //                  NATIVE ERC20 IMPLEMENTATION
    // =============================================================

    /// @notice Approves a spender to use the caller's LP tokens.
    /// @param spender The address to approve.
    /// @param value The amount of LP tokens to approve.
    /// @return success True if the approval was successful.
    function approve(address spender, uint256 value) external returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @notice Transfers LP tokens from the caller to a recipient.
    /// @param to The address of the recipient.
    /// @param value The amount of LP tokens to transfer.
    /// @return success True if the transfer was successful.
    function transfer(address to, uint256 value) external returns (bool success) {
        if (balanceOf[msg.sender] < value) revert SimpleSwap__InsufficientBalance();
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /// @notice Transfers LP tokens from one account to another, using the allowance mechanism.
    /// @param from The address of the token owner.
    /// @param to The address of the recipient.
    /// @param value The amount of LP tokens to transfer.
    /// @return success True if the transfer was successful.
    function transferFrom(address from, address to, uint256 value) external returns (bool success) {
        if (allowance[from][msg.sender] < value) revert SimpleSwap__InsufficientAllowance();
        if (balanceOf[from] < value) revert SimpleSwap__InsufficientBalance();
        
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    // =============================================================
    //                 VIEW & INTERNAL HELPER FUNCTIONS
    // =============================================================
    
    /// @notice Internal function to mint LP tokens.
    /// @dev Can mint to address(0) to implement the MINIMUM_LIQUIDITY burn.
    /// @param to The address to mint the tokens to.
    /// @param value The amount of LP tokens to mint.
    function _mint(address to, uint256 value) internal {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    /// @notice Internal function to burn LP tokens.
    /// @param from The address from which to burn the tokens.
    /// @param value The amount of LP tokens to burn.
    function _burn(address from, uint256 value) internal {
        if (balanceOf[from] < value) revert SimpleSwap__InsufficientBalance();
        totalSupply -= value;
        balanceOf[from] -= value;
        emit Transfer(from, address(0), value);
    }
    
    /// @inheritdoc ISimpleSwap
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure override returns (uint256 amountOut) {
        if (amountIn == 0) revert SimpleSwap__ZeroInputAmount();
        if (reserveIn == 0 || reserveOut == 0) revert SimpleSwap__InsufficientLiquidity();
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;
        amountOut = numerator / denominator;
    }

    /// @inheritdoc ISimpleSwap
    function getPrice(address tokenA, address tokenB) external view override returns (uint256 price) {
        (uint reserveA, uint reserveB) = _getReservesByTokens(tokenA, tokenB);
        if (reserveA == 0 || reserveB == 0) revert SimpleSwap__InsufficientLiquidity();
        price = (reserveB * 1e18) / reserveA;
    }
    
    /// @notice Sorts two token addresses to ensure a canonical representation of a pair.
    /// @dev The pair is always represented as (lower_address, higher_address).
    /// @param tokenA The address of the first token.
    /// @param tokenB The address of the second token.
    /// @return token0 The token with the lower address.
    /// @return token1 The token with the higher address.
    function _sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        if (tokenA == tokenB) revert SimpleSwap__IdenticalTokens();
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
    
    /// @notice Gets the reserves for a token pair, returned in the same order as the input tokens.
    /// @param tokenA The address of the first token.
    /// @param tokenB The address of the second token.
    /// @return reserveA The reserve corresponding to tokenA.
    /// @return reserveB The reserve corresponding to tokenB.
    function _getReservesByTokens(address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address _token0, address _token1) = _sortTokens(tokenA, tokenB);
        PairReserves storage pair = reserves[_token0][_token1];
        (reserveA, reserveB) = tokenA == _token0 ? (pair.reserveA, pair.reserveB) : (pair.reserveB, pair.reserveA);
    }
    
    /// @notice Updates the pair's reserves after a state-changing operation.
    /// @dev Handles the correct assignment of amounts based on the canonical token order.
    /// @param tokenA The first token of the operation.
    /// @param tokenB The second token of the operation.
    /// @param amountA The change in the amount of tokenA (can be negative).
    /// @param amountB The change in the amount of tokenB (can be negative).
    function _updateReserves(address tokenA, address tokenB, int256 amountA, int256 amountB) private {
        (address _token0, address _token1) = _sortTokens(tokenA, tokenB);
        PairReserves storage pair = reserves[_token0][_token1];
        if (tokenA == _token0) {
            pair.reserveA = uint256(int256(pair.reserveA) + amountA);
            pair.reserveB = uint256(int256(pair.reserveB) + amountB);
        } else {
            pair.reserveA = uint256(int256(pair.reserveA) + amountB);
            pair.reserveB = uint256(int256(pair.reserveB) + amountA);
        }
    }

    // =============================================================
    //                 EMERGENCY RECOVERY FUNCTIONS
    // =============================================================
    
    /// @notice Allows the contract to receive Ether.
    receive() external payable {}

    /// @notice Allows the owner to withdraw any ETH accidentally sent to this contract.
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert SimpleSwap__NoEthToWithdraw();
        (bool success, ) = owner().call{value: balance}("");
        if (!success) revert SimpleSwap__EthTransferFailed();
    }

    /// @notice Allows the owner to recover any arbitrary ERC20 token sent to this contract.
    /// @param tokenAddress The address of the ERC20 token to recover.
    function recoverERC20(address tokenAddress) external onlyOwner {
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        if (tokenBalance == 0) revert SimpleSwap__NoTokensToRecover();
        IERC20(tokenAddress).safeTransfer(owner(), tokenBalance);
    }
}
