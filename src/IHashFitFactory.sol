// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IHashFitFactory {
    function fetchKeyByGen(uint256 keyGen) external returns (address);
    function keyBurner() external returns (address);
    function mythic() external returns(address);
    function epic() external returns(address);

    event NewBurnerSet(address newBurner);
}
