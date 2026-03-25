// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitTypes} from "./Types.sol";
import {IHashFitErrors} from "./interfaces/IHashFitErrors.sol";
import {ERC1155} from "@openzeppelin/token/ERC1155/ERC1155.sol";
import {IHashFitKey} from "./interfaces/IHashFitKey.sol";
import {IERC721A} from "@ERC721A/IERC721A.sol";
import {IERC20} from "@openzeppelin/interfaces/IERC20.sol";
import {IHashFitFactory} from "./interfaces/IHashFitFactory.sol";
import {HashFitLegendary, HashFitMythic} from "./HashFitKeys.sol";
import {ReentrancyGuard} from "@openzeppelin/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {console} from "forge-std/Test.sol";

/// @title HashFit Identity SBT
/// @author Ibrahim 🐸
/**
 * An identity and loyalty rewarding system for a clothing brand.
 *
 *
 */
contract HashFitCore is ERC1155, IHashFitErrors, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // USDT
    IERC20 immutable USDT;
    // BPS value for % calculations
    uint16 internal constant BPS = 10_000;

    // HashFit Admin contorls all administrative functions
    address internal immutable ADMIN;

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

    //
    uint256[] itemIds;
    // Unique HashFit items
    HashFitTypes.Item[] internal hashFitItems;

    // Unique drop items
    mapping(uint256 => HashFitTypes.Item) public dropItems;

    // Tracks the suppply of each unique item within the drop
    mapping(uint256 => uint256) public currentSupply;

    // Number of items that has been sold in the drop
    uint256 public totalSoldItems;

    /// @dev Initialize drop with required data
    constructor(HashFitTypes.HashFitDrop memory setup, address _admin) ERC1155(setup.uri) ReentrancyGuard() {
        GENERATION = setup.generation;
        SALE_START_TIME = setup.saleStartTime;
        CYPHERING_PHASE_DURATION = setup.cypheringPhaseDuration;
        ADMIN = _admin;
        USDT = IERC20(setup.token);
        // Add unique drop items to record
        for (uint256 i; i < setup.items.length; i++) {
            dropItems[i] = setup.items[i];
            itemIds.push(i);
            totalSupply += setup.items[i].maxSupply;
        }
        _updateItems();
    }

    // Enforce admin priviledges
    modifier onlyAdmin() {
        if (msg.sender != ADMIN) {
            revert UnauthorizedAccess();
        }
        _;
    }

    /// @dev Purchase an item from drop and claim identity SBT
    /// @param _items is the list of all items to be purchased
    function purchaseAndClaim(HashFitTypes.SaleItem[] memory _items, bytes32[] memory)
        external
        payable
        virtual
        nonReentrant
    {
        _purchaseAndClaim(_items);
    }

    /// @dev Purchase n units of m items with no key involvements
    function _purchaseAndClaim(HashFitTypes.SaleItem[] memory _items) internal {
        if (block.timestamp < SALE_START_TIME) {
            revert SaleNotStarted();
        }

        if (_items.length == 0) {
            revert NotEnoughItems();
        }

        uint256 totalCost;
        // Destructure bag and handle sale of all items present.
        for (uint8 i; i < _items.length; i++) {
            HashFitTypes.SaleItem memory currentItem = _items[i];

            if (!_canPurchase(currentItem)) {
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }
            uint64 discount = dropItems[currentItem.itemId].discount;
            uint256 price = dropItems[currentItem.itemId].price;
            uint256 amount = currentItem.amount;
            totalCost += discount > 0 ? ((price * amount) - ((price * amount * discount) / BPS)) : price * amount;
            if (USDT.balanceOf(tx.origin) < totalCost) {
                revert InsufficientFund();
            }

            currentSupply[currentItem.itemId] += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, false);
            _mint(tx.origin, currentItem.itemId, currentItem.amount, "");
        }

        USDT.safeTransferFrom(tx.origin, ADMIN, totalCost);
    }

    function _updateItems() internal {
        delete hashFitItems;
        for (uint8 i; i < itemIds.length; i++) {
            HashFitTypes.Item storage item = dropItems[itemIds[i]];
            hashFitItems.push(item);
        }
    }

    /// @dev Checks whether an item can be purchased without exceeding its current max supply
    function _canPurchase(HashFitTypes.SaleItem memory item) internal view returns (bool) {
        if (currentSupply[item.itemId] + item.amount > dropItems[item.itemId].maxSupply) {
            return false;
        }
        return true;
    }

    // ADMIN GATED FUNCTIONS
    /// @dev Restocks a particular drop item
    /// @param itemId is the identifier of the item to restock
    /// @param restockAmount is the amount of that item that is to be restocked
    /// NB: Restock can only be done through factory by an authorized admin
    function restock(uint8 itemId, uint64 restockAmount) external onlyAdmin {
        dropItems[itemId].maxSupply += restockAmount;
        _updateItems();
        totalSupply += restockAmount;
    }

    /// @dev Applies discount to a particular drop item
    /// @param itemId is the identifier of the item for which discount is to be applied
    /// @param discountBps defines the percentage of discount to be applied. (100bps = 1%)
    /// NB: Discount can only be set through factory by an authorized admin
    function setDiscount(uint8 itemId, uint64 discountBps) external onlyAdmin {
        dropItems[itemId].discount = discountBps;
        _updateItems();
    }

    /// @dev fetches the URI for an item
    function uri(uint256 itemId) public view override returns (string memory) {
        if (!_itemExists(itemId)) {
            revert UriRequestForNonExistentToken();
        }
        return dropItems[itemId].uri;
    }

    /// @dev getter for all unique drop items
    function items() external view returns (HashFitTypes.Item[] memory) {
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
