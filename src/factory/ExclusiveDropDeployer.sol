//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {HashFitExclusive} from "../HashFitExclusive.sol";
import {HashFitTypes} from "../Types.sol";

contract ExclusiveDropDeployer {
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
        HashFitTypes.HashFitDrop memory _setup,
        bytes32 _root
    ) external onlyCoreFactory returns (HashFitExclusive) {
        return new HashFitExclusive(_root, _setup, admin, coreFactory);
    }
}
