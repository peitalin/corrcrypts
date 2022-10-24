//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./CorruptionCryptsContracts.sol";



abstract contract CorruptionCryptsSettings is Initializable, CorruptionCryptsContracts {

    function __CorruptionCryptsSettings_init() internal initializer {
        CorruptionCryptsContracts.__CorruptionCryptsContracts_init();
    }

    event SetEpochDuration(uint);
    event SetMaxMapTilesOnBoard(uint8);
    event SetMaxPendingMoves(uint8);
    event SetMaxLegionsOnTemplesBeforeReset(uint);
    event SetNumHarvesters(uint8);

    function setEpochDuration(uint newDuration) external onlyAdminOrOwner {
        // 1 hours, 25 minutes, etc
        epochDuration = newDuration;
        emit SetEpochDuration(newDuration);
    }

    function setMaxMapTilesOnBoard(uint8 _maxMapTilesOnBoard) external onlyAdminOrOwner {
        // unimplemented
        MAX_TILES_ON_BOARD = _maxMapTilesOnBoard;
        emit SetMaxMapTilesOnBoard(_maxMapTilesOnBoard);
    }

    function setMaxPendingMoves(uint8 _maxPendingMoves) external onlyAdminOrOwner {
        // unimplemented
        MAX_PENDING_MOVES = _maxPendingMoves;
        emit SetMaxPendingMoves(_maxPendingMoves);
    }

    function setMaxLegionsOnTemplesBeforeReset(uint _maxLegionsOnTemplesBeforeReset) external onlyAdminOrOwner {
        // unimplemented
        MAX_LEGIONS_ON_TEMPLES_BEFORE_RESET = _maxLegionsOnTemplesBeforeReset;
        emit SetMaxLegionsOnTemplesBeforeReset(_maxLegionsOnTemplesBeforeReset);
    }

    function setNumHarvesters(uint8 newNumHarvesters) external onlyAdminOrOwner {
        NUM_HARVESTERS = newNumHarvesters;
        emit SetNumHarvesters(newNumHarvesters);
    }

    function getTempleHarvester(uint t) pure internal returns (Temple temple) {

        temple = Temple.None;
        // if t == 0; temple is None

        if (t == 1) {
            temple = Temple.Harvester1;
        }
        if (t == 2) {
            temple = Temple.Harvester2;
        }
        if (t == 3) {
            temple = Temple.Harvester3;
        }
        if (t == 4) {
            temple = Temple.Harvester4;
        }
        if (t == 5) {
            temple = Temple.Harvester5;
        }
        if (t == 6) {
            temple = Temple.Harvester6;
        }
        if (t == 7) {
            temple = Temple.Harvester7;
        }
        if (t == 8) {
            temple = Temple.Harvester8;
        }
        if (t == 9) {
            temple = Temple.Harvester9;
        }
        // // not used
        // if (t == 9) {
        //     temple = Temple.ForbiddenCrafts;
        // } else {
        //     temple = Temple.None;
        // }
    }
}

enum Temple {
    None,
    Harvester1,
    Harvester2,
    Harvester3,
    Harvester4,
    Harvester5,
    Harvester6,
    Harvester7,
    Harvester8,
    Harvester9,
    ForbiddenCrafts
}
