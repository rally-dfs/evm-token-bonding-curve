// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/RallyV1Curve.sol";
import "../src/RallyV1CurveFactory.sol";

contract RallyV1CurveFactoryTest is Test {
  RallyV1CurveFactory factory;

  function setUp() public {
    factory = new RallyV1CurveFactory();
  }

  function testDeploy() public {
    address token0 = 0xb07Dad0000000000000000000000000000000000;
    address token1 = 0xb07dAd0000000000000000000000000000000001;

    address curveAddress = factory.deployCurve(token0, token1);

    assertFalse(curveAddress == address(0x0));
  }

  function testDuplicateDeploy() public {
    address token0 = 0xb07Dad0000000000000000000000000000000000;
    address token1 = 0xb07dAd0000000000000000000000000000000001;

    factory.deployCurve(token0, token1);
    vm.expectRevert();
    factory.deployCurve(token0, token1);
  }

  function testParameterPassing() public {
    address token0 = 0xb07Dad0000000000000000000000000000000000;
    address token1 = 0xb07dAd0000000000000000000000000000000001;

    RallyV1Curve curve = RallyV1Curve(factory.deployCurve(token0, token1));

    assertEq(address(factory), curve.factory());
    assertEq(token0, curve.token0());
    assertEq(token1, curve.token1());
  }
}
