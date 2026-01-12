//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {IHashFitFactory} from "./IHashFitFactory.sol";
import {HashFit} from "./HashFit.sol";
import {KeyScaffold, HashFitMythic, HashFitLegendary, HashFitEpic} from "./HashFitKeys.sol";

contract HashFitFactory is IHashFitFactory {
    address internal immutable HASHFIT_MYTHIC;
    address internal immutable HASHFIT_EPIC;
    address public keyBurner;
    address public crafter;
    uint256 internal nextGeneration;

    mapping(uint256 keyGen => address) internal legendaryKeys;
    mapping(uint256 drop => address) public drop;

    struct FactorySetup{
        address epic;
        address mythic;
        address burner;
    }
    constructor(FactorySetup memory setup){
        HASHFIT_EPIC = setup.epic;
        HASHFIT_MYTHIC = setup.mythic;
        keyBurner = setup.burner;
    }

    struct GenKeyInfo {
        KeyScaffold.Metadata keyMetadata;
        KeyScaffold.KeyDetail keyDetail;
    }

    function fetchKeyByGen(uint256 keyGen) external view returns (address _legendary) {
        _legendary = legendaryKeys[keyGen];
    }

    function setKeyBurner(address _newBurner) external {
        keyBurner = _newBurner;
        emit NewBurnerSet(_newBurner);
    }

    function genesis() external view returns(address){
        return drop[0];
    }

    function deployHashFitDrop(string memory _uri, HashFit.HashFitDrop memory _setup, GenKeyInfo memory legendaryKey)
        external returns(HashFit)
    {
        HashFit nextGenDrop = new HashFit(_uri, _setup);
        HashFitLegendary nextGenLegendaryKey = new HashFitLegendary(legendaryKey.keyMetadata, legendaryKey.keyDetail);
        legendaryKeys[nextGeneration] = address(nextGenLegendaryKey);
        drop[nextGeneration] = address(nextGenDrop);
        nextGeneration++;
        return nextGenDrop;
    }

    function mythic() public view returns(address){
        return HASHFIT_MYTHIC;
    }

    function epic() public view returns(address){
        return HASHFIT_EPIC;
    }
}
