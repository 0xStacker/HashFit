// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {ERC1155} from "@openzeppelin/token/ERC1155/ERC1155.sol";

interface IHashFitFactory{
    function fetchKeyByGen(uint) external returns(address);
    function keyBurner() external returns(address);
}

interface IHashFitKey{
    function generation() external returns(uint);
    function balanceOf(address) external returns(uint);
    function ownerOf(uint) external returns(address);
    function safeTransferFrom(address, address, uint);
}

contract HashFit is ERC1155{
    // Current Drop Generation
    uint8 public immutable GENERATION;
    //
    address private immutable FACTORY;
    // Total unit of items in the drop
    uint8 public immutable TOTAL_SUPPLY;
    // Time when drop sale begins
    uint8 immutable SALE_START_TIME;
    // How long the cyphering stage of drop sale would last
    uint8 immutable CYPHERING_PHASE_DURATION;
    // Keys that are acceptable. this value indicates that all keys 
    uint8 immutable KEY_VALIDITY;

  
    string public contractUri;

    mapping(uint  => Item) dropItems;
    // Number of items that has been sold in the drop
    uint256 public totalSoldItems;

    struct Item{
        uint32 price;
        uint32 maxSupply;
        uint32 currentSupply;
        string name;
        string uri;
    }

    struct SaleItem{
        uint itemId;
        uint256 amount;
    }

    struct Key{
        uint keyGen;
        uint keyId;
    }

    event PurchaseAndClaim(uint item, uint amount, bool key)

    error SaleNotStarted();
    error NonTransferrable(); 
    error NotEnoughItems();
    error InsufficientFund();
    error UriRequestForNonExistentToken();
    error InsufficientKeys();
    error UnauthorizedKeyUsage(uint, uint);
    error UnableToTransferKey();
    error KeyMismatch();
    error ExpiredKey(uint)
    error CannotPurchaseItem(uint itemId, uint amount);

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
            SaleItem memory currentItem = _items[i]
            if dropItems[currentItem.itemId].currentSupply + currentItem.amount > dropItems[currentItem.itemId].maxSupply{
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }
            totalCost += dropItems[currentItem.itemId].price * currentItem.amount;
            if msg.value < totalCost{
                revert InsufficientFund();
            } 
           
            dropItems[currentItem].currentSupply += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, false);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");
        }
    }

    function purchaseWithKey(SaleItem[] _items, Key[] keys) external{
        if (items.length != keys.length){
            revert KeyMismatch();
        }
        for(uint i; i < items.length; i++){
            SaleItem memory currentItem = _items[i]
            if dropItems[currentItem.itemId].currentSupply + currentItem.amount > dropItems[currentItem.itemId].maxSupply{
                revert CannotPurchaseItem(currentItem.itemId, currentItem.amount);
            }

            IHashFitKey key = IHashFitKey(IHashFitFactory(FACTORY).fetchKeyByGen(keys[i].keyGen));
            if (GENERATION - key.generation() < KEY_VALIDITY){
                revert ExpiredKey(keyId)
            }
            if (key.balanceOf(msg.sender) < 1){
                revert InsufficientKeys(keys[i].keyGen);
            }
            if (msg.sender != key.ownerOf(keyId)){
                revert UnauthorizedKeyUsage(keys[i].keyGen, keys[i].keyId);
            }
            try{
                key.safeTransferFrom(msg.sender, IhashFitFactory(FACTORY).keyBurner(), keys[i].Id);
            }
            catch{
                revert UnableToTransferKey();
            }

            dropItems[currentItem].currentSupply += currentItem.amount;
            totalSoldItems += currentItem.amount;
            emit PurchaseAndClaim(currentItem.itemId, currentItem.amount, true);
            _mint(msg.sender, currentItem.amount, currentItem.itemId, "");
        }

    }

    function uri(uint256 itemId) public view override returns (string memory) {
        if !_itemExists(itemId){
            revert UriRequestForNonExistentToken();
        }
        return dropItems[itemId].uri;
    }

    /// @dev Number of units of an item remaining in the drop
    function itemsLeft(uint itemId) external returns(uint){
        return dropItems[itemid].maxSupply - dropItems[itemId].currentSupply;
    }

    function _itemExists(uint itemId) internal returns(bool){
        return dropItems[itemId].maxSupply != 0;
    } 


    // Prevent Transferablity
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override{
        revert NonTransferrable();
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override{
        revert NonTransferrable();
    }
    
    function setApprovalForAll(address operator, bool approved) public override{
        revert NonTransferrable();
    }
}
