// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
import {IERC721Receiver} from "@openzeppelin/token/ERC721/IERC721Receiver.sol";
import {IHashFitKey} from "./IHashFitKey.sol";

/**
 * @title Key Burner
 * @author Ibrahim
 * @notice 
 */

contract KeyBurner is IERC721Receiver{
    event KeyDestroyed(address ca, uint keyId);
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata data
    ) external returns (bytes4){
        (address ca, uint keyId) = abi.decode(data,(address, uint256));
        _burn(ca, keyId);
        emit KeyDestroyed(ca, keyId);
        return IERC721Receiver.onERC721Received.selector;
    }

    function _burn(address _ca, uint _keyId) internal{
        IHashFitKey(_ca).destroyKey(_keyId);
    }

}