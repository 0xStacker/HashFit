//SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
import {HashFitTypes} from "../Types.sol";

interface IHashFitKey {
    event DistributeKeys(address indexed receiver, uint256 amount);
    error UnauthorizedAccess();
    error MythicKeyNonTransferrable();


    function distributeKeys(HashFitTypes.Receiver[] memory receivers) external;

    function generation() external returns (uint256);

    function validity() external view returns (uint256);

    function destroyKey(uint256 keyId) external;

    function keyTier() external returns (bytes32);
}

