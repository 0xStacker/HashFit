// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {Test, console} from "forge-std/Test.sol";
import {HashFitFactory} from "../src/HashFitFactory.sol";
import {HashFitMythic, HashFitEpic, HashFitLegendary, KeyScaffold} from "../src/HashFitKeys.sol";
import {KeyBurner} from "../src/KeyBurner.sol";
import {HashFit} from "../src/HashFit.sol";
contract FactoryTest is Test{
    // HashFit Factory
    uint8 nextGen;
    HashFit.Item[] _items;
    HashFitFactory factory;
    string constant contractURI = "https://HashFit";
    // Setup mythic key
    KeyScaffold.Metadata mythic = KeyScaffold.Metadata({name: "Mythic",
    symbol: "MTHC",
    uri: "https://mythic-key"});

    KeyScaffold.KeyDetail mythicKeyDetail = KeyScaffold.KeyDetail({
        validity: 0,
        generation: 0
    });

    // Setup epic key
    KeyScaffold.Metadata epic = KeyScaffold.Metadata({name: "Epic",
    symbol: "EPIC",
    uri: "https://epic-key"});

    KeyScaffold.KeyDetail epicKeyDetail = KeyScaffold.KeyDetail({
        validity: 0,
        generation: 0
    });

    // Deploy mythic and epic keys
    HashFitMythic mythicKey = new HashFitMythic(mythic, mythicKeyDetail);
    HashFitEpic epicKey = new HashFitEpic(epic, epicKeyDetail);
    KeyBurner burner = new KeyBurner();

    // Setup factory
    HashFitFactory.FactorySetup setupData = HashFitFactory.FactorySetup({
        epic: address(epicKey),
        mythic: address(mythicKey),
        burner: address(burner)
    });

    // Deploy Factory
    function setUp() public{
        factory = new HashFitFactory(setupData);
        console.log("Setup complete");
        assertEq(factory.mythic(), address(mythicKey));
        assertEq(factory.epic(), address(epicKey));
        for(uint i; i < 3; i++){
            _items.push();
        } 
    }

    /// @dev Setup legendary key
    /// @param _validity is how long key is valid for
    /// @param _gen is the generation of creation 
    function _buildLegendary(uint64 _gen, uint8 _validity) internal pure returns (HashFitFactory.GenKeyInfo memory leggy){
        KeyScaffold.Metadata memory metadata = KeyScaffold.Metadata({name: "LEGENDARY",
        symbol: "LEGENDARY",
        uri: "https://legendary-key"});

        KeyScaffold.KeyDetail memory detail = KeyScaffold.KeyDetail({
            validity: _validity, // leggy keys are valid through 3 gens
            generation: _gen
        });

        leggy = HashFitFactory.GenKeyInfo({
            keyMetadata: metadata,
            keyDetail: detail
        });
    }


    // Builds details for next HashFit Drop
    function _buildNextHashFitDrop(uint64 totalSupply,
    HashFit.Item[] memory items) internal returns (HashFit.HashFitDrop memory drop){
        for(uint i; i < items.length; i++){
            items[i].maxSupply = totalSupply / 3;
            items[i].discount  = 0;
            items[i].price = 100;
            _items.push(items[i]);
        }
        drop = HashFit.HashFitDrop({totalSupply: totalSupply,
        generation: nextGen,
        saleStartTime: 0,
        cypheringPhaseDuration: 400,
        items: _items});
    }


    // Deploy a new HashFit Drop
    function _deployHashFit(HashFit.Item[] memory _items, HashFitFactory.GenKeyInfo memory leggyKey) internal returns(HashFit drop){
        uint64 totalSupply = 300; // (bound(totalSupply, 120, 500) / 3) * 3;
        HashFit.HashFitDrop memory dropSetup = _buildNextHashFitDrop(totalSupply, _items);
        // HashFitLegendary leggyKey = _buildLegendary(nextGen, 3);
        drop = factory.deployHashFitDrop(contractURI, dropSetup, leggyKey);
    }

    function testDeployHashFit() public returns(HashFit drop){   
        drop = _deployHashFit(_items, _buildLegendary(nextGen, 3));
        assertEq(factory.mythic(), address(mythicKey));
        assertEq(factory.epic(), address(epicKey));
        assertEq(factory.keyBurner(), address(burner));
        assertNotEq(factory.fetchKeyByGen(0), address(0));
    }

    function testSetBurner() public {
        HashFit drop = testDeployHashFit();
        KeyBurner newBurner = new KeyBurner();
        factory.setKeyBurner(address(newBurner));
        assertEq(factory.keyBurner(), address(newBurner));
    }
}
