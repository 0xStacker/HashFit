// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
/// @dev declares all error and event signatures for HashFitCore

interface IHashFitErrors{
    // Emitted after a successful purchase of an item
    event PurchaseAndClaim(uint256 item, uint256 amount, bool key);
    // Emitted when a key is succesfully redeemed
    event RedeemKey(address redeemer, uint256 keyGen, uint256 keyId);

    // Thrown when a purchase is attempted before drop sale begins 
    error SaleNotStarted();
    error UnauthorizedAccess();
    error NonTransferrable();
    error NotEnoughItems();
    error InsufficientFund();
    error UriRequestForNonExistentToken();
    error InsufficientKeys(address);
    error UnauthorizedKeyUsage(uint256, uint256);
    error UnableToTransferKey();
    error KeyMismatch();
    error ExpiredKey(uint256);
    error CannotPurchaseItem(uint256 itemId, uint256 amount);
}