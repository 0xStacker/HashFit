// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "../HashFitKeys.sol";

interface IHashFitFactory {
    // Fetches the addressof the key burner
    // The burner is responsible for destroying redeemed keys
    function keyBurner() external returns (address);

    // Fetches the non changing mythic key
    function mythic() external returns (HashFitMythic);

    function legendary() external returns (HashFitLegendary);

    // Fetches the epic key
    function epic() external returns (HashFitEpic);

    event NewBurnerSet(address newBurner);
}
