
// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;


// File: @openzeppelin/contracts/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: ISimpleSwap.sol


pragma solidity ^0.8.27;

/// @title Interface for SimpleSwap
/// @notice SwapVerifier interface to ensure compatibility
interface ISimpleSwap {
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
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getPrice(address tokenA, address tokenB)
        external
        view
        returns (uint256 price);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256);
}
// File: Math.sol


pragma solidity ^0.8.27;

/// @title Mathematical Utilities
/// @author Based on the implementation from Uniswap V2 / Solmate
/// @notice Provides safe and gas-efficient math functions, such as this integer square root calculation.
library Math {
    /**
     * @notice Calculates the integer square root of a number `y`.
     * @dev Uses the Babylonian method (or Heron's method) to find the square root iteratively.
     * The result is truncated, meaning any fractional part is discarded. For example, sqrt(10) will return 3.
     * This implementation is gas-efficient and safe against overflows for uint256 values.
     * @param y The number for which to calculate the square root.
     * @return z The integer square root of `y`.
     */
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
// File: SimpleSwap.sol


pragma solidity ^0.8.27;





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
    //                      AMM LOGIC FUNCTIONS
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
