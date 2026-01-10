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
    address public genesisDrop = drop[0];
    uint256 internal nextGeneration;

    mapping(uint256 keyGen => address) internal legendaryKeys;
    mapping(uint256 drop => address) public drop;

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

    function deployHashFitDrop(string memory _uri, HashFit.HashFitDrop memory _setup, GenKeyInfo memory legendaryKey)
        external
    {
        HashFit nextGenDrop = new HashFit(_uri, _setup);
        HashFitLegendary nextGenLegendaryKey = new HashFitLegendary(legendaryKey.keyMetadata, legendaryKey.keyDetail);
        legendaryKeys[nextGeneration] = address(nextGenLegendaryKey);
        drop[nextGeneration] = address(nextGenDrop);
        nextGeneration++;
    }

    function mythic() public view returns(address){
        return HASHFIT_MYTHIC;
    }

    function epic() public view returns(address){
        return HASHFIT_EPIC;
    }
}
