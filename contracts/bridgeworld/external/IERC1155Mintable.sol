// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface IERC1155Mintable is IERC1155Upgradeable {

    function mint(
        address _to,
        uint256 _itemId,
        uint256 _amount
    ) external;
}