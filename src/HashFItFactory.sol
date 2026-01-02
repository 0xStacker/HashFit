//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {IHashFitFactory} from "./IHashFitFactory.sol";
import {HashFit} from "./HashFit.sol";
import {KeyScaffold, HashFitMythic, HashFitLegendary} from "./HashFitKeys.sol";

contract HashFitFactory is IHashFitFactory{
    uint256 internal nextGeneration;

    address public keyBurner;
    address public crafter;
    GenKey public genesis = keys[0];

    mapping(uint keyGen => HashFit.GenKey) internal keys;
    mapping (uint drop => address) public drop;

    struct GenKeyinfo{
        KeyScaffold.Metadata keyMetadata;
        KeyScaffold.KeyDetail keyDetail;
    }

    struct GenKey{
        address mythic;
        address legendary;
        // address epic;
    }
    
    function fetchKeyByGen(uint keyGen) external view returns(address mythic, address legendary){
        mythic = keys[keyGen].mythic;
        legendary = keys[keyGen].legendary;
    }

    function setKeyBurner(address _newBurner) external{
        keyBurner = _newBurner;
        emit NewBurnerSet(_newBurner);
    }

    function deployApparelDrop(string memory _uri, HashFit.HashFitDrop memory _setup, GenKey memory mythicKey, GenKey memory legendaryKey) external{
        HashFit nextGenDrop = new HashFit(_uri, _setup);
        HashFitMythic nextGenMythicKey = new HashFitMythic(mythicKey.keyMetadata, mythicKey.keyDetail);
        HashFitLegendary nextGenLegendaryKey = new HashFitLegendary(legendaryKey.keyMetadata, legendaryKey.keyDetail);
        keys[nextGeneration] = HashFit.GenKey({
            mythic: address(nextGenMythicKey),
            legendary: address(nextGenLegendaryKey)
        });

        nextGeneration++;
    }
    
}