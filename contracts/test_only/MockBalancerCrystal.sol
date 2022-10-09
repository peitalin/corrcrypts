//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract MockBalancerCrystal is ERC1155Upgradeable {

    function initialize() external initializer {
        ERC1155Upgradeable.__ERC1155_init("");
    }

    function mint(address _account, uint256 _id, uint256 _amount) external {
        _mint(_account, _id, _amount, "");
    }

    function adminSafeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount)
    external {
        _safeTransferFrom(_from, _to, _id, _amount, "");
    }

    function adminSafeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts)
    external {
        _safeBatchTransferFrom(_from, _to, _ids, _amounts, "");
    }
}