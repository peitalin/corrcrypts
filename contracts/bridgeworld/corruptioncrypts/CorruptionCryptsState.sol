//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../legionmetadatastore/ILegionMetadataStore.sol";
import "../treasuremetadatastore/ITreasureMetadataStore.sol";

import "./ICorruptionCrypts.sol";
import "../../shared/AdminableUpgradeable.sol";
import "./LibCorruptionCryptsDiamond.sol";


abstract contract CorruptionCryptsState is Initializable, ICorruptionCrypts, AdminableUpgradeable {

    LibCorruptionCryptsDiamond.AppStorage internal appStorage;

    event TreasureCardInfoSet(uint256 _treasureId, CardInfo _cardInfo);

    uint8 constant NUMBER_OF_CONTRACT_CARDS = 3;
    uint8 constant NUMBER_OF_CELLS_WITH_AFFINITY = 2;
    uint8 constant MAX_NUMBER_OF_CORRUPTED_CELLS = 2;

    EnumerableSetUpgradeable.UintSet internal treasureIds;
    // Maps the treasure id to the info about the card.
    // Used for both contract and player placed cards.
    mapping(uint256 => CardInfo) public treasureIdToCardInfo;

    // The base rarities for each tier of treasure out of 256.
    uint8[5] public baseTreasureRarityPerTier;

    uint8 public numberOfFlippedCardsToWin;

    // IRandomizer public randomizer;

    function __CorruptionCryptsState_init() internal initializer {
        AdminableUpgradeable.__Adminable_init();

        baseTreasureRarityPerTier = [51, 51, 51, 51, 52];

        numberOfFlippedCardsToWin = 2;

    }

}

struct CardInfo {
    // While this is a repeat of the information stored in TreasureMetadataStore, overall it is beneficial
    // to have this information readily available in this contract.
    TreasureCategory category;
    uint8 north;
    uint8 east;
    uint8 south;
    uint8 west;
}