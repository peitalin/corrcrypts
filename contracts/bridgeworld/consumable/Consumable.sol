//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "./ConsumableState.sol";

contract Consumable is Initializable, IConsumable, ConsumableState {
    using StringsUpgradeable for uint256;

    function initialize() external initializer {
        ConsumableState.__ConsumableState_init();
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "No token transfer while paused");
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
        uint256 value
    ) public override(IConsumable, ERC1155BurnableUpgradeable) {
        super.burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public override(IConsumable, ERC1155BurnableUpgradeable) {
        super.burnBatch(account, ids, values);
    }

     function airdropSingle(uint256 _id, uint256 _amount, address[] calldata _recipients) external onlyAdminOrOwner {
        require(_id > 0 && _amount > 0 && _recipients.length > 0, "Bad inputs given");

        for(uint256 i = 0; i < _recipients.length; i++) {
            _mint(_recipients[i], _id, _amount, "");
        }
    }

    function airdropMulti(uint256[] calldata _ids, uint256[] calldata _amounts, address[] calldata _recipients) external onlyAdminOrOwner {
        require(_ids.length == _amounts.length
            && _amounts.length == _recipients.length
            && _recipients.length > 0, "Bad inputs given");

        for(uint256 i = 0; i < _recipients.length; i++) {
            require(_amounts[i] > 0, "Bad amount");
            require(_ids[i] > 0, "Bad id");
            _mint(_recipients[i], _ids[i], _amounts[i], "");
        }
    }

    function setBaseUri(string memory _baseURI) external onlyAdminOrOwner {
        baseURI = _baseURI;
    }

    function uri(uint256 _typeId)
        public
        view
        override
        returns (string memory)
    {
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _typeId.toString())) : baseURI;
    }

}