//SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

interface IHashFitKey{

    event DistributeKeys(address indexed receiver, uint amount);
    error UnauthorizedAccess();

    struct Receiver{
        address receiverAddress;
        uint amount;
    }
    
    function distributeKeys(Receiver[] memory receivers) external;

    function generation() external returns(uint);
}