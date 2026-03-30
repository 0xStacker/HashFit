//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitTypes} from "../Types.sol";
import {IHashFitFactory} from "../interfaces/IHashFitFactory.sol";
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "../HashFitKeys.sol";
import {GenDropDeployer} from "./GenDropDeployer.sol";
import {ExclusiveDropDeployer} from "./ExclusiveDropDeployer.sol";
import {HashFitCore} from "../HashFit.sol";
import {HashFitExclusive} from "../HashFitExclusive.sol";
import {KeyBurner} from "../KeyBurner.sol";

/**
 * @title HashFit Factory
 * @author Ibrahim🐸
 *
 * HashFit factory is responsible for the deployment of new gen of HashFit drops.
 */
contract HashFitFactory is IHashFitFactory {
    bool deployersInitialized;
    /// Next generation of drop waiting to be deployed
    uint64 internal nextGen;
    uint64 internal nextExclusive;

    /// @dev The key burner contract
    address public keyBurner;

    /// @dev Non changing mythic key contract deployed with the factory
    HashFitMythic public mythic;

    /// @dev Non changing epic key contract deployed with the factory
    HashFitEpic public epic;

    /// @dev Non changing epic key contract deployed with the factory
    HashFitLegendary public legendary;

    GenDropDeployer internal genDropDeployer;

    ExclusiveDropDeployer internal exclusiveDropDeployer;

    /// @dev Admin who controls the entire factory
    /// @notice All administrative function accross all HashFit contract managed by ADMIN
    /// Check {HashFitAdmin} to see all administrative functions
    address private immutable ADMIN;

    /// @dev All deployed drops mapped by gen
    mapping(uint256 => HashFitCore) public drop;

    /// @dev getter variable for all deployed drops
    HashFitCore[] public getDrops;

    /// @dev getter variable for all deployed exclusives
    HashFitExclusive[] public getExclusive;

    /// @dev All deployed exclusive drops mapped by id
    mapping(uint256 => HashFitExclusive) exclusive;

    /// @dev Thrown when a non-admin address attempts to call administrative functions
    error UnauthorizedAccess();
    /// @dev Thrown when factory is not fully initialized by admin
    error FactoryNotFullyInitialized();
    /// @dev Thrown when multiple initialization of protocol dependent contracts is attempted by admin
    error AlreadyInitialized();

    // Emitted when a drop is created
    event CreateDrop(address indexed _drop, uint256 gen);

    struct Keys {
        address mythic;
        address legendary;
        address epic;
    }

    struct Deployers {
        address genDropDeployer;
        address exclusiveDropDeployer;
    }

    /// @dev Initialize factory as necessary
    constructor(Keys memory _keys) {
        ADMIN = msg.sender;
        mythic = HashFitMythic(_keys.mythic);
        legendary = HashFitLegendary(_keys.legendary);
        epic = HashFitEpic(_keys.epic);
        keyBurner = address(new KeyBurner());
    }

    /// @dev Enforce admin priviledges
    modifier onlyAdmin() {
        if (msg.sender != ADMIN) {
            revert UnauthorizedAccess();
        }
        _;
    }

    modifier fullyInitialized() {
        _fullyInitialized();
        _;
    }

    function initDeployers(Deployers memory _deployers) external onlyAdmin {
        if (deployersInitialized) {
            revert AlreadyInitialized();
        }
        genDropDeployer = GenDropDeployer(_deployers.genDropDeployer);
        exclusiveDropDeployer = ExclusiveDropDeployer(
            _deployers.exclusiveDropDeployer
        );
        deployersInitialized = true;
    }

    ///////////////////// DEPLOY DROPS ////////////////////

    /// @dev Admin creates new drop
    /// @param _setup contains the required data to initialize the drop. see {HashFitTypes.HashFitDrop}
    function deployHashFitDrop(
        HashFitTypes.HashFitDrop memory _setup
    ) external onlyAdmin fullyInitialized {
        _setup.generation = nextGen;
        HashFitCore nextGenDrop = genDropDeployer.deployDrop(_setup);
        drop[nextGen] = nextGenDrop;
        getDrops.push(nextGenDrop);
        nextGen++;
    }

    /// @dev Admin creates new exclusive drop
    /// @param _setup contains the required data to initialize the drop. see {HashFitTypes.HashFitDrop}
    /// @notice Function only callable after all keys have been deployed
    function deployHashFitExclusive(
        bytes32 merkleRoot,
        HashFitTypes.HashFitDrop memory _setup
    ) external onlyAdmin fullyInitialized {
        HashFitExclusive nextExclusiveDrop = exclusiveDropDeployer.deployDrop(
            _setup,
            merkleRoot
        );
        exclusive[nextExclusive] = nextExclusiveDrop;
        getExclusive.push(nextExclusiveDrop);
        nextExclusive++;
    }

    function _fullyInitialized() internal view {
        if (!deployersInitialized) {
            revert FactoryNotFullyInitialized();
        }
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

    /// @dev getter for all exclusive drops deployed by this factory
    function exclusiveDrops()
        external
        view
        returns (HashFitExclusive[] memory)
    {
        return getExclusive;
    }

    /// @dev getter for all gen drops deployed by this factory.
    function genDrops() external view returns (HashFitCore[] memory) {
        return getDrops;
    }

    /// @dev the last drop deployed by factory
    function lastGen() external view returns (HashFitCore) {
        return drop[nextGen - 1];
    }
}
