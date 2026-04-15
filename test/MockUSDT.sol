// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {
    constructor() ERC20("USDC-H", "USDC-H") {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
