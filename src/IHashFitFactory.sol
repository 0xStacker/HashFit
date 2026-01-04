// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IHashFitFactory {
    function fetchKeyByGen(uint256 keyGen) external returns (address, address);
    function keyBurner() external returns (address);

    event NewBurnerSet(address newBurner);
}
