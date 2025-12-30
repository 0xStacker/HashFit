// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {ERC1155} from "@openzeppelin/token/ERC1155/ERC1155.sol";
import {IHashFitKey} from "./IHashFitKey.sol";
import {IERC721A} from "@ERC721A/IERC721A.sol";
import {IHashFitFactory} from "./IHashFitFactory.sol";

contract HashFit is ERC1155{
    // How many generations key is valid for
    uint8 immutable KEY_VALIDITY;
    // Total unit of items in the drop
    uint64 public immutable TOTAL_SUPPLY;
    // Current Drop Generation
    uint64 public immutable GENERATION;
    // Time when drop sale begins
    uint256 immutable SALE_START_TIME;
    // How long the cyphering stage of drop sale would last
    uint256 immutable CYPHERING_PHASE_DURATION;

    address private immutable FACTORY;
  
    string public contractUri;

    mapping(uint256  => Item) dropItems;
    // Number of items that has been sold in the drop
    uint256 public totalSoldItems;

    //
    struct HashFitDrop{
        uint64 totalSupply;
        uint64 generation;
        uint256 saleStartTime;
        uint256 cypheringPhaseDuration;
    }

    // Per item details
    struct Item{
        uint64 maxSupply; // Total units of an item present in the drop
        uint64 currentSupply; // Total number of an item that has been sold
        uint256 price; // Selling price of a unit of an item
        string name; // Item name
        string uri; // Item uri
    }

    // Item purchase details
    struct SaleItem{
        uint8 itemId; // Unique item identifier
        uint64 amount; // Unit of item being purchased
    }

    // HashFit key details
    struct Key{
        uint64 keyGen; 
        uint64 keyId;
    }

    event PurchaseAndClaim(uint item, uint amount, bool key);
    event RedeemKey(address redeemer, uint keyGen, uint keyId); 

    error SaleNotStarted();
    error NonTransferrable(); 
    error NotEnoughItems();
    error InsufficientFund();
    error UriRequestForNonExistentToken();
    error InsufficientKeys(address);
    error UnauthorizedKeyUsage(uint, uint);
    error UnableToTransferKey();
    error KeyMismatch();
    error ExpiredKey(uint);
    error CannotPurchaseItem(uint itemId, uint amount);

    constructor(string memory _uri, HashFitDrop memory setup
        ) ERC1155(_uri){
            TOTAL_SUPPLY = setup.totalSupply;
            GENERATION = setup.generation;
            SALE_START_TIME = setup.saleStartTime;
            CYPHERING_PHASE_DURATION = setup.cypheringPhaseDuration;
    }
    
    /// @dev Purchase n units of m items
    function purchaseAndClaim(SaleItem[] memory _items) external payable{
        if (block.timestamp < SALE_START_TIME){
            revert SaleNotStarted();
        }
        if (totalSoldItems + _items.length > TOTAL_SUPPLY){
            revert NotEnoughItems();
        }

        uint totalCost;
        //Calculate cost
        for (uint8 i; i < _items.length; i++){
            SaleItem memory currentItem = _items[i];

            if (dropItems[currentItem.itemId].currentSupply + currentItem.amount > dropItems[currentItem.itemId].maxSupply){
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }
            totalCost += dropItems[currentItem.itemId].price * currentItem.amount;
            if (msg.value < totalCost){
                revert InsufficientFund();
            } 
           
            dropItems[currentItem.itemId].currentSupply += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, false);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");
        }
    }

    function purchaseWithKey(SaleItem[] memory _items, Key[] memory keys) external{
        if (_items.length != keys.length){
            revert KeyMismatch();
        }
        for(uint i; i < _items.length; i++){
            SaleItem memory currentItem = _items[i];
            if (dropItems[currentItem.itemId].currentSupply + currentItem.amount > dropItems[currentItem.itemId].maxSupply){
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }

            address keyContract = IHashFitFactory(FACTORY).fetchKeyByGen(keys[i].keyGen);
            IHashFitKey key = IHashFitKey(keyContract);
            if (GENERATION - key.generation() < KEY_VALIDITY){
                revert ExpiredKey(keys[i].keyId);
            }

            if (IERC721A(keyContract).balanceOf(msg.sender) < 1){
                revert InsufficientKeys(keyContract);
            }
            if (msg.sender != IERC721A(keyContract).ownerOf(keys[i].keyId)){
                revert UnauthorizedKeyUsage(keys[i].keyGen, keys[i].keyId);
            }
            try IERC721A(keyContract).safeTransferFrom(msg.sender, IHashFitFactory(FACTORY).keyBurner(), keys[i].keyId){
               emit RedeemKey(msg.sender, key.generation(), keys[i].keyId);
            }
            catch{
                revert UnableToTransferKey();
            }

            dropItems[currentItem.itemId].currentSupply += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, true);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");
        }

    }

    function uri(uint256 itemId) public view override returns (string memory) {
        if (!_itemExists(itemId)){
            revert UriRequestForNonExistentToken();
        }
        return dropItems[itemId].uri;
    }

    /// @dev Number of units of an item remaining in the drop
    function itemsLeft(uint itemId) external view returns(uint){
        return dropItems[itemId].maxSupply - dropItems[itemId].currentSupply;
    }

    function _itemExists(uint itemId) internal view returns(bool){
        return dropItems[itemId].maxSupply != 0;
    } 


    // Prevent Transferablity
    function safeTransferFrom(address /*from*/, address /*to*/, uint256 /*tokenId*/, uint256 /*value*/, bytes memory /*data*/) public pure override{
        revert NonTransferrable();
    }

    function safeBatchTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256[] memory /*ids*/,
        uint256[] memory /*values*/,
        bytes memory /*data*/
    ) public pure override{
        revert NonTransferrable();
    }
    
    function setApprovalForAll(address /*operator*/, bool /*approved*/) public pure override{
        revert NonTransferrable();
    }
}
