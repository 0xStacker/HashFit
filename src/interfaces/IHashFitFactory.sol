// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitMythic, HashFitEpic} from "../HashFitKeys.sol";

interface IHashFitFactory {
    function fetchKeyByGen(uint256 keyGen) external returns (address);
    function keyBurner() external returns (address);
    function mythic() external returns(HashFitEpic);

    event NewBurnerSet(address newBurner);
    event RestockItem(uint, uint, uint);
    event SetDiscount(uint64, uint8, uint64);
}
