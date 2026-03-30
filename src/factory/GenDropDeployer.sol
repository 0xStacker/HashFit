//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitCore} from "../HashFit.sol";
import {HashFitTypes} from "../Types.sol";

contract GenDropDeployer {
    address coreFactory;
    address admin;

    error UnauthorizedAccess();

    constructor(address _coreFactory, address _admin) {
        coreFactory = _coreFactory;
        admin = _admin;
    }

    modifier onlyCoreFactory() {
        _onlyCoreFactory();
        _;
    }

    function _onlyCoreFactory() internal view {
        if (msg.sender != coreFactory) {
            revert UnauthorizedAccess();
        }
    }

    function deployDrop(
        HashFitTypes.HashFitDrop memory _setup
    ) external onlyCoreFactory returns (HashFitCore) {
        return new HashFitCore(_setup, admin);
    }
}
