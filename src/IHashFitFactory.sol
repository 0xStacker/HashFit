// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IHashFitFactory{
    function fetchKeyByGen(uint keyGen) external returns(address);
    function keyBurner() external returns(address);

    event NewBurnerSet(address newBurner);
}