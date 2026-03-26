// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title HashFitTypes
 * @author Ibrahim🐸
 *
 * This contract defines all complex datatypes used across all HashFit contracts
 */
abstract contract HashFitTypes {
    /// @dev defines basic ERC721 metadata for key
    struct Metadata {
        // Name of the key
        string name;
        // Symbol of the key
        string symbol;
        // URI for key
        string uri;
    }

    /// @dev defines usage details for key
    struct KeyDetail {
        // How many  generation key is valid for use
        uint8 validity;
        // Generation which key was created
        uint64 generation;
    }

    enum KeyTier {
        MYTHIC,
        LEGENDARY,
        EPIC
    }

    /// @dev An HashFit Key
    struct Key {
        // key uri
        string uri;
        // see {KeyDetail} struct
        KeyDetail keyDetail;
    }

    /// @dev Setup data for factory
    struct FactorySetup {
        // One time detail for epic key contract to be deployed by factory
        Key epic;
        // one time detail for mythic key contract to be deployed by factory
        Key mythic;
        // one time detail for legendary key to be deployed by factory
        Key legendary;
    }

    // Per item details
    struct Item {
        // Total units of an item present in the drop
        uint64 maxSupply;
        // Percentage discount applied
        uint64 discount;
        // Cost in keys (Used in exclusive drops)
        uint64 priceInKeys;
        // Selling price of a unit of an item
        uint256 price;
        // Item name
        string name;
        // Item uri
        string uri;
    }

    // Holds required data for an apparel drop
    // Cyphering phase is a special limited sale phase at the begining of the drop
    // Purchasing an item within this phase would allow buyer wallet to be collected and considered
    // for random HashFit keys distribution offchain
    struct HashFitDrop {
        // Allowed payment tokens token
        address token;
        // Drop generation
        uint64 generation;
        // When the drop sale begins
        uint256 saleStartTime;
        // Sale timeframe within which buyers can be considered for key raffle
        uint256 cypheringPhaseDuration;
        // Authorized sale routers
        Routers routers;
        // contract uri
        string uri;
        // Unique items in the drop. see {Item} struct.
        Item[] items;
    }

    /// @dev Used to collect info on what key a user would like to use when they attempt
    /// To make purchase with a key
    struct KeyInfo {
        uint64 gen; // Key generation
        uint64 keyId; // Unique key identifier
        bytes32 keyTier; // Key tier
    }

    /// @dev Used to collect the info of an item a user wants to purchase within drop
    struct SaleItem {
        // Unique item identifier
        uint8 itemId;
        // Unit of item being purchased
        uint64 amount;
    }

    struct Receiver {
        address receiverAddress;
        uint256 amount;
    }

    struct Routers {
        address paidRouter;
        address keyRouter;
    }
}
