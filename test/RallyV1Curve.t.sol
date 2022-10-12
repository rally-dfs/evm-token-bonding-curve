// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/RallyV1Curve.sol";
import "../src/RallyV1CurveFactory.sol";

contract RallyV1CurveFactoryTest is Test {
  RallyV1CurveFactory factory;
  RallyV1Curve curve;

  function setUp() public {
    factory = new RallyV1CurveFactory();
    address token0 = 0xb07Dad0000000000000000000000000000000000;
    address token1 = 0xb07dAd0000000000000000000000000000000001;
    uint256 slopeNumerator = 10000;
    uint256 slopeDenominator = 5000;
    uint256 initialPrice = 1000;
    uint256 initialSupply = 1000;

    curve = RallyV1Curve(
      factory.deployCurve(
        token0,
        token1,
        slopeNumerator,
        slopeDenominator,
        initialPrice,
        initialSupply
      )
    );
  }
}
