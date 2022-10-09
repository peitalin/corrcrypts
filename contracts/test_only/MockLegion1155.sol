//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract MockLegion1155 is ERC1155Upgradeable {

    function initialize() external initializer {
        ERC1155Upgradeable.__ERC1155_init("");
    }

    function mint(address _account, uint256 _id, uint256 _amount) external {
        _mint(_account, _id, _amount, "");
    }
}