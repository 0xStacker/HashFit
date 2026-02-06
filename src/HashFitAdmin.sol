// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
import {HashFitFactory} from "./HashFitFactory.sol";
import {HashFitTypes} from "./Types.sol";
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "./HashFitKeys.sol";
import {HashFitCore} from "./HashFit.sol";

/**
 * @title HashFit Admin management contract
 * @author Ibrahim🐸
 *
 * This contract is resposible for handling and managing all administrative
 * functionalities across all HashFit contracts
 * It deploys and manage HashFit Factory and every drop contracts spawned by the Factory
 */

contract HashFitAdmin {
    /// @dev Factory controlled by admin contract
    HashFitFactory public immutable FACTORY;

    constructor(HashFitTypes.FactorySetup memory setup) {
        // Create factory for spawning drops
        FACTORY = new HashFitFactory(setup);
    }

    // Emitted when admin restocks a particular item within a drop gen
    event Command__RestockItem(uint64 _gen, uint8 _itemId, uint256 _restockAmount);
    // Emitted when admin applies discount to a certain item within a drop gen
    event Command__SetDiscount(uint64 _gen, uint8 itemId, uint64 discount);
    // Emitted when admin changes the contracts that burns redeemed keys
    event Command__SetKeyBurner(address _newBurner);
    // Emitted when admins distributes keys
    event Command__DistributeKeys(HashFitTypes.KeyTier indexed tier);

    error InvalidKeyType();

    /// @dev Admin function to restock an item in a particular drop generation
    /// @param gen is the drop generation for which the item was created
    /// @param itemId is the identifier for the item within the drop gen
    /// @param restockAmount is the amount of that item to be restocked
    function restock(uint64 gen, uint8 itemId, uint64 restockAmount) external {
        HashFitCore drop = HashFitCore(FACTORY.drop(gen));
        drop.restock(itemId, restockAmount);
        emit Command__RestockItem(gen, itemId, restockAmount);
    }

    /// @dev Admin function to add discount to a unique item within a drop gen
    /// @param gen is the drop generation which the item belongs
    /// @param itemId is the unique identifier of the item within the drop gen
    /// @param discountBps is the percentage discount to be applied to the item (100bps = 1%)
    function setDiscount(uint64 gen, uint8 itemId, uint64 discountBps) external {
        HashFitCore drop = HashFitCore(FACTORY.drop(gen));
        drop.setDiscount(itemId, discountBps);
        emit Command__SetDiscount(gen, itemId, discountBps);
    }

    /// @dev Admin function to set new burner address for keys
    /// @param _newBurner is the new address which keys would be sent to for incilneration
    function setKeyBurner(address _newBurner) external {
        FACTORY.setKeyBurner(_newBurner);
        emit Command__SetKeyBurner(_newBurner);
    }

    /// @dev Admin function to distribute legendary keys for a particular gen
    /// @notice keys can only be distributed for a gen once
    /// @param _receivers contain the addresses of the winners, computed off chain
    /// @param gen is the key generation to be distributed
    function distributeLegendary(HashFitTypes.Receiver[] memory _receivers, uint256 gen) external {
        HashFitLegendary legendary = FACTORY.fetchKeyByGen(gen);
        legendary.distributeKeys(_receivers);
        emit Command__DistributeKeys(HashFitTypes.KeyTier.LEGENDARY);
    }

    /// @dev Admin function to distribute mythic and epic keys]
    /// @param _receivers contains the addresses of the winners to which keys would be distributed.
    /// @param tier is the key tier to distribute
    /// - Mythic
    /// - Epic
    function distributeOthers(HashFitTypes.Receiver[] memory _receivers, HashFitTypes.KeyTier tier) external {
        // reject invalid key types
        if (tier != HashFitTypes.KeyTier.MYTHIC && tier != HashFitTypes.KeyTier.EPIC) {
            revert InvalidKeyType();
        }
        // distribute mythics
        if (tier == HashFitTypes.KeyTier.MYTHIC) {
            HashFitMythic mythic = FACTORY.mythic();
            mythic.distributeKeys(_receivers);
        }
        // distribute epics
        else if (tier == HashFitTypes.KeyTier.EPIC) {
            HashFitEpic epic = FACTORY.epic();
            epic.distributeKeys(_receivers);
        }
        emit Command__DistributeKeys(tier);
    }
}
