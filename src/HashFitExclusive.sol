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
    // Factory contract
    IHashFitFactory internal immutable FACTORY;
    // Non changing mythic key contract
    HashFitMythic internal immutable mythic;

    // Initialize contract with necessary data
    constructor(bytes32 merkleRoot, HashFitTypes.HashFitDrop memory setup, address _admin) HashFitCore(setup, _admin) {
        ROOT = merkleRoot;
        FACTORY = IHashFitFactory(msg.sender);
        mythic = FACTORY.mythic();
    }

    // Thrown when a non whitelisted user attempts a purchase
    error NotWhiteListed(address _buyer, bytes32[] proof);

    // Enforce whitelist priviledges
    // modifier onlyWhitelist(bytes32[] memory proof) {
    //     if (!proof.verify(ROOT, keccak256(abi.encodePacked(tx.origin)))) {
    //         revert NotWhiteListed(tx.origin, proof);
    //     }
    //     _;
    // }

    /// @inheritdoc HashFitCore
    /// @param proof is the merkle proof used to validate user
    function purchaseAndClaim(HashFitTypes.SaleItem[] memory _items, bytes32[] memory proof)
        external
        payable
        override /*onlyWhitelist (proof) */
        nonReentrant
    {
        _purchaseAndClaim(_items);
    }

    function purchaseWithKey(HashFitTypes.SaleItem memory _item, uint256[] memory keyIds) external nonReentrant {
        if (keyIds.length < dropItems[_item.itemId].priceInKeys) {
            revert KeyMismatch();
        }

        // Ensure sale has begun
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }

        if (currentSupply[_item.itemId] + _item.amount > dropItems[_item.itemId].maxSupply) {
            revert CannotPurchaseItem(_item.itemId, _item.amount);
        }

        for (uint256 i; i < keyIds.length; i++) {
            uint256 keyId = keyIds[i];

            if (tx.origin != IERC721A(mythic).ownerOf(keyId)) {
                revert UnauthorizedKeyUsage(keyId);
            }
            // Send key to burner and mint identity SBT
            bytes memory burnInstruction = abi.encode(address(mythic), keyId);
            try IERC721A(mythic).safeTransferFrom(tx.origin, FACTORY.keyBurner(), keyId, burnInstruction) {
                emit RedeemKey(tx.origin, keyId);
            } catch {
                revert UnableToTransferKey();
            }
        }
        currentSupply[_item.itemId] += _item.amount;
        totalSoldItems += _item.amount;
        emit PurchaseAndClaim(_item.itemId, _item.amount, true);
        _mint(tx.origin, _item.itemId, _item.amount, "");
    }
}
