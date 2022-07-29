// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./RallyV1Curve.sol";

/// @title A contract capable of deploying Creator Coins
/// @dev This is used to avoid having constructor arguments in the creator coin contract, which results in the init code hash
/// of the coin being constant allowing the CREATE2 address of the coin to be cheaply computed on-chain
contract RallyV1CurveDeployer {
  struct Parameters {
    address factory;
    address token0;
    address token1;
  }

  /// @notice Get the parameters to be used in constructing the token bonding curve, set transiently during coin creation.
  /// @dev Called by the token bonding curve constructor to fetch the parameters of the coin
  /// Returns factory The contract address of the Rally V1 Curve factory
  /// Returns token0 The first token of the token bonding curve by address sort order
  /// Returns token1 The second token of the token bonding curve by address sort order
  Parameters public parameters;

  /// @dev Deploys a coin with the given parameters by transiently setting the parameters storage slot and then
  /// clearing it after deploying the coin.
  /// @param factory The contract address of the Rally V1 Curve factory
  /// @param token0 The first token of the token bonding curve by address sort order
  /// @param token1 The second token of the token bonding curve by address sort order
  function deploy(
    address factory,
    address token0,
    address token1
  ) internal returns (address curveAddress) {
    parameters = Parameters({
      factory: factory,
      token0: token0,
      token1: token1
    });

    curveAddress = address(
      new RallyV1Curve{ salt: keccak256(abi.encode(token0, token1))}()
    );
    delete parameters;
  }
}
