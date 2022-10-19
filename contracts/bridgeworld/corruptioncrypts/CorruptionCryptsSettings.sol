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
}