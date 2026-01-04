//SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

interface IHashFitKey {
    event DistributeKeys(address indexed receiver, uint256 amount);
    error UnauthorizedAccess();
    error MythicKeyNonTransferrable();

    struct Receiver {
        address receiverAddress;
        uint256 amount;
    }

    function distributeKeys(Receiver[] memory receivers) external;

    function generation() external returns (uint256);

    function keyValidity() external view returns (uint256);

    function destroyKey(uint256 keyId) external;

    function keyTier() external returns (bytes32);
}

