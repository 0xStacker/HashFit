// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitCore} from "./HashFit.sol";
import {HashFitTypes} from "./Types.sol";
import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import {IHashFitFactory} from "./interfaces/IHashFitFactory.sol";
import {IHashFitKey} from "./interfaces/IHashFitKey.sol";
import {HashFitMythic} from "./HashFitKeys.sol";
import {IERC721A} from "@ERC721A/IERC721A.sol";

/**
 * @title HashFit Exclusive Drop
 * @author Ibrahim🐸
 * This is an exclusive version of HashFitCore.
 * Only whitelisted addresses are allowed to purchase items from the drop
 */

contract HashFitExclusive is HashFitCore {
    using MerkleProof for bytes32[];
    // Merkle root for addresses allowed to purchase an item from the drop
    bytes32 immutable ROOT;

    // Initialize contract with necessary data
    constructor(string memory _uri, bytes32 merkleRoot, HashFitTypes.HashFitDrop memory setup, address _admin)
        HashFitCore(_uri, setup, _admin)
    {
        root = merkleRoot;
    }

    // Thrown when a non whitelisted user attempts a purchase
    error NotWhiteListed();
    // Enforce whitelist priviledges
    modifier onlyWhitelist(bytes32[] memory proof) {
        if (!proof.verify(ROOT, keccak256(abi.encode(msg.sender)))) {
            revert NotWhiteListed();
        }
        _;
    }

    /// @inheritdoc HashFitCore
    /// @param proof is the merkle proof used to validate user
    function purchaseAndClaim(HashFitTypes.SaleItem[] memory _items, bytes32[] memory proof)
        external
        payable
        override
        onlyWhitelist(proof)
    {
        _purchaseAndClaim(_items);
    }

    /// @inheritdoc HashFitCore
    function purchaseWithKey(HashFitTypes.SaleItem[] memory _items, KeyInfo[] memory keys) external override {
        // Sanity check
        if (_items.length != keys.length) {
            revert KeyMismatch();
        }
        // Ensure sale has begun
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }
        // Fetch the address of the HashFit mythic key from factory
        HashFitMythic mythic = FACTORY.mythic();
        address keyContract = address(mythic);
        IHashFitKey key = mythic;

        for (uint256 i; i < _items.length; i++) {
            // Make sure item is not sold out
            HashFitTypes.SaleItem memory currentItem = _items[i];
            if (currentSupply[currentItem.itemId] + currentItem.amount > dropItems[currentItem.itemId].maxSupply) {
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }
            // Use the corresponding key for current item
            uint256 keyId = keys[i].keyId;

            if (msg.sender != IERC721A(keyContract).ownerOf(keyId)) {
                revert UnauthorizedKeyUsage(keys[i].gen, keyId);
            }
            // Burn key and mint, validate sale and mint identity SBT
            bytes memory burnInstruction = abi.encode(keyContract, keyId);
            try IERC721A(keyContract)
                .safeTransferFrom(msg.sender, IHashFitFactory(FACTORY).keyBurner(), keyId, burnInstruction) {
                emit RedeemKey(msg.sender, key.generation(), keyId);
            } catch {
                revert UnableToTransferKey();
            }

            currentSupply[currentItem.itemId] += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, true);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");
        }
    }
}
