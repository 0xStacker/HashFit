// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitCore} from "../HashFit.sol";
import {HashFitTypes} from "../Types.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/interfaces/IERC20.sol";

/// @dev Purchase Bundler for non-key purchases.
contract PaidPurchaseRouter {
    using SafeERC20 for IERC20;
    IERC20 USDT;
    address ADMIN;

    constructor() {}

    struct Item {
        address gen;
        HashFitTypes.SaleItem[] items;
        bytes32[] proof;
    }

    function bundledPurchase(Item[] memory _items) external payable {
        if (_items.length < 1) {
            revert("error");
        }

        for (uint256 i; i < _items.length; i++) {
            if (_items[i].items.length < 1) {
                revert("error");
            }
            HashFitCore drop = HashFitCore(_items[i].gen);
            uint cost = drop.getTotal(_items[i].items);
            USDT.safeTransferFrom(msg.sender, ADMIN, cost);
            // Pass down caller
            drop.purchaseAndClaim(_items[i].items, msg.sender, _items[i].proof);
        }
    }
}
