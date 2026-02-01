 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitTypes} from "./Types.sol";
import {IHashFitErrors} from "./interfaces/IHashFitErrors.sol";
import {ERC1155} from "@openzeppelin/token/ERC1155/ERC1155.sol";
import {IHashFitKey} from "./interfaces/IHashFitKey.sol";
import {IERC721A} from "@ERC721A/IERC721A.sol";
import {IHashFitFactory} from "./interfaces/IHashFitFactory.sol";
import {HashFitLegendary, HashFitMythic} from "./HashFitKeys.sol";

/// @title HashFit Identity SBT
/// @author Ibrahim 🐸
/**
 * An identity and loyalty rewarding system for a clothing brand.
 * 
 *
 */
contract HashFitCore is ERC1155, IHashFitErrors{
    // BPS value for % calculations 
    uint16 internal constant BPS = 10_000; 
    // HashFit Factory
    address internal immutable ADMIN;
    // Factory contract
    IHashFitFactory FACTORY;
    // Total unit of items in the drop
    uint64 public totalSupply;
    // Current Drop Generation
    uint64 public immutable GENERATION;
    // Time when drop sale begins
    uint256 immutable SALE_START_TIME;
    // How long the cyphering stage of drop sale would last
    uint256 immutable CYPHERING_PHASE_DURATION;
    // SBT uri
    string public contractUri;
    // Unique HashFit items
    HashFitTypes.Item[] internal hashFitItems; 
    // Unique drop items
    mapping(uint256 => HashFitTypes.Item) dropItems;
    // Tracks the suppply of each unique item within the drop
    mapping(uint256 => uint256) public currentSupply;
    // Number of items that has been sold in the drop
    uint256 public totalSoldItems;

    /// @dev Used to collect info on what key a user would like to use when they attempt
    /// To make purchase with a key
    struct KeyInfo{
        uint64 gen; // Key generation
        uint64 keyId; // Unique key identifier
        bytes32 keyTier; // Key tier
    }

    /// @dev Initialize drop with required data
    constructor(string memory _uri, HashFitTypes.HashFitDrop memory setup, address _admin) ERC1155(_uri) {
        // Configure drop 
        totalSupply = setup.totalSupply;
        GENERATION = setup.generation;
        SALE_START_TIME = setup.saleStartTime;
        CYPHERING_PHASE_DURATION = setup.cypheringPhaseDuration;
        ADMIN = _admin;
        FACTORY = IHashFitFactory(msg.sender);
        // Add unique drop items to record
        for(uint i; i < setup.items.length; i++){
            dropItems[i] = setup.items[i];
            hashFitItems.push(setup.items[i]);
        }
    }

    // Enforce factory priviledges
    modifier onlyAdmin{
        if(msg.sender != ADMIN){
            revert UnauthorizedAccess();
        }
        _;
    }

    /// @dev Purchase an item from drop and claim identity SBT
    /// @param _items is the list of all items to be purchased
    function purchaseAndClaim(HashFitTypes.SaleItem[] memory _items, bytes32[] memory) external virtual payable {
        _purchaseAndClaim(_items);
    }


    /// @dev Purchase n units of m items
    function _purchaseAndClaim(HashFitTypes.SaleItem[] memory _items) internal {
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }
        if (totalSoldItems + _items.length > totalSupply) {
            revert NotEnoughItems();
        }

        uint256 totalCost;
        // Handle sale of all items requested.
        for (uint8 i; i < _items.length; i++) {
            HashFitTypes.SaleItem memory currentItem = _items[i];

            if (
                currentSupply[currentItem.itemId] + currentItem.amount
                    > dropItems[currentItem.itemId].maxSupply
            ) {
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }
            uint64 discount = dropItems[currentItem.itemId].discount;
            uint256 price = dropItems[currentItem.itemId].price;
            uint256 amount = currentItem.amount;
            totalCost += discount > 0 ? (price * amount * discount) / BPS : price * amount; 
            if (msg.value < totalCost) {
                revert InsufficientFund();
            }

            currentSupply[currentItem.itemId] += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, false);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");
        }
    }

    /// @dev Purchase items from drop using key in a 1:1 format
    /// @param _items contain info on every items in user cart
    /// @param keys contains info on the keys to be traded for _items
    function purchaseWithKey(HashFitTypes.SaleItem[] memory _items, KeyInfo[] memory keys) external virtual {
        // Sanity check
        if (_items.length != keys.length) {
            revert KeyMismatch();
        }
        // Ensure sale has begun
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }

        address keyContract;
        IHashFitKey key;

        // Non changing mythic key contract
        HashFitMythic mythic = FACTORY.mythic();
        
        for (uint256 i; i < _items.length; i++) {
            // Fetch key address by generation
            HashFitLegendary legendary = FACTORY.fetchKeyByGen(keys[i].gen);
            HashFitTypes.SaleItem memory currentItem = _items[i];
            // Make sure item is not sold out and the purchase amount does not exceed item supply
            if (!_canPurchase(currentItem)){
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }
            // Use the corressponding key for the next item.
            uint256 keyId = keys[i].keyId;
            bytes32 tier = keys[i].keyTier;
            // (address keyContract, IHashFitKey key) = tier == keccak256(bytes("LEGENDARY")) ? (legendary, IHashFitKey(legendary)):(mythic, IHashFitKey(mythic)) ;
            if (tier == keccak256("LEGENDARY")) {
                keyContract = address(legendary);
                key = legendary;
                // Check for legendary expiry
                if (GENERATION - key.generation() < key.validity()) {
                    revert ExpiredKey(keyId);
                }
            } else if (tier == keccak256("MYTHIC")) {
                // No expiry checks as mythic keys don't expire
                keyContract = address(mythic);
                key = mythic;
            } else {
                // reject invalid keys e.g epic
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }

            // Assert key ownership
            if (msg.sender != IERC721A(keyContract).ownerOf(keyId)) {
                revert UnauthorizedKeyUsage(keys[i].gen, keyId);
            }
            // Redeem key and mint, validate sale and mint identity SBT
            bytes memory burnInstruction = abi.encode(keyContract, keyId);
            try IERC721A(keyContract)
                .safeTransferFrom(msg.sender, IHashFitFactory(FACTORY).keyBurner(), keyId, burnInstruction) {
                emit RedeemKey(msg.sender, key.generation(), keyId);
            } catch {
                revert UnableToTransferKey();
            }

            currentSupply[currentItem.itemId] += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, true);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");
        }
    }

    /// @dev Checks whether an item can be purchased without exceeding its current max supply
    function _canPurchase(HashFitTypes.SaleItem memory item) internal view returns(bool){
        if (
            currentSupply[item.itemId] + item.amount
                > dropItems[item.itemId].maxSupply
        ) {
            return false;
        }
        return true;
    }

    // ADMIN GATED FUNCTIONS
    /// @dev Restocks a particular drop item 
    /// @param itemId is the identifier of the item to restock
    /// @param restockAmount is the amount of that item that is to be restocked
    /// NB: Restock can only be done through factory by an authorized admin
    function restock(uint8 itemId, uint64 restockAmount) external onlyAdmin{
        dropItems[itemId].maxSupply += restockAmount;
        totalSupply += restockAmount;
    }

    /// @dev Applies discount to a particular drop item
    /// @param itemId is the identifier of the item for which discount is to be applied
    /// @param discountBps defines the percentage of discount to be applied. (100bps = 1%)
    /// NB: Discount can only be set through factory by an authorized admin
    function setDiscount(uint8 itemId, uint64 discountBps) external onlyAdmin{
        dropItems[itemId].discount = discountBps;
    }

    /// @dev fetches the URI for an item
    function uri(uint256 itemId) public view override returns (string memory) {
        if (!_itemExists(itemId)) {
            revert UriRequestForNonExistentToken();
        }
        return dropItems[itemId].uri;
    }

    /// @dev getter for all unique drop items
    function items() external view returns(HashFitTypes.Item[] memory){
        return hashFitItems;
    }

    /// @dev Number of units of an item remaining in the drop
    function itemsLeft(uint256 itemId) external view returns (uint256) {
        return dropItems[itemId].maxSupply - currentSupply[itemId];
    }
    
    /// @dev Checks if an item exists in the drop
    function _itemExists(uint256 itemId) internal view returns (bool) {
        return dropItems[itemId].maxSupply != 0;
    }

    // Prevent Transferablity
    function safeTransferFrom(
        address,
        /*from*/
        address,
        /*to*/
        uint256,
        /*tokenId*/
        uint256,
        /*value*/
        bytes memory /*data*/
    )
        public
        pure
        override
    {
        revert NonTransferrable();
    }

    function safeBatchTransferFrom(
        address,
        /*from*/
        address,
        /*to*/
        uint256[] memory,
        /*ids*/
        uint256[] memory,
        /*values*/
        bytes memory /*data*/
    )
        public
        pure
        override
    {
        revert NonTransferrable();
    }

    function setApprovalForAll(
        address,
        /*operator*/
        bool /*approved*/
    )
        public
        pure
        override
    {
        revert NonTransferrable();
    }
}
