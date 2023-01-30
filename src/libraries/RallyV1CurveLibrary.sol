// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "../RallyV1Curve.sol";

library RallyV1CurveLibrary {
  function curveFor(
    address factory,
    address token0,
    address token1,
    uint256 slopeNumerator,
    uint256 slopeDenominator,
    uint256 initialPrice,
    uint256 initialSupply
  ) internal pure returns (address curve) {
    curve = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              factory,
              keccak256(
                abi.encode(
                  token0,
                  token1,
                  slopeNumerator,
                  slopeDenominator,
                  initialPrice,
                  initialSupply
                )
              ),
              keccak256(type(RallyV1Curve).creationCode)
            )
          )
        )
      )
    );
  }

  // given an input amount of token1 calculate the amount of token0 to be received by the user
  function getAmountToken0(
    uint256 amountToken1,
    uint256 initialSupply,
    uint256 balance0,
    uint256 balance1,
    uint256 initialPrice,
    uint256 slopeNumerator,
    uint256 slopeDenominator
  ) internal pure returns (uint256 amountToken0) {
    uint256 c = initialSupply - (balance1 + amountToken1);
    uint256 r0 = initialPrice;
    uint256 r1 = (slopeNumerator * c) / slopeDenominator + initialPrice;
    uint256 area = ((r0 + r1) * c) / 2;
    amountToken0 = balance0 - area;
  }

  // given an input amount of token0 calculate the amount of token1 to be received by the user
  function getAmountToken1(
    uint256 amountToken0,
    uint256 initialSupply,
    uint256 balance0,
    uint256 balance1,
    uint256 initialPrice,
    uint256 slopeNumerator,
    uint256 slopeDenominator
  ) internal pure returns (uint256 amountToken1) {
    uint256 guess = 0;

    while (true) {
      uint256 c = initialSupply - (balance1 - guess);
      uint256 r0 = initialPrice;
      uint256 r1 = (slopeNumerator * c) / slopeDenominator + initialPrice;
      uint256 area = ((r0 + r1) * c) / 2;
      uint256 resultAmountToken0 = area - balance0;

      if (resultAmountToken0 >= amountToken0) {
        break;
      } else {
        guess = guess + 1;
      }
    }

    amountToken1 = guess;
  }
}
