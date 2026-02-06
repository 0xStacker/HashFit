//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitTypes} from "./Types.sol";
import {ERC721A} from "@ERC721A/ERC721A.sol";
import {IHashFitKey} from "./interfaces/IHashFitKey.sol";

/**
 * @title HashFit Keys
 * @author Ibrahim 🐸
 * HashFit keys are NFT collectibles used to unlock exclusive perks for owner.
 * There are 3 different key tiers:
 *     - Mythic
 *     - Legendary
 *     - Epic
 *
 * Mythic Keys:
 *  - Mythic keys are the most rare key types
 *  - They carry multiple perks and can be redeemed at any point in time
 *  - They do not expire
 *  - Perks include:
 *      * Automatically whitelists holders for limited/exclusive perks
 *      * Can be redeemed for any item within exclusive drop in a 1:1 manner
 *      * Can be redeemed for irl perks such as gym passes.
 *      * Can also be redeemed for items on regular drops
 *
 * Legendary Keys:
 *  - Legendary keys are fairly rare keys with only one major use case;
 *  - They can basically be redeemed for any item within a regular drop in a 1:1 manner
 *  - Legendary keys however, have expiry which is determined by their validity
 *  - Users can redeem a legendary key for any item in drops that comes within its validity range
 *  - ex: A legendary key with 3 gen validity means users can redeem keys from that legendary key gen for
 *  - items in any of the next three generations of drops.
 *
 *
 *  Epic Keys:
 *   - Epic keys are basically minor coupons that can be applied on items to get further discounts
 */

abstract contract KeyScaffold is ERC721A, IHashFitKey {
    // How many generations key is valid for
    uint8 internal immutable KEY_VALIDITY;
    // Flag to check whether key for this gen has been distributed
    bool internal distributed;
    // Factory address
    address internal immutable ADMIN;
    // Generation in which key was created
    uint64 private immutable GENERATION;
    // Base uri
    string public baseURI;

    constructor(HashFitTypes.Metadata memory _keyMetaData, HashFitTypes.KeyDetail memory _keydetail, address _admin)
        ERC721A(_keyMetaData.name, _keyMetaData.symbol)
    {
        ADMIN = _admin;
        baseURI = _keyMetaData.uri;
        KEY_VALIDITY = _keydetail.validity;
        GENERATION = _keydetail.generation;
    }

    // admin priviledge calls
    modifier onlyAdmin() {
        if (msg.sender != ADMIN) {
            revert UnauthorizedAccess();
        }
        _;
    }

    // Owner priviledge calls
    modifier onlyOwner(uint256 tokenId) {
        if (msg.sender != ownerOf(tokenId)) {
            revert NotOwner(tokenId);
        }
        _;
    }

    // EIP 165
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IHashFitKey).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev admin gated function used for manual key distribution.
    function distributeKeys(HashFitTypes.Receiver[] memory receivers) external onlyAdmin {
        // Check whether key for this gen has been distributed
        if (distributed) {
            revert KeyDistributed(GENERATION);
        }
        for (uint256 i; i < receivers.length; i++) {
            _mint(receivers[i].receiverAddress, receivers[i].amount);
            emit DistributeKeys(receivers[i].receiverAddress, receivers[i].amount);
        }

        // Flag key as distributed and prevent newer ditributions
        distributed = true;
    }

    /// @dev The drop generation in which key was created.
    function generation() external view virtual returns (uint256 gen) {
        gen = GENERATION;
    }

    /// @dev The time frame for which key usage is valid.
    /// @notice a validity of 0 means key cannot expire (Mythic tier keys)
    /// @notice a validity of n (n >= 1) means keys are valid for the next n drops.
    function validity() external view returns (uint256 _validity) {
        _validity = KEY_VALIDITY;
    }

    /// @dev returns tier of the key
    /// Mythic > Legendary > Epic
    function keyTier() external virtual returns (bytes32) {
        return keccak256(bytes("KEY TIER"));
    }

    /// @dev All tokens return the same URI which is the image representation of the key
    function tokenURI(uint256) public view override returns (string memory) {
        return baseURI;
    }

    // keyId starts from 1
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @dev Destroys keyId from existence.
    function destroyKey(uint256 keyId) external onlyOwner(keyId) {
        _burn(keyId);
    }
}

/// @title HashFit Mythic tier key
/// Features:
///       - Non transferrable
///       - No expiry
///       - Can be redeemed for an item in a mythic tier (exclusive) apparel drops
///       - Can be redeemed for exclusive irl perks (future updates)
contract HashFitMythic is KeyScaffold {
    bytes32 internal constant TIER = keccak256("MYTHIC");

    constructor(string memory _uri, HashFitTypes.KeyDetail memory _keyDetail, address _admin)
        KeyScaffold(
            HashFitTypes.Metadata({name: "HashFit Mythic Key", symbol: "MYTHIC", uri: _uri}), _keyDetail, _admin
        )
    {}

    function keyTier() external pure override returns (bytes32) {
        return TIER;
    }

    function generation() external pure override returns (uint256) {
        return 0;
    }
}

/// @title HashFit Legendary tier key
/// Features:
///        - Transferrable
///        - Can be used to purchase an item in Legendary tier apparel drops or lower
///        - Expires if not used within the time frame for which its usage is valid
contract HashFitLegendary is KeyScaffold {
    bytes32 internal constant TIER = keccak256("LEGENDARY");
    constructor(string memory _uri, HashFitTypes.KeyDetail memory _keyDetail, address _admin)
        KeyScaffold(
            HashFitTypes.Metadata({name: "HashFit Legendary Key", symbol: "LEGENDARY", uri: _uri}), _keyDetail, _admin
        )
    {}

    function keyTier() external pure override returns (bytes32) {
        return TIER;
    }
}

contract HashFitEpic is KeyScaffold {
    bytes32 internal constant TIER = keccak256("EPIC");
    constructor(string memory _uri, HashFitTypes.KeyDetail memory _keyDetail, address _admin)
        KeyScaffold(HashFitTypes.Metadata({name: "HashFit Epic Key", symbol: "EPIC", uri: _uri}), _keyDetail, _admin)
    {}

    function keyTier() external pure override returns (bytes32) {
        return TIER;
    }
}

