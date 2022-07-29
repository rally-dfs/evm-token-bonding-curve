// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./RallyV1CurveDeployer.sol";

contract RallyV1CurveFactory is RallyV1CurveDeployer {
  event CurveDeployed(
    address indexed curve,
    address indexed token0,
    address indexed token1
  );

  function deployCurve(address token0, address token1)
    external
    returns (address curveAddress)
  {
    curveAddress = _deployCurve(token0, token1);
  }

  function _deployCurve(address token0, address token1)
    internal
    returns (address curveAddress)
  {
    curveAddress = deploy(address(this), token0, token1);

    emit CurveDeployed(address(this), token0, token1);
  }
}
