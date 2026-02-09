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
        ROOT = merkleRoot;
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
        nonReentrant
    {
        _purchaseAndClaim(_items);
    }


    function purchaseWithKey(HashFitTypes.SaleItem memory _item, uint256[] memory keyIds) external nonReentrant{
        if (keyIds.length < dropItems[_item.itemId].priceInKeys){
            revert KeyMismatch();
        }

        // Ensure sale has begun
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }

        IHashFitKey key = mythic;

        if (currentSupply[_item.itemId] + _item.amount > dropItems[_item.itemId].maxSupply) {
            revert CannotPurchaseItem(_item.itemId, _item.amount);
        }

        for (uint i; i < keyIds.length; i++){
            uint256 keyId = keyIds[i];

            if (msg.sender != IERC721A(mythic).ownerOf(keyId)) {
                revert UnauthorizedKeyUsage(key.generation(), keyId);
            }
            // Send key to burner and mint identity SBT
            bytes memory burnInstruction = abi.encode(address(mythic), keyId);
            try IERC721A(mythic)
                .safeTransferFrom(msg.sender, FACTORY.keyBurner(), keyId, burnInstruction) {
                emit RedeemKey(msg.sender, key.generation(), keyId);
            } catch {
                revert UnableToTransferKey();
            }
        }
        // Use the corresponding key for current item


        currentSupply[_item.itemId] += _item.amount;
        totalSoldItems += _item.amount;
        emit PurchaseAndClaim(_item.itemId, _item.amount, true);
        _mint(msg.sender, _item.amount, _item.itemId, "");      
    }
}
