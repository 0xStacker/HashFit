//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitTypes} from "../Types.sol";

interface IHashFitKey {
    // Emitted when keys have been distributed
    event DistributeKeys(address indexed receiver, uint256 amount);
    // Thrownn when a key owner-only function is called by non-owner
    error NotOwner(uint256);
    // Thrown when an admin function is called by a non admin address
    error UnauthorizedAccess();
    // Thrown when another key distribution is attempted after initial distribution
    error KeyDistributed(uint256 gen);

    /**
     * Airdrop keys to winners
     * receivers contain the address of winners, decided offchain.
     */
    function distributeKeys(HashFitTypes.Receiver[] memory receivers) external;

    /**
     * Returns the number of gens for which key can be used before expiry
     * Mythic keys return 0 as they do not expire
     */
    function validity() external view returns (uint256);

    /**
     * Remove a key from existence
     */
    function destroyKey(uint256 keyId) external;

    /**
     * Returns the tier in which a key belongs
     *  - Mythic
     *  - Legendary
     *  - Epic
     */
    function keyTier() external returns (bytes32);
}

