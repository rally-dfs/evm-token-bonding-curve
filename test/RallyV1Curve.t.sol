// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";
import "../src/RallyV1Curve.sol";
import "../src/RallyV1CurveFactory.sol";

contract MockUser {}

contract RallyV1CurveTest is Test {
  RallyV1CurveFactory factory;
  RallyV1Curve curve;
  MockERC20 token0;
  MockERC20 token1;
  MockUser user;

  function setUp() public {
    factory = new RallyV1CurveFactory();
    token0 = new MockERC20("TBCToken0", "T0", 18);
    token1 = new MockERC20("TBCToken1", "T1", 18);

    token0.mint(address(this), 10 ether);
    token1.mint(address(this), 10 ether);

    uint256 slopeNumerator = 1;
    uint256 slopeDenominator = 1;
    uint256 initialPrice = 0;
    uint256 initialSupply = 1000;

    token0.approve(address(factory), 1);
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
    // transfer to maintain curve
    token0.transfer(address(curve), 20000 - 1);

    curve.swap(0, 200, address(user), new bytes(0));

    assertEq(token1.balanceOf(address(user)), 200);
  }

  function testSwap1For0() public {
    token0.transfer(address(curve), 20000 - 1);
    curve.swap(0, 200, address(user), new bytes(0));

    token1.transfer(address(curve), 20);
    curve.swap(3800, 0, address(user), new bytes(0));

    assertEq(token0.balanceOf(address(user)), 3800);
  }

  function testSwap0For1TakeMore() public {
    // transfer to maintain curve
    token0.transfer(address(curve), 20000 - 1);

    vm.expectRevert(bytes("RallyCurveV1: INVALID_BONDING"));
    curve.swap(0, 201, address(user), new bytes(0));

    assertEq(token1.balanceOf(address(user)), 0);
  }

  function testSwap1For0TakeMore() public {
    token0.transfer(address(curve), 20000 - 1);
    curve.swap(0, 200, address(user), new bytes(0));

    token1.transfer(address(curve), 20);

    vm.expectRevert(bytes("RallyCurveV1: INVALID_BONDING"));
    curve.swap(3801, 0, address(user), new bytes(0));

    assertEq(token0.balanceOf(address(user)), 0);
  }
}
