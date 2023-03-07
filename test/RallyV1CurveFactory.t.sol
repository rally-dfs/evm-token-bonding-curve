// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/RallyV1Curve.sol";
import "../src/RallyV1CurveFactory.sol";
import "../src/libraries/RallyV1CurveLibrary.sol";
import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";

contract RallyV1CurveFactoryTest is Test {
  RallyV1CurveFactory factory;
  MockERC20 token0;
  MockERC20 token1;
  uint256 slopeNumerator = 10000;
  uint256 slopeDenominator = 5000;
  uint256 initialPrice = 1000;
  uint256 initialSupply = 1000;

  function setUp() public {
    token0 = new MockERC20("TBCToken0", "T0", 18);
    token1 = new MockERC20("TBCToken1", "T1", 18);

    token0.mint(address(this), 10 ether);
    token1.mint(address(this), 10 ether);

    factory = new RallyV1CurveFactory();

    token0.approve(address(factory), 1);
    token1.approve(address(factory), 10 ether);
  }

  function testDeploy() public {
    address curveAddress = factory.deployCurve(
      address(token0),
      address(token1),
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );

    assertFalse(curveAddress == address(0x0));
  }

  function testDuplicateDeploy() public {
    factory.deployCurve(
      address(token0),
      address(token1),
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );

    vm.expectRevert();
    factory.deployCurve(
      address(token0),
      address(token1),
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );
  }

  function testParameterPassing() public {
    RallyV1Curve curve = RallyV1Curve(
      factory.deployCurve(
        address(token0),
        address(token1),
        slopeNumerator,
        slopeDenominator,
        initialPrice,
        initialSupply
      )
    );

    assertEq(address(factory), curve.factory());
    assertEq(address(token0), curve.token0());
    assertEq(address(token1), curve.token1());
    assertEq(slopeNumerator, curve.slopeNumerator());
    assertEq(slopeDenominator, curve.slopeDenominator());
    assertEq(initialPrice, curve.initialPrice());
    assertEq(initialSupply, curve.initialSupply());
  }

  function testDeterministicAddress() public {
    RallyV1Curve deployedCurve = RallyV1Curve(
      factory.deployCurve(
        address(token0),
        address(token1),
        slopeNumerator,
        slopeDenominator,
        initialPrice,
        initialSupply
      )
    );

    address curve = RallyV1CurveLibrary.curveFor(
      address(factory),
      address(token0),
      address(token1),
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    );

    assertEq(address(deployedCurve), curve);
  }
}
