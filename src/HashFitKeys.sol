//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {ERC721A} from "@ERC721A/ERC721A.sol";
import {IHashFitKey, IHashFitLegendary, IHashFitMythic} from "./IHashFitKey.sol";

/**
 * @title HashFit Keys
 * @author Ibrahim
 * HashFit keys are NFTs used to unlock exclusive perks for owner.
 * There are 3 different key tiers:
    - Mythic
    - Legendary
    - Epic
 */

abstract contract KeyScaffold is ERC721A, IHashFitKey {
    // How many generations key is valid for
    uint8 private immutable KEY_VALIDITY;
    // Factory address
    address internal immutable FACTORY;
    // Generation in which key was created
    uint64 private immutable GENERATION;
    // Base uri
    string public baseURI;
    
    constructor(Metadata memory _keyMetaData, KeyDetail memory _keydetail) ERC721A(_keyMetaData.name, _keyMetaData.symbol) {
        FACTORY = msg.sender;
        baseURI = _keyMetaData.uri;
        KEY_VALIDITY = _keydetail.validity;
        GENERATION = _keydetail.generation;
    }

    // Key Metadata
    struct Metadata{
        string name;
        string symbol;
        string uri;
    }

    struct KeyDetail{
        uint8 validity; // How many  generation key is valid for use
        uint64 generation; // Generation which key was created
    }

    // Factory priviledge calls
    modifier onlyFactory() {
        if (msg.sender != FACTORY) {
            revert IHashFitKey.UnauthorizedAccess();
        }
        _;
    }

    // Owner priviledged calls
    modifier onlyOwner(uint256 tokenId){
        if(msg.sender != ownerOf(tokenId)){
            revert UnauthorizedAccess();
        }
        _;
    }
    
    // EIP 165
    function supportsInterface(bytes4 interfaceId) external override returns(bool){
        return interfaceId == type(IHashFItKey).interfaceId || super.supportsInterface()
    }
    /// @dev admin gated function used for manual key distribution.
    function distributeKeys(Receiver[] memory receivers) external onlyFactory {
        for (uint256 i; i < receivers.length; i++) {
            _mint(receivers[i].receiverAddress, receivers[i].amount);
            emit DistributeKeys(receivers[i].receiverAddress, receivers[i].amount);
        }
    }
    
    /// @dev The drop generation in which key was created.
    function generation() external view returns(uint gen){
        gen = GENERATION;
    }

    /// @dev The time frame for which key usage is valid.
    /// @notice a validity of 0 means key cannot expire (Mythic tier keys)
    /// @notice a validity of n (n >= 1) means keys are valid for the next n drops.
    function keyValidity() external view returns(uint validity){
        validity = KEY_VALIDITY;
    }

    function keyTier() external virtual returns(bytes32 memory){
        return keccak256(bytes("KEY TIER"));
    }
    // keyId starts from 1
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @dev Destroys a key from existence.
    function destroyKey(uint256 tokenId) external onlyOwner(tokenId){
        _burn(tokenId);
    }
}

/// @title HashFit Mythic tier key
/// Features:
///       - Non transferrable
///       - No expiry
///       - Can be redeemed for an item in a mythic tier (exclusive) apparel drops
///       - Can be redeemed for exclusive irl perks (future updates)
contract HashFitMythic is KeyScaffold{
    bytes32 internal constant TIER = keccak256(bytes("MYTHIC"));

    constructor(Metadata memory _keyMetaData, KeyDetail memory _keyDetail) KeyScaffold(_keyMetaData, _keyDetail){}
    
    function keyTier() external override returns(bytes32){
        return TIER;
    }

    function approve(address, uint256) public payable virtual override {
        revert MythicKeyNonTransferrable();
    }


    function setApprovalForAll(address, bool) public virtual override {
        revert MythicKeyNonTransferrable();
    }

    function transferFrom(
        address, 
        address,
        uint256
    ) public payable virtual override {
        revert MythicKeyNonTransferrable();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public payable virtual override {
        revert MythicKeyNonTransferrable();
    }

}

/// @title HashFit Legendary tier key
/// Features:
///        - Transferrable
///        - Can be used to purchase an item in Legendary tier apparel drops or lower
///        - Expires if not used within the time frame for which its usage is valid
contract HashFitLegendary is KeyScaffold, IHashFitLengendary{
    bytes32 internal constant TIER = keccak256(bytes("LEGENDARY"));
    constructor(Metadata memory _keyMetaData, KeyDetail memory _keyDetail) KeyScaffold(_keyMetaData, _keyDetail){}

    function keyTier() external override returns(bytes32){
        return TIER;
    }
}

