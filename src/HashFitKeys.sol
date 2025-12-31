//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {ERC721A} from "@ERC721A/ERC721A.sol";
import {IHashFitKey} from "./IHashFitKey.sol";

abstract contract KeyScaffold is ERC721A, IHashFitKey {
    // How many generations key is valid for
    uint8 private immutable KEY_VALIDITY;
    address internal FACTORY;
    uint64 private immutable GENERATION;

    string public baseURI;
    
    constructor(Metadata _keyMetaData, KeyDetail _keydetail) ERC721A(_keyMetadata.name, _keyMetaData.symbol) {
        FACTORY = msg.sender;
        _keyMetadata.baseURI = _uri;
        KEY_VALIDITY = _keydetail.validity;
        GENERATION = _keydetail.generation;
    }

    struct Metadata{
        string name;
        string symbol;
        string uri;
    }

    struct KeyDetail{
        uint8 validity;
        uint64 generation;
    }

    modifier onlyFactory() {
        if (msg.sender != FACTORY) {
            revert IHashFitKey.UnauthorizedAccess();
        }
        _;
    }
    
    /// @dev admin gated function used for manual key distribution.
    function distributeKeys(Receiver[] memory receivers) external KeyScaffold.onlyFactory {
        for (uint256 i; i < receivers.length; i++) {
            _mint(receivers[i].receiverAddress, receivers[i].amount);
            emit DistributeKeys(receivers[i].receiverAddress, receivers[i].amount);
        }
    }
    
    /// @dev The drop generation in which key was created.
    function generation() external returns(uint gen){
        gen = GENERATION;
    }

    /// @dev The time frame for which key usage is valid.
    /// @notice a validity of 0 means key cannot expire (Mythic tier keys)
    /// @notice a validity of n (n >= 1) means keys are valid for the next n drops.
    function keyValidity() external returns(uint validity){
        validity = KEY_VALIDITY;
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function burn i
}

/// @title HashFit Mythic tier key
/// Features:
///       - Non transferrable
///       - No expiry
///       - Can be redeemed for an item in a mythic tier (exclusive) apparel drops
///       - Can be redeemed for exclusive irl perks (future updates)
contract HashFitMythic is KeyScaffold{

    function approve(address to, uint256 tokenId) public payable virtual override {
        revert MythicKeyNonTransferrable();
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        revert MythicKeyNonTransferrable();
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        revert MythicKeyNonTransferrable();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual override {
        revert MythicKeyNonTransferrable();
    }

}

/// @title HashFit Legendary tier key
/// Features:
///        - Transferrable
///        - Can be used to purchase an item in Legendary tier apparel drops or lower
///        - Expires if not used within the time frame for which its usage is valid
contract HashFitLegendary is KeyScaffold{
}

