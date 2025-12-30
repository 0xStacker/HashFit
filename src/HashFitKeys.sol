//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {ERC721A} from "@ERC721A/ERC721A.sol";
import {IHashFitKey} from "./IHashFitKey.sol";

abstract contract KeyScaffold is ERC721A{
    address public FACTORY;
    string public baseURI;

    modifier onlyFactory{
        if (msg.sender != FACTORY){
            revert IHashFitKey.UnauthorizedAccess();
        }
        _;
    }

    function _startTokenId() internal pure override returns(uint){
        return 1;
    }

    function _baseURI() internal view override returns(string memory){
        return baseURI;
    }
}

contract HashFitMythic is KeyScaffold, IHashFitKey{
    uint public immutable generation;

    constructor(string memory name, string memory symbol, string memory _uri) ERC721A(name, symbol){
        FACTORY = msg.sender;
        baseURI = _uri;
    }
    function distributeKeys(Receiver[] memory receivers) external KeyScaffold.onlyFactory{
        for (uint i; i < receivers.length; i++){
            _mint(receivers[i].receiverAddress, receivers[i].amount);
            emit DistributeKeys(receivers[i].receiverAddress, receivers[i].amount);
        }
    }
}


contract HashFitLegendary is KeyScaffold, IHashFitKey{
    uint public immutable generation;

    constructor(string memory name, string memory symbol, string memory _uri) ERC721A(name, symbol){
        FACTORY = msg.sender;
        baseURI = _uri;
    }

    function distributeKeys(Receiver[] memory receivers) external onlyFactory{
        for (uint i; i < receivers.length; i++){
            _mint(receivers[i].receiverAddress, receivers[i].amount);
            emit DistributeKeys(receivers[i].receiverAddress, receivers[i].amount);
        }
    }
}

