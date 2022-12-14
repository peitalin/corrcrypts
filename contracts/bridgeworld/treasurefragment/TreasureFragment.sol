//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "./TreasureFragmentState.sol";

contract TreasureFragment is Initializable, ITreasureFragment, TreasureFragmentState {
    using StringsUpgradeable for uint256;

    function initialize() external initializer {
        TreasureFragmentState.__TreasureFragmentState_init();
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data)
    internal
    override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(isAdmin(msg.sender) || isOwner(), "TreasureFragment: Only admin or owner can transfer");
    }

    function mint(address _to, uint256 _id, uint256 _amount) external override onlyAdminOrOwner whenNotPaused {

        _mint(_to, _id, _amount, "");
    }

    function adminSafeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount) external override onlyAdminOrOwner whenNotPaused {
        _safeTransferFrom(_from, _to, _id, _amount, "");
    }

    function adminSafeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts) external override onlyAdminOrOwner whenNotPaused {
        _safeBatchTransferFrom(_from, _to, _ids, _amounts, "");
    }

    function burn(
        address account,
        uint256 id,
        uint256 value)
    public
    override
    onlyAdminOrOwner
    whenNotPaused
    {
        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values)
    public
    override
    onlyAdminOrOwner
    whenNotPaused
    {
        _burnBatch(account, ids, values);
    }

}