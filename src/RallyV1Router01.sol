// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;
/*
import "./interfaces/IUniswapV2Pair.sol";
import "./libraries/TransferHelper.sol";

contract UniswapV2Router02 {
  address public immutable override factory;
  address public immutable override WETH;

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
    _;
  }

  // **** SWAP ****
  // requires the initial amount to have already been sent to the first pair
  function _swap(
    uint256[] memory amounts,
    address[] memory path,
    address _to
  ) internal virtual {
    for (uint256 i; i < path.length - 1; i++) {
      (address input, address output) = (path[i], path[i + 1]);
      (address token0, ) = UniswapV2Library.sortTokens(input, output);
      uint256 amountOut = amounts[i + 1];
      (uint256 amount0Out, uint256 amount1Out) = input == token0
        ? (uint256(0), amountOut)
        : (amountOut, uint256(0));
      address to = i < path.length - 2
        ? UniswapV2Library.pairFor(factory, output, path[i + 2])
        : _to;
      IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
        amount0Out,
        amount1Out,
        to,
        new bytes(0)
      );
    }
  }

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    virtual
    override
    ensure(deadline)
    returns (uint256[] memory amounts)
  {
    amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
    );
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      UniswapV2Library.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, to);
  }

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  )
    external
    virtual
    override
    ensure(deadline)
    returns (uint256[] memory amounts)
  {
    amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
    require(
      amounts[0] <= amountInMax,
      "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
    );
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      UniswapV2Library.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, to);
  }
}
*/
