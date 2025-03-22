// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract swap {
    address public tokenA = address(0xETH);
    address public tokenB = address(0xUSDC);
    uint256 public fee = 1;

    event Swap(address indexed sender, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    function swap(address tokenIn, uint256 amountIn) public {
        require(tokenIn == tokenA || tokenIn == tokenB, "Invalid token");
        address tokenOut = tokenIn == tokenA ? tokenB : tokenA;
        uint256 amountOut = amountIn * (100 - fee) / 100;
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }
}
