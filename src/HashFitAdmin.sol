// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
import {HashFitFactory} from "./HashFitFactory.sol";
import {HashFitTypes} from "./Types.sol";
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "./HashFitKeys.sol";
import {HashFitCore} from "./HashFit.sol";

contract HashFitAdmin{
    /// @dev Factory controlled by admin contract
    HashFitFactory public immutable FACTORY;

    constructor(HashFitTypes.Key memory _epic, HashFitTypes.Key memory _mythic){
        // Create factory for spawning drops
        FACTORY = new HashFitFactory(_epic, _mythic);
    }

    event Command__RestockItem(uint64 _gen, uint8 _itemId, uint _restockAmount);
    event Command__SetDiscount(uint64 _gen, uint8 itemId, uint64 discount);
    event Command__SetKeyBurner(address _newBurner);
    event Command__DistributeKeys(HashFitTypes.KeyTier indexed tier);

    error InvalidKeyType();

    /// @dev Restocks an item in a particular drop generation.abi
    /// @param gen is the drop generation for which the item was created
    /// @param itemId is the identifier for the item within the drop gen
    /// @param restockAmount is the amount of that item to be restocked
    function restock(uint64 gen, uint8 itemId, uint64 restockAmount) external {
        HashFitCore drop = HashFitCore(FACTORY.drop(gen));
        drop.restock(itemId, restockAmount);
        emit Command__RestockItem(gen, itemId, restockAmount);
    }

    function setDiscount(uint64 gen, uint8 itemId, uint64 discountBps) external {
        HashFitCore drop = HashFitCore(FACTORY.drop(gen));
        emit Command__SetDiscount();
    }

    function setKeyBurner(address _newBurner) external {
        FACTORY.setKeyBurner(_newBurner);
        emit Command__SetKeyBurner(_newBurner);
    }

    function distributeLegendary(HashFitTypes.Receiver[] memory _receivers, HashFitTypes.KeyTier tier, uint gen) external{
        // reject invalid key types
        if (tier != HashFitTypes.KeyTier.LEGENDARY){
            revert InvalidKeyType();
        }
        HashFitLegendary legendary = FACTORY.fetchKeyByGen(gen);
        legendary.distributeKeys(_receivers);
        emit Command__DistributeKeys(tier);
    }

    function distributeOthers(HashFitTypes.Receiver[] memory _receivers, HashFitTypes.KeyTier tier) external{
        // reject invalid key types
        if(tier != HashFitTypes.KeyTier.MYTHIC && tier != HashFitTypes.KeyTier.EPIC){
            revert InvalidKeyType();
        }
        // distribute mythics
        if(tier == HashFitTypes.KeyTier.MYTHIC){
            HashFitMythic mythic = FACTORY.mythic();
            mythic.distributeKeys(_receivers);
        }
        // distribute epics
        else if(tier == HashFitTypes.KeyTier.EPIC){
            HashFitEpic epic = FACTORY.epic();
            epic.distributekeys(_receivers);
        }
        emit Command__DistributeKeys(tier);
    }
}
