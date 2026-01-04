// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFit} from "./HashFit.sol";
import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
contract HashFitExclusive is HashFit{
    using MerkleProof for bytes32[];

    bytes32 immutable root;
    constructor(string memory _uri, bytes32 merkleRoot, HashFitDrop memory setup) HashFit(_uri, setup){
        root = merkleRoot;
    }

    error NotWhiteListed(); 
    modifier onlyWhitelist(bytes32[] memory proof){
        if(!proof.verify(root, keccak256(abi.encode(msg.sender)))){
            revert NotWhiteListed();
        }
        _;
    }

    function purchaseAndClaim(SaleItem[] memory _items, bytes32[] memory proof) external payable override onlyWhitelist(proof){
        _purchaseAndClaim(_items);
    }

    function purchaseWithKey(SaleItem[] memory _items, Key[] memory keys) external override{
         // Sanity check
        if (_items.length != keys.length) {
            revert KeyMismatch();
        }
        // Ensure sale has begun
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }
        // Fetch the addresses of the legendary key of the required generation
        // and the mythic key contract
        (, address mythic) = IHashFitFactory(FACTORY).fetchKeyByGen(keys[i].keyGen);
        address keyContract = mythic;
        IHashFitKey key = IHashFit(keyContract);

        for (uint256 i; i < _items.length; i++) {
            // Make sure item is not sold out
            SaleItem memory currentItem = _items[i];
            if (
                dropItems[currentItem.itemId].currentSupply + currentItem.amount
                    > dropItems[currentItem.itemId].maxSupply
            ) {
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
                }
            // Use the corresponding key for current item
            uint256 keyId = keys[i].keyId;
            // Assert key ownership
            if (IERC721A(keyContract).balanceOf(msg.sender) < 1) {
                revert InsufficientKeys(keyContract);
            }

            if (msg.sender != IERC721A(keyContract).ownerOf(keyId)) {
                revert UnauthorizedKeyUsage(keys[i].keyGen, keyId);
            }
            // Burn key and mint, validate sale and mint identity SBT
            bytes memory burnInstruction = abi.encode(keyContract, keyId);
            try IERC721A(keyContract)
                .safeTransferFrom(msg.sender, IHashFitFactory(FACTORY).keyBurner(), keyId, burnInstruction) {
                emit RedeemKey(msg.sender, key.generation(), keyId);
            } catch {
                revert UnableToTransferKey();
            }

            dropItems[currentItem.itemId].currentSupply += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, true);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");           
        }
    }
}