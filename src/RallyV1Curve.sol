// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./RallyV1CurveDeployer.sol";

contract RallyV1Curve {
  address public immutable factory;
  address public immutable token0;
  address public immutable token1;

  constructor() {
    (factory, token0, token1) = RallyV1CurveDeployer(msg.sender).parameters();
  }
}
