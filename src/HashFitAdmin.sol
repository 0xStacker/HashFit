// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
import {HashFitFactory} from "./factory/HashFitFactory.sol";
import {HashFitTypes} from "./Types.sol";
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "./HashFitKeys.sol";
import {HashFitCore} from "./HashFit.sol";
import {AccessControlDefaultAdminRules} from "@openzeppelin/access/extensions/AccessControlDefaultAdminRules.sol";

/**
 * @title HashFit Admin management contract
 * @author Ibrahim🐸
 *
 * This contract is resposible for handling and managing all administrative
 * functionalities across all HashFit contracts
 * It deploys and manage HashFit Factory and every drop contracts spawned by the Factory
 */

contract HashFitAdmin is AccessControlDefaultAdminRules {
    /// @dev Total regular drops deployed by admin so far
    uint16 public totalDropsDeployed;
    /// @dev Total exclusive drops deployed by admin so far
    uint16 public totalExclusivesDeployed;
    /// @dev factory controlled by admin contract
    HashFitFactory public factory;
    /// @dev Tracks whether factory has been initialized or not
    bool internal factoryInit;

    constructor(
        address defaultAdmin
    ) AccessControlDefaultAdminRules(3 days, defaultAdmin) {}

    // Emitted when admin restocks a particular item within a drop gen
    event Command__RestockItem(
        uint64 _gen,
        uint8 _itemId,
        uint256 _restockAmount
    );
    // Emitted when admin applies discount to a certain item within a drop gen
    event Command__SetDiscount(uint64 _gen, uint8 itemId, uint64 discount);
    // Emitted when admin changes the contracts that burns redeemed keys
    event Command__SetKeyBurner(address _newBurner);
    // Emitted when admins distributes keys
    event Command__DistributeKeys(HashFitTypes.KeyTier indexed tier);
    // Emitted when a new gen drop is deployed
    event Command__DeployHashFitDrop();
    // Emitted when a new exclusive drop is deployed.
    event Command__DeployExclusiveDrop();

    error InvalidKeyType();

    error FactoryNotInitialized();
    error FactoryInitialized();

    modifier factoryInitialized() {
        _factoryInitialized();
        _;
    }

    function _factoryInitialized() internal view {
        if (!factoryInit) {
            revert FactoryNotInitialized();
        }
    }

    /// @dev Deploy factory
    function initializeFactory(
        HashFitFactory.Keys memory _keys
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // Create factory for spawning drops
        if (factoryInit) {
            revert FactoryInitialized();
        }
        factory = new HashFitFactory(_keys);
        factoryInit = true;
    }

    /// @dev Initialize factory deployers
    function initializeFactoryDeployers(
        HashFitFactory.Deployers memory _deployers
    ) external onlyRole(DEFAULT_ADMIN_ROLE) factoryInitialized {
        factory.initDeployers(_deployers);
    }

    /// @dev Admin function to restock an item in a particular drop generation
    /// @param gen is the drop generation for which the item was created
    /// @param itemId is the identifier for the item within the drop gen
    /// @param restockAmount is the amount of that item to be restocked
    function restock(
        uint64 gen,
        uint8 itemId,
        uint64 restockAmount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) factoryInitialized {
        HashFitCore drop = HashFitCore(factory.drop(gen));
        drop.restock(itemId, restockAmount);
        emit Command__RestockItem(gen, itemId, restockAmount);
    }

    /// @dev Admin function to add discount to a unique item within a drop gen
    /// @param gen is the drop generation which the item belongs
    /// @param itemId is the unique identifier of the item within the drop gen
    /// @param discountBps is the percentage discount to be applied to the item (100bps = 1%)
    function setDiscount(
        uint64 gen,
        uint8 itemId,
        uint64 discountBps
    ) external onlyRole(DEFAULT_ADMIN_ROLE) factoryInitialized {
        HashFitCore drop = HashFitCore(factory.drop(gen));
        drop.setDiscount(itemId, discountBps);
        emit Command__SetDiscount(gen, itemId, discountBps);
    }

    /// @dev Admin function to distribute mythic and epic keys]
    /// @param _receivers contains the addresses of the winners to which keys would be distributed.
    /// @param tier is the key tier to distribute
    /// - Mythic
    /// - Epic
    function distributeKeys(
        HashFitTypes.Receiver[] memory _receivers,
        HashFitTypes.KeyTier tier
    ) external onlyRole(DEFAULT_ADMIN_ROLE) factoryInitialized {
        // reject invalid key types
        if (tier == HashFitTypes.KeyTier.MYTHIC) {
            HashFitMythic mythic = factory.mythic();
            mythic.distributeKeys(_receivers);
        }
        // distribute mythics
        if (tier == HashFitTypes.KeyTier.LEGENDARY) {
            HashFitLegendary legendary = factory.legendary();
            legendary.distributeKeys(_receivers);
        }
        // distribute epics
        else if (tier == HashFitTypes.KeyTier.EPIC) {
            HashFitEpic epic = factory.epic();
            epic.distributeKeys(_receivers);
        }
        emit Command__DistributeKeys(tier);
    }

    /// @dev Admin function to deploy a new drop from factory
    function deployHashFitDrop(
        HashFitTypes.HashFitDrop memory setup
    ) external onlyRole(DEFAULT_ADMIN_ROLE) factoryInitialized {
        factory.deployHashFitDrop(setup);
        totalDropsDeployed += 1;
        emit Command__DeployHashFitDrop();
    }

    /// @dev Admin function to deploy a new exclusive drop from factory
    function deployExclusiveDrop(
        bytes32 merkleRoot,
        HashFitTypes.HashFitDrop memory setup
    ) external onlyRole(DEFAULT_ADMIN_ROLE) factoryInitialized {
        factory.deployHashFitExclusive(merkleRoot, setup);
        totalExclusivesDeployed += 1;
        emit Command__DeployExclusiveDrop();
    }
}
