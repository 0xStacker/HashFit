//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitTypes} from "./Types.sol";
import {IHashFitFactory} from "./interfaces/IHashFitFactory.sol";
import {HashFitCore} from "./HashFit.sol";
import {HashFitExclusive} from "./HashFitExclusive.sol";
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "./HashFitKeys.sol";
import {KeyBurner} from "./KeyBurner.sol";

/**
 * @title HashFit Factory
 * @author Ibrahim🐸
 *
 * HashFit factory is responsible for the deployment of new gen of HashFit drops.
 */
contract HashFitFactory is IHashFitFactory {
    /// @dev The key burner contract
    address public keyBurner;
    /// @dev Non changing mythic key contract deployed with the factory
    HashFitMythic internal immutable MYTHIC;
    /// @dev Non changing epic key contract deployed with the factory
    HashFitEpic internal immutable EPIC;
    /// @dev Non changing epic key contract deployed with the factory
    HashFitLegendary internal immutable LEGENDARY;
    /// @dev Admin who controls the entire factory
    /// @notice All administrative function accross all HashFit contract managed by ADMIN
    /// Check {HashFitAdmin} to see all administrative functions
    address private immutable ADMIN;
    /// Next generation of drop waiting to be deployed
    uint256 internal nextGen;
    uint256 internal nextExclusive;
    /// @dev All deployed drops mapped by gen
    mapping(uint256 => HashFitCore) public drop;
    /// @dev All deployed exclusive drops mapped by id
    mapping(uint256 => HashFitExclusive) exclusive;

    error UnauthorizedAccess();
    // Emitted when a drop is created
    event CreateDrop(address indexed _drop, uint256 gen);

    /// @dev Initialize factory as necessary
    constructor(HashFitTypes.FactorySetup memory setup) {
        EPIC = new HashFitEpic(setup.epic.uri, setup.epic.keyDetail, msg.sender);
        MYTHIC = new HashFitMythic(setup.mythic.uri, setup.mythic.keyDetail, msg.sender);
        LEGENDARY = new HashFitLegendary(setup.legendary.uri, setup.legendary.keyDetail, msg.sender);
        keyBurner = address(new KeyBurner());
        ADMIN = msg.sender;
    }

    /// @dev Enforce admin priviledges
    modifier onlyAdmin() {
        if (msg.sender != ADMIN) {
            revert UnauthorizedAccess();
        }
        _;
    }

    /// @dev Admin sets new key burner contract
    function setKeyBurner(address _newBurner) external onlyAdmin {
        keyBurner = _newBurner;
    }

    /// @dev Admin creates new drop
    /// @param _setup contains the required data to initialize the drop. see {HashFitTypes.HashFitDrop}

    function deployHashFitDrop(HashFitTypes.HashFitDrop memory _setup) external onlyAdmin {
        HashFitCore nextGenDrop = new HashFitCore(_setup, ADMIN);
        drop[nextGen] = nextGenDrop;
        nextGen++;
    }

    /// @dev Admin creates new exclusive drop
    /// @param _setup contains the required data to initialize the drop. see {HashFitTypes.HashFitDrop}
    function deployHashFitExclusive(bytes32 merkleRoot, HashFitTypes.HashFitDrop memory _setup) external onlyAdmin {
        HashFitExclusive nextExclusiveDrop = new HashFitExclusive(merkleRoot, _setup, ADMIN);
        exclusive[nextExclusive] = nextExclusiveDrop;
        nextExclusive++;
    }

    //////////////// GETTERS /////////////////////

    /// @dev getter for legendary keys
    /// @param gen is the generation of legendary key to fetch
    // function fetchKeyByGen(uint256 gen) external view returns (HashFitLegendary _legendary) {
    //     _legendary = legendaryKeys[gen];
    // }

    /// @dev The first drop deployed by factory
    function genesis() external view returns (HashFitCore) {
        return drop[0];
    }

    /// @dev the last drop deployed by factory
    function lastGen() external view returns (HashFitCore) {
        return drop[nextGen - 1];
    }

    /// @dev getter for mythic key contract
    function mythic() external view returns (HashFitMythic) {
        return MYTHIC;
    }

    /// @dev getter for epic key contract
    function epic() external view returns (HashFitEpic) {
        return EPIC;
    }

    function legendary() external view returns (HashFitLegendary) {
        return LEGENDARY;
    }
}
