// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IRallyV1Curve {
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function initialPrice() external view returns (uint256);

  function initialSupply() external view returns (uint256);

  function slopeNumerator() external view returns (uint256);

  function slopeDenominator() external view returns (uint256);

  function getReserves()
    external
    view
    returns (uint112 reserve0, uint112 reserve1);

  function kLast() external view returns (uint256);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;
}
