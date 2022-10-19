//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../shared/AdminableUpgradeable.sol";
import "./LibCorruptionCryptsDiamond.sol";


abstract contract CorruptionCryptsGlobalState is Initializable, AdminableUpgradeable {

    LibCorruptionCryptsDiamond.AppStorage internal appStorage;

    uint8 MAX_TILES_ON_BOARD = 5;
    uint MAX_LEGIONS_ON_TEMPLES_BEFORE_RESET = 2;
    // should be like 4000 in practice

    // gobal temple locations

    // Corruption Diversion variables
    // Forbidden Crafts variables

    //////////////////////////////////
    /////// Global Epoch Variables
    //////////////////////////////////

    // every epoch lasts 1 hrs, players can draw maptiles once every hour
    uint currentEpoch = 0;
    uint epochStartTime = block.timestamp;
    uint epochDuration = 4 hours; // e.g. 4 hours
    uint epochEndTime = epochStartTime + epochDuration;

    mapping(address => mapping(uint => bool)) hasPlayerMovedInEpoch;
    // Keep track of each player => epoch => whether maptile was drawn
    uint MAX_PENDING_MOVES = 5;
    // players can "build up" up to 5 moves over a day
    uint GAME_ROUND = 1;
    // increment this when MAX_LEGIONS_ON_TEMPLES_BEFORE_RESET is reached
    event AdvancedEpoch(uint, uint);


    function __CorruptionCryptsGlobalState_init() internal initializer {
        AdminableUpgradeable.__Adminable_init();
    }

    modifier tryAdvanceEpoch() {
        // try advance epoch if it's after epochEndTime
        _advanceEpoch(block.timestamp);
        _;
    }

    function _calculatePendingMoves() internal returns (uint8 numPendingMoves) {

        require(
            !hasPlayerMovedInEpoch[msg.sender][currentEpoch],
            "Player already moved this epoch"
        );

        numPendingMoves = 0;
        // see how many moves have built up for the player over time
        for (uint i = 0; i < MAX_PENDING_MOVES; i++) {
            if (currentEpoch >= i) { // skip negative epochs
                if (!hasPlayerMovedInEpoch[msg.sender][currentEpoch - i]) {
                    numPendingMoves++;
                    hasPlayerMovedInEpoch[msg.sender][currentEpoch - i] = true;
                }
            }
        }
    }

    function _testSetCurrentEpoch(uint n) public onlyOwner {
        // test only
        currentEpoch = n;
    }

    function advanceEpoch() public {
        _advanceEpoch(block.timestamp);
    }

    function _advanceEpoch(uint _now) internal {
        // anyone can advance the epoch if current time is past endTime
        if (_now >= epochEndTime) {
            // if current time is far ahead of epochEndTime, fast forward
            // and automatically advance a bunch of epochs to present time
            uint numTimesToAdvance = (_now - epochStartTime) / epochDuration;
            epochStartTime = epochStartTime + (epochDuration * numTimesToAdvance);
            epochEndTime = epochStartTime + epochDuration;
            currentEpoch = currentEpoch + numTimesToAdvance;
            emit AdvancedEpoch(currentEpoch, numTimesToAdvance);
        }
    }

}
