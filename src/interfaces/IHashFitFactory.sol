// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "../HashFitKeys.sol";

interface IHashFitFactory {
    //Fetches the Legendary key contract for a particular drop gen
    // gen is the drop generation to fetch key for
    function fetchKeyByGen(uint256 gen) external returns (HashFitLegendary);

    // Fetches the address of the key burner
    // The burner is responsible for destroying redeemed keys
    function keyBurner() external returns (address);

    // Fetches the non changing mythic key 
    function mythic() external returns(HashFitMythic);
    // Fetches the epic key
    function epic() external returns(HashFitEpic);
    event NewBurnerSet(address newBurner);
  
}
