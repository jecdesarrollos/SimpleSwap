// SPDX-License-Identifier: MIT
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
     * @return z The integer (truncated) square root of `y`.
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