//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitTypes} from "./Types.sol"; 
import {IHashFitFactory} from "./interfaces/IHashFitFactory.sol";
import {HashFitCore} from "./HashFit.sol";
import {KeyScaffold, HashFitMythic, HashFitLegendary, HashFitEpic} from "./HashFitKeys.sol";
import {KeyBurner} from "./KeyBurner.sol";

contract HashFitFactory is IHashFitFactory {
    /// @dev The key burner contract
    address public keyBurner;
    /// @dev Non changing mythic key contract deployed with the factory
    HashFitMythic internal immutable MYTHIC;
    /// @dev Non changing epic key contract deployed with the factory
    HashFitEpic internal immutable EPIC;
    /// @dev Admin who controls the entire factory
    /// @notice All administrative function accross all HashFit contract managed by ADMIN
    /// Check {HashFitAdmin} to see all administrative functions 
    address private immutable ADMIN;
    /// Next generation of drop waiting to be deployed
    uint256 public nextGen;

    mapping(uint256 keyGen => HashFitLegendary) internal legendaryKeys;
    mapping(uint256 drop => HashFitCore) public drop;

    error UnauthorizedAccess();
    // Emitted when a drop is created
    event CreateDrop(address indexed _drop, uint gen);
    
    /// @dev Initialize factory as necessary
    constructor(HashFitTypes.FactorySetup memory setup){
        EPIC = new HashFitEpic(setup.epic.keyMetadata, setup.epic.keyDetail, msg.sender);
        MYTHIC = new HashFitMythic(setup.mythic.keyMetadata, setup.mythic.keyDetail, msg.sender);
        keyBurner = address(new KeyBurner());
        ADMIN = msg.sender;
    }

    modifier onlyAdmin{
        if(msg.sender != ADMIN){
            revert UnauthorizedAccess();
        }
        _;
    }
    
    /// @dev getter for legendary keys
    /// @param gen is the generation of legendary key to fetch 
    function fetchKeyByGen(uint256 gen) external view returns (HashFitLegendary _legendary) {
        _legendary = legendaryKeys[gen];
    }

    /// @dev The first drop deployed by factory
    function genesis() external view returns(HashFitCore){
        return drop[0];
    }

    /// @dev the last drop deployed by factory
    function lastGen() external returns(HashFitCore) {
        return drop[nextGen - 1];
    }
    /// @dev getter for mythic key contract
    function mythic() external returns(HashFitMythic){
        return MYTHIC;
    }
    /// @dev getter for epic key contract
    function epic() external returns(HashFitEpic){
        return EPIC;
    }

    function setKeyBurner(address _newBurner) external onlyAdmin{
        keyBurner = _newBurner;
    }
    /// @dev Admin creates new drop
    /// @param _setup contains the required data to initialize the drop. see {HashFitTypes.HashFitDrop}
    /// @param legendaryKey is the legenary key for the current drop generation
    function deployHashFitDrop(string memory _uri, HashFitTypes.HashFitDrop memory _setup, HashFitTypes.Key memory legendaryKey)
        external returns(HashFitCore)
    {
        HashFitCore nextGenDrop = new HashFitCore(_uri, _setup, ADMIN);
        HashFitLegendary nextGenLegendaryKey = new HashFitLegendary(legendaryKey.keyMetadata, legendaryKey.keyDetail, ADMIN);
        legendaryKeys[nextGen] = nextGenLegendaryKey;
        drop[nextGen] = nextGenDrop;
        nextGen++;
        return nextGenDrop;
    }

}
