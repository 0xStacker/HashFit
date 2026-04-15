// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

///@author Ibrahim🐸
/// @dev This interface declares all error and event signatures for HashFitCore and other related contracts

interface IHashFitErrors {
    // Emitted after a successful purchase of an item
    event PurchaseAndClaim(
        address indexed buyer,
        uint256 item,
        uint256 amount,
        bool key
    );
    // Emitted when a key is succesfully redeemed
    event RedeemKey(address redeemer, uint256 keyId);
    // Emitted when admin withdraws ERC20 token from contract
    event WithdrawToken(address indexed token, uint amount);
    // Thrown when a purchase is attempted before drop sale begins
    error SaleNotStarted();
    // Thrown when user tries to access admin functionalitiesd
    error UnauthorizedAccess();
    // Thrown when user tries to transfer Identity SBT {HashFitCore}
    error NonTransferrable();
    // Thrown when ERC20 token withdrawal fails
    error TokenWithdrawalFailed();
    // Thrown when there are not enough items to cover requested purchase quantity
    error NotEnoughItems();
    // Thrown when user doesn't send enough funds to purchase drop items.
    error InsufficientFund();
    error UriRequestForNonExistentToken();
    // Thrown when user does not provide enough keys to exchange for an item
    error InsufficientKeys(uint256);
    // Thrown when user tries to use a key that does not belong to them
    error UnauthorizedKeyUsage(uint256);
    // Thrown when key redeem fails
    error UnableToTransferKey();
    // Thrown when user tries to use an expired legendary key
    error ExpiredKey(uint256);
    // Thrown when item purchase fail
    error CannotPurchaseItem(uint256 itemId, uint256 amount);
}
