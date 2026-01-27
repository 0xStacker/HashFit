// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "../HashFitKeys.sol";

interface IHashFitFactory {
    function fetchKeyByGen(uint256 keyGen) external returns (HashFitLegendary);
    function keyBurner() external returns (address);
    function mythic() external returns(HashFitMythic);
    function epic() external returns(HashFitEpic);

    event NewBurnerSet(address newBurner);
  
}
