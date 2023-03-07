// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "./interfaces/IRallyV1Curve.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/RallyV1CurveLibrary.sol";

contract RallyV1Router01 {
  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
    _;
  }

  function swap0For1(
    uint256 amount0,
    uint256 amount1Min,
    address curve,
    uint256 deadline
  ) external ensure(deadline) returns (uint256 amount1) {
    (uint256 reserve0, uint256 reserve1) = IRallyV1Curve(curve).getReserves();

    uint256 initialSupply = IRallyV1Curve(curve).initialSupply();
    uint256 initialPrice = IRallyV1Curve(curve).initialPrice();
    uint256 slopeNumerator = IRallyV1Curve(curve).slopeNumerator();
    uint256 slopeDenominator = IRallyV1Curve(curve).slopeDenominator();

    amount1 = RallyV1CurveLibrary.getAmountToken1(
      amount0,
      initialSupply,
      reserve0,
      reserve1,
      initialPrice,
      slopeNumerator,
      slopeDenominator
    );

    require(amount1 >= amount1Min, "RallyV1Router: INSUFFICIENT_OUTPUT_AMOUNT");

    TransferHelper.safeTransferFrom(
      IRallyV1Curve(curve).token0(),
      msg.sender,
      curve,
      amount0
    );

    IRallyV1Curve(curve).swap(0, amount1, msg.sender, new bytes(0));
  }

  function swap1For0(
    uint256 amount1,
    uint256 amount0Min,
    address curve,
    uint256 deadline
  ) external ensure(deadline) returns (uint256 amount0) {
    (uint256 reserve0, uint256 reserve1) = IRallyV1Curve(curve).getReserves();

    uint256 initialSupply = IRallyV1Curve(curve).initialSupply();
    uint256 initialPrice = IRallyV1Curve(curve).initialPrice();
    uint256 slopeNumerator = IRallyV1Curve(curve).slopeNumerator();
    uint256 slopeDenominator = IRallyV1Curve(curve).slopeDenominator();

    amount0 = RallyV1CurveLibrary.getAmountToken0(
      amount1,
      initialSupply,
      reserve0,
      reserve1,
      initialPrice,
      slopeNumerator,
      slopeDenominator
    );

    require(amount0 >= amount0Min, "RallyV1Router: INSUFFICIENT_OUTPUT_AMOUNT");

    TransferHelper.safeTransferFrom(
      IRallyV1Curve(curve).token1(),
      msg.sender,
      curve,
      amount1
    );

    IRallyV1Curve(curve).swap(amount0, 0, msg.sender, new bytes(0));
  }
}
