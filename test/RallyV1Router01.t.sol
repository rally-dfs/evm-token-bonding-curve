// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";

import "../src/RallyV1Curve.sol";
import "../src/RallyV1CurveFactory.sol";
import "../src/RallyV1Router01.sol";
import "../src/libraries/RallyV1CurveLibrary.sol";

contract MockUser {}

contract RallyV1Router01Test is Test {
  RallyV1CurveFactory factory;
  RallyV1Curve curve;
  RallyV1Router01 router;
  MockERC20 token0;
  MockERC20 token1;
  MockUser user;
  uint256 slopeNumerator = 1;
  uint256 slopeDenominator = 1;
  uint256 initialPrice = 0;
  uint256 initialSupply = 1000;
  uint256 MAX_UINT = 2**256 - 1;

  function setUp() public {
    factory = new RallyV1CurveFactory();
    router = new RallyV1Router01();
    token0 = new MockERC20("TBCToken0", "T0", 18);
    token1 = new MockERC20("TBCToken1", "T1", 18);

    token0.mint(address(this), 10 ether);
    token1.mint(address(this), 10 ether);

    token1.approve(address(factory), 10 ether);

    curve = RallyV1Curve(
      factory.deployCurve(
        address(token0),
        address(token1),
        slopeNumerator,
        slopeDenominator,
        initialPrice,
        initialSupply
      )
    );

    user = new MockUser();
  }

  function testSwap0For1() public {
    token0.approve(address(router), 20000);

    uint256 balanceBefore = token1.balanceOf(address(this));
    router.swap0For1(20000, 0, address(curve), MAX_UINT);
    uint256 balanceAfter = token1.balanceOf(address(this));

    assertEq(balanceAfter - balanceBefore, 200);
  }

  function testSwap1For0() public {
    token0.transfer(address(curve), 20000);
    curve.swap(0, 200, address(user), new bytes(0));

    token1.approve(address(router), 20);

    uint256 balanceBefore = token0.balanceOf(address(this));
    router.swap1For0(20, 0, address(curve), MAX_UINT);
    uint256 balanceAfter = token0.balanceOf(address(this));

    assertEq(balanceAfter - balanceBefore, 3800);
  }

  function testSwap0For1TakeMore() public {
    token0.approve(address(router), 20000);

    vm.expectRevert(bytes("RallyV1Router: INSUFFICIENT_OUTPUT_AMOUNT"));
    router.swap0For1(20000, 201, address(curve), MAX_UINT);
  }

  function testSwap1For0TakeMore() public {
    token0.transfer(address(curve), 20000);
    curve.swap(0, 200, address(user), new bytes(0));

    token1.approve(address(router), 20);

    vm.expectRevert(bytes("RallyV1Router: INSUFFICIENT_OUTPUT_AMOUNT"));
    router.swap1For0(20, 3801, address(curve), MAX_UINT);
  }
}
