//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {IHashFitFactory} from "./IHashFitFactory.sol";
import {HashFit} from "./HashFit.sol";
import {KeyScaffold} from "./HashFitKeys.sol";

contract HashFitFactory is IHashFitFactory{
    uint256 internal nextGeneration;

    address public keyBurner;
    address public crafter;
    address public genesis = keys[0];

    mapping(uint keyGen => address) internal keys;

    function fetchKeyByGen(uint keyGen) external view returns(address key){
        key = keys[keyGen];
    }

    function setKeyBurner(address _newBurner) external{
        keyBurner = _newBurner;
        emit NewBurnerSet(_newBurner);
    }
    
    struct GenKey{
        KeyScaffold.Metadata keyMetadata;
        KeyScaffold.KeyDetail keyDetail;
    }

    function deployApparelDrop(string memory _uri, GenKey mythicKey, GenKey legendaryKey) external onlyAdmin{
        nextGenDrop = new HashFit(_uri, _setup);
        nextGenMythicKey = new HashFitMythic(mythicKey.keyMetadata, mythicKey.keyDetail);
        nextGenLegendaryKey = new HashFitLegendary(legendaryKey.keyMetadata, legendaryKey.keyDetail);
        nextGeneration++;
    }
    
}