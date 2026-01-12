 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {ERC1155} from "@openzeppelin/token/ERC1155/ERC1155.sol";
import {IHashFitKey} from "./IHashFitKey.sol";
import {IERC721A} from "@ERC721A/IERC721A.sol";
import {IHashFitFactory} from "./IHashFitFactory.sol";

/// @title HashFit Apparel Drop
/// @author Ibrahim
/**
 * A loyalty and identity system for a web3 backed sports wear brand
 *
 */
contract HashFit is ERC1155 {
    uint16 internal constant BPS = 10_000; // BPS value for % calculations 
    // HashFit Factory
    address internal immutable FACTORY;
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
    Item[] internal hashFitItems; 
    // Unique drop items
    mapping(uint256 => Item) dropItems;

    mapping(uint256 => uint256) public currentSupply;
    // Number of items that has been sold in the drop
    uint256 public totalSoldItems;

    // Holds required data for an apparel drop
    // Cyphering phase is a special limited sale phase at the begining of the drop
    // Purchasing an item within this phase would allow buyer wallet to be collected and considered
    // for random HashFit keys distribution offchain
    struct HashFitDrop {
        uint64 totalSupply; // How many individual items are in the drop
        uint64 generation; // Drop generation
        uint256 saleStartTime; // When the drop sale begins
        uint256 cypheringPhaseDuration; //
        Item[] items;
    }

    // Per item details
    struct Item {
        uint64 maxSupply; // Total units of an item present in the drop
        uint64 discount; // Percentage discount applied
        uint256 price; // Selling price of a unit of an item
        string name; // Item name
        string uri; // Item uri
    }

    // Item purchase details
    struct SaleItem {
        uint8 itemId; // Unique item identifier
        uint64 amount; // Unit of item being purchased
    }

    // HashFit key details
    struct Key {
        uint64 keyGen;
        uint64 keyId;
        bytes32 keyTier;
    }

    event PurchaseAndClaim(uint256 item, uint256 amount, bool key);
    event RedeemKey(address redeemer, uint256 keyGen, uint256 keyId);

    error SaleNotStarted();
    error NonTransferrable();
    error NotEnoughItems();
    error InsufficientFund();
    error UriRequestForNonExistentToken();
    error InsufficientKeys(address);
    error UnauthorizedKeyUsage(uint256, uint256);
    error UnableToTransferKey();
    error KeyMismatch();
    error ExpiredKey(uint256);
    error CannotPurchaseItem(uint256 itemId, uint256 amount);

    constructor(string memory _uri, HashFitDrop memory setup) ERC1155(_uri) {
        totalSupply = setup.totalSupply;
        GENERATION = setup.generation;
        SALE_START_TIME = setup.saleStartTime;
        CYPHERING_PHASE_DURATION = setup.cypheringPhaseDuration;
        for(uint i; i < setup.items.length; i++){
            dropItems[i] = setup.items[i];
            hashFitItems.push(setup.items[i]);
        }
    }

    function purchaseAndClaim(SaleItem[] memory _items, bytes32[] memory) external virtual payable {
        _purchaseAndClaim(_items);
    }

    /// @dev Purchase n units of m items
    function _purchaseAndClaim(SaleItem[] memory _items) internal {
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }
        if (totalSoldItems + _items.length > totalSupply) {
            revert NotEnoughItems();
        }

        uint256 totalCost;
        // Handle sale of all items requested.
        for (uint8 i; i < _items.length; i++) {
            SaleItem memory currentItem = _items[i];

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
    function purchaseWithKey(SaleItem[] memory _items, Key[] memory keys) external virtual {
        // Sanity check
        if (_items.length != keys.length) {
            revert KeyMismatch();
        }
        // Ensure sale has begun
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }
        // Fetch the addresses of the legendary key of the required generation
        // and the mythic key contract
        
        address keyContract;
        IHashFitKey key;
        address mythic = IHashFitFactory(FACTORY).mythic();

        for (uint256 i; i < _items.length; i++) {
            address legendary = IHashFitFactory(FACTORY).fetchKeyByGen(keys[i].keyGen);
            // Make sure item is not sold out
            SaleItem memory currentItem = _items[i];
            if (
                currentSupply[currentItem.itemId] + currentItem.amount
                    > dropItems[currentItem.itemId].maxSupply
            ) {
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }
            // Use the corressponding key for the next item.
            uint256 keyId = keys[i].keyId;
            bytes32 tier = keys[i].keyTier;
            // (address keyContract, IHashFitKey key) = tier == keccak256(bytes("LEGENDARY")) ? (legendary, IHashFitKey(legendary)):(mythic, IHashFitKey(mythic)) ;
            if (tier == keccak256(bytes("LEGENDARY"))) {
                keyContract = legendary;
                key = IHashFitKey(keyContract);
                // Check for legendary expiry
                if (GENERATION - key.generation() < key.keyValidity()) {
                    revert ExpiredKey(keyId);
                }
            } else if (tier == keccak256(bytes("MYTHIC"))) {
                // No expiry checks as mythic keys don't expire
                keyContract = mythic;
                key = IHashFitKey(keyContract);
            } else {
                // reject invalid keys e.g epic
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }

            // Assert key ownership
            if (IERC721A(keyContract).balanceOf(msg.sender) < 1) {
                revert InsufficientKeys(keyContract);
            }

            if (msg.sender != IERC721A(keyContract).ownerOf(keyId)) {
                revert UnauthorizedKeyUsage(keys[i].keyGen, keyId);
            }
            // Burn key and mint, validate sale and mint identity SBT
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

    // ADMIN GATED FUNCTIONS
    function restock(uint8 itemId, uint64 restockAmount) external {
        dropItems[itemId].maxSupply = restockAmount;
        totalSupply += restockAmount;
    }

    function setDiscount(uint8 itemId, uint64 discountBps) external{
        dropItems[itemId].discount = discountBps;
    }

    function uri(uint256 itemId) public view override returns (string memory) {
        if (!_itemExists(itemId)) {
            revert UriRequestForNonExistentToken();
        }
        return dropItems[itemId].uri;
    }

    function items() external returns(Item[] memory){
        return hashFitItems;
    }

    /// @dev Number of units of an item remaining in the drop
    function itemsLeft(uint256 itemId) external view returns (uint256) {
        return dropItems[itemId].maxSupply - currentSupply[itemId];
    }

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
