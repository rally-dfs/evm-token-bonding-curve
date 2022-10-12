// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/RallyV1Curve.sol";
import "../src/RallyV1CurveFactory.sol";

contract RallyV1CurveFactoryTest is Test {
  RallyV1CurveFactory factory;

  address token0 = 0xb07Dad0000000000000000000000000000000000;
  address token1 = 0xb07dAd0000000000000000000000000000000001;
  uint256 slopeNumerator = 10000;
  uint256 slopeDenominator = 5000;
  uint256 initialPrice = 1000;
  uint256 initialSupply = 1000;

  function setUp() public {
    factory = new RallyV1CurveFactory();
  }

  function testDeploy() public {
    address curveAddress = factory.deployCurve(
      token0,
      token1,
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );

    assertFalse(curveAddress == address(0x0));
  }

  function testDuplicateDeploy() public {
    factory.deployCurve(
      token0,
      token1,
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );

    vm.expectRevert();
    factory.deployCurve(
      token0,
      token1,
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );
  }

  function testParameterPassing() public {
    RallyV1Curve curve = RallyV1Curve(
      factory.deployCurve(
        token0,
        token1,
        slopeNumerator,
        slopeDenominator,
        initialPrice,
        initialSupply
      )
    );

    assertEq(address(factory), curve.factory());
    assertEq(token0, curve.token0());
    assertEq(token1, curve.token1());
    assertEq(slopeNumerator, curve.slopeNumerator());
    assertEq(slopeDenominator, curve.slopeDenominator());
    assertEq(initialPrice, curve.initialPrice());
    assertEq(initialSupply, curve.initialSupply());
  }
}
