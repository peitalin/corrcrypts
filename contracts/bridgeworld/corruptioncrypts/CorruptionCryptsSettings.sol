//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./CorruptionCryptsContracts.sol";

abstract contract CorruptionCryptsSettings is Initializable, CorruptionCryptsContracts {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    function __CorruptionCryptsSettings_init() internal initializer {
        CorruptionCryptsContracts.__CorruptionCryptsContracts_init();
    }

    function addTreasureCardInfo(
        uint256[] calldata _treasureIds,
        CardInfo[] calldata _cardInfo)
    external
    onlyAdminOrOwner
    {
        require(_treasureIds.length > 0 && _treasureIds.length == _cardInfo.length,
            "CorruptionCrypts: Bad array lengths");

        for(uint256 i = 0; i < _treasureIds.length; i++) {
            require(_cardInfo[i].north > 0
                && _cardInfo[i].east > 0
                && _cardInfo[i].south > 0
                && _cardInfo[i].west > 0,
                "CorruptionCrypts: Cards must have a value on each side");

            treasureIds.add(_treasureIds[i]);

            treasureIdToCardInfo[_treasureIds[i]] = _cardInfo[i];

            emit TreasureCardInfoSet(_treasureIds[i], _cardInfo[i]);
        }
    }

    function affinityForTreasure(uint256 _treasureId) public view returns(TreasureCategory) {
        return treasureIdToCardInfo[_treasureId].category;
    }
}