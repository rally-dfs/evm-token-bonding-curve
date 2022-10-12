// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./RallyV1CurveDeployer.sol";
import "./libraries/TransferHelper.sol";

contract RallyV1CurveFactory is RallyV1CurveDeployer {
  event CurveDeployed(
    address indexed curve,
    address indexed token0,
    address indexed token1
  );

  function deployCurve(
    address token0,
    address token1,
    uint256 slopeNumerator,
    uint256 slopeDenominator,
    uint256 initialPrice,
    uint256 initialSupply
  ) external returns (address curveAddress) {
    curveAddress = _deployCurve(
      token0,
      token1,
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );

    // TransferHelper.safeTransfer(token0, curveAddress, initialSupply);
  }

  function _deployCurve(
    address token0,
    address token1,
    uint256 slopeNumerator,
    uint256 slopeDenominator,
    uint256 initialPrice,
    uint256 initialSupply
  ) internal returns (address curveAddress) {
    curveAddress = deploy(
      address(this),
      token0,
      token1,
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );

    emit CurveDeployed(address(this), token0, token1);
  }
}
