// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20Minimal.sol";
import "./interfaces/IUniswapV2Callee.sol";

import "./libraries/TransferHelper.sol";

import "./RallyV1CurveDeployer.sol";

contract RallyV1Curve {
  address public immutable factory;
  address public immutable token0;
  address public immutable token1;

  bool public immutable isToken0Bonded;

  uint256 public immutable initialPrice;
  uint256 public immutable initialSupply;
  uint256 public immutable slopeNumerator;
  uint256 public immutable slopeDenominator;

  uint112 private reserve0;
  uint112 private reserve1;

  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  constructor() {
    (
      factory,
      token0,
      token1,
      slopeNumerator,
      slopeDenominator,
      initialPrice,
      initialSupply
    ) = RallyV1CurveDeployer(msg.sender).parameters();
    // TODO: unlike univ2 TBC curves aren't symmetric. token0 is the bound token and token1 is the reserve token
    // is not the same as token1 being the bound token and token0 being the reserve token
    // naming is hard so not changing away from token0/token1 until we have a better idea
    isToken0Bonded = true;
  }

  uint256 private unlocked = 1;
  modifier lock() {
    require(unlocked == 1, "UniswapV2: LOCKED");
    unlocked = 0;
    _;
    unlocked = 1;
  }

  function getReserves()
    public
    view
    returns (uint112 _reserve0, uint112 _reserve1)
  {
    _reserve0 = reserve0;
    _reserve1 = reserve1;
  }

  /// @dev Get the pool's balance of token0
  /// @dev This function is gas optimized to avoid a redundant extcodesize check in addition to the returndatasize
  /// check
  function balance0() private view returns (uint256) {
    (bool success, bytes memory data) = token0.staticcall(
      abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, address(this))
    );
    require(success && data.length >= 32);
    return abi.decode(data, (uint256));
  }

  /// @dev Get the pool's balance of token1
  /// @dev This function is gas optimized to avoid a redundant extcodesize check in addition to the returndatasize
  /// check
  function balance1() private view returns (uint256) {
    (bool success, bytes memory data) = token1.staticcall(
      abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, address(this))
    );
    require(success && data.length >= 32);
    return abi.decode(data, (uint256));
  }

  // update reserves and, on the first call per block, price accumulators
  function _update(uint256 _balance0, uint256 _balance1) private {
    reserve0 = uint112(_balance0);
    reserve1 = uint112(_balance1);
    emit Sync(reserve0, reserve1);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external lock {
    require(
      amount0Out > 0 || amount1Out > 0,
      "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT"
    );
    require(
      (amount0Out > 0 && amount1Out == 0) ||
        (amount0Out == 0 && amount1Out > 0),
      "RallyCurveV1: INVALID_OUTPUT_AMOUNT"
    );
    (uint112 _reserve0, uint112 _reserve1) = getReserves(); // gas savings
    require(
      amount0Out < _reserve0 && amount1Out < _reserve1,
      "UniswapV2: INSUFFICIENT_LIQUIDITY"
    );

    uint256 _balance0;
    uint256 _balance1;
    {
      // scope for _token{0,1}, avoids stack too deep errors
      address _token0 = token0;
      address _token1 = token1;
      require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO");
      if (amount0Out > 0) TransferHelper.safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
      if (amount1Out > 0) TransferHelper.safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
      if (data.length > 0) {
        IUniswapV2Callee(to).uniswapV2Call(
          msg.sender,
          amount0Out,
          amount1Out,
          data
        );
      }
      _balance0 = balance0();
      _balance1 = balance1();
    }

    uint256 amount0In = _balance0 > _reserve0 - amount0Out
      ? _balance0 - (_reserve0 - amount0Out)
      : 0;
    uint256 amount1In = _balance1 > _reserve1 - amount1Out
      ? _balance1 - (_reserve1 - amount1Out)
      : 0;
    require(
      amount0In > 0 || amount1In > 0,
      "UniswapV2: INSUFFICIENT_INPUT_AMOUNT"
    );

    {
      // scope for reserve{0,1}Adjusted, avoids stack too deep errors
      uint256 balance0Adjusted = _balance0; // no fee currently: balance0.mul(1000).sub(amount0In.mul(3));
      uint256 balance1Adjusted = _balance1; // no fee currently: balance1.mul(1000).sub(amount1In.mul(3));
      // require(
      //   balance0Adjusted * balance1Adjusted >=
      //     uint256(_reserve0) * uint256(_reserve1), // no fee currently: .mul(1000**2),
      //   "UniswapV2: K"
      // );

      /*
        // area of trapezoid 
               / |
              /  |
             /   |
            /    | r1
           |     |
        r0 |     |
           |_____|
              c

        c is the number of bonded tokens that have been transferred out
          initialBondedSupply - currentBondedBalance
        r0 is the initial price
        r1 is the current price (slope * c + initialPrice)
        area = (r0 + r1) * c / 2
      */

      uint256 c = initialSupply -
        (isToken0Bonded ? balance0Adjusted : balance1Adjusted);
      uint256 r0 = initialPrice;
      uint256 r1 = (slopeNumerator * c) / slopeDenominator + initialPrice;
      uint256 area = ((r0 + r1) * c) / 2;
      uint256 baseTokenBalance = isToken0Bonded
        ? balance1Adjusted
        : balance0Adjusted;

      require(baseTokenBalance >= area, "RallyCurveV1: INVALID_BONDING");

      /*
      if (isToken0Bonded && amount0Out == 0 || !isToken0Bonded && amount1Out == 0) {
        // bonded token is being transferred to contract (c is decreasing)
        // so we need to ensure the amount of base token leftover
        // matches or is less than the area of the trapezoid 
        // but if this is the case they can just take all the base token

        require(
          baseTokenBalance >= area,
          "RallyCurveV1: INVALID_BONDING"
        );
      } else if (isToken0Bonded && amount1Out == 0 || !isToken0Bonded && amount0Out == 0) {
        // bonded token is being transferred to user (c is increasing)
        // so we need to ensure the amount of base token leftover
        // matches or is greater than the area of the trapezoid
        
        require(
          baseTokenBalance >= area,
          "RallyCurveV1: INVALID_BONDING"
        );
      } else {
        revert("RallyCurveV1: INVALID_SWAP");
      }
     */
    }

    _update(_balance0, _balance1);

    emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
  }

  // force balances to match reserves
  function skim(address to) external lock {
    TransferHelper.safeTransfer(token0, to, balance0() - reserve0);
    TransferHelper.safeTransfer(token1, to, balance1() - reserve1);
  }

  // force reserves to match balances
  function sync() external lock {
    _update(balance0(), balance1());
  }
}
