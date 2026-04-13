// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitExclusive} from "../HashFitExclusive.sol";
import {HashFitTypes} from "../Types.sol";
import {IERC721Enumerable} from "@openzeppelin/interfaces/IERC721Enumerable.sol";
import {IHashFitErrors} from "../interfaces/IHashFitErrors.sol";
import {HashFitMythic} from "../HashFitKeys.sol";
import "forge-std/Test.sol";

/// @dev Purchase bundler for sales involving keys.
contract KeyPurchaseRouter is Test {
    HashFitMythic immutable MYTHIC;
    address immutable BURNER;

    struct Item {
        address gen;
        HashFitTypes.SaleItem item;
    }

    error EmptyCart();

    constructor(address burner, address mythic) {
        MYTHIC = HashFitMythic(mythic);
        BURNER = burner;
        console.log("MYTHIC", address(MYTHIC));
    }

    function bundledPurchase(Item[] memory _items) external payable {
        if (_items.length < 1) {
            revert EmptyCart();
        }

        for (uint256 i; i < _items.length; i++) {
            HashFitExclusive drop = HashFitExclusive(_items[i].gen);
            uint256 callerBalance = MYTHIC.balanceOf(msg.sender);
            console.log(callerBalance);
            (uint64 maxSupply, uint64 discount, uint64 keyPrice, , , ) = drop
                .dropItems(_items[i].item.itemId);
            console.log("Key price", keyPrice);
            console.log("discount", discount);
            console.log("max supply", maxSupply);
            if (callerBalance < keyPrice) {
                revert IHashFitErrors.InsufficientKeys(keyPrice);
            }

            for (uint256 j; j < keyPrice; j++) {
                uint256 keyId = IERC721Enumerable(MYTHIC).tokenOfOwnerByIndex(
                    msg.sender,
                    0
                );
                // Send key to burner and mint identity SBT
                bytes memory burnInstruction = abi.encode(
                    address(MYTHIC),
                    keyId
                );
                try
                    IERC721Enumerable(MYTHIC).safeTransferFrom(
                        msg.sender,
                        BURNER,
                        keyId,
                        burnInstruction
                    )
                {
                    emit IHashFitErrors.RedeemKey(msg.sender, keyId);
                } catch {
                    revert IHashFitErrors.UnableToTransferKey();
                }
            }
            drop.purchaseWithKey(_items[i].item, msg.sender);
        }
    }
}
