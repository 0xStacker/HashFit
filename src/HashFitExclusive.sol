// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitCore} from "./HashFit.sol";
import {HashFitTypes} from "./Types.sol";
import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import {IHashFitFactory} from "./interfaces/IHashFitFactory.sol";
import {IHashFitKey} from "./interfaces/IHashFitKey.sol";
import {HashFitMythic} from "./HashFitKeys.sol";
import {IHashFitErrors} from "./interfaces/IHashFitErrors.sol";
import {IERC721Enumerable} from "@openzeppelin/interfaces/IERC721Enumerable.sol";

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

    address immutable KEY_ROUTER;
    // Factory contract
    IHashFitFactory internal immutable FACTORY;
    // Non changing mythic key contract
    HashFitMythic public immutable mythic;

    // Initialize contract with necessary data
    constructor(
        bytes32 merkleRoot,
        HashFitTypes.HashFitDrop memory setup,
        address _admin,
        address _coreFactory
    ) HashFitCore(setup, _admin) {
        ROOT = merkleRoot;
        FACTORY = IHashFitFactory(_coreFactory);
        mythic = FACTORY.mythic();
        KEY_ROUTER = setup.routers.keyRouter;
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

    modifier onlyKeyRouter() {
        if (msg.sender != KEY_ROUTER) {
            revert IHashFitErrors.UnauthorizedAccess();
        }
        _;
    }

    function purchaseWithKey(
        HashFitTypes.SaleItem memory _item,
        address caller
    ) external nonReentrant onlyKeyRouter {
        // Fetch user key holdings

        // Ensure sale has begun
        if (block.timestamp < SALE_START_TIME) {
            revert IHashFitErrors.SaleNotStarted();
        }

        if (
            currentSupply[_item.itemId] + _item.amount >
            dropItems[_item.itemId].maxSupply
        ) {
            revert IHashFitErrors.CannotPurchaseItem(
                _item.itemId,
                _item.amount
            );
        }

        currentSupply[_item.itemId] += _item.amount;
        totalSoldItems += _item.amount;
        emit IHashFitErrors.PurchaseAndClaim(
            caller,
            _item.itemId,
            _item.amount,
            true
        );
        _mint(caller, _item.itemId, _item.amount, "");
    }
}
