// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitExclusive} from "../HashFitExclusive.sol";
import {HashFitTypes} from "../Types.sol";

/// @dev Purchase bundler for sales involving keys.
contract KeyPurchaseRouter {
    struct Item {
        address gen;
        HashFitTypes.SaleItem item;
        uint256[] keyIds;
    }

    function bundledPurchase(Item[] memory _items) external payable {
        if (_items.length < 1) {
            revert("error");
        }
        for (uint256 i; i < _items.length; i++) {
            HashFitExclusive drop = HashFitExclusive(_items[i].gen);
            drop.purchaseWithKey(_items[i].item, _items[i].keyIds);
        }
    }
}
