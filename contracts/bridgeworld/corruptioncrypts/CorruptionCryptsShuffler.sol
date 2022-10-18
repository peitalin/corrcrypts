//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "hardhat/console.sol";
import "./CorruptionCryptsSettings.sol";
import "../../shared/ShittyRandom.sol";


abstract contract CorruptionCryptsShuffler is Initializable, CorruptionCryptsSettings {

    uint receiptId;

    ShittyRandom public shittyRandom = new ShittyRandom();

    function __CorruptionCryptsShuffler_init() internal initializer {
        CorruptionCryptsSettings.__CorruptionCryptsSettings_init();
    }

    function drawRandomMapTileId(uint _requestId) public view returns (uint) {

        // uint256 _randomNumber = appStorage.randomizer.revealRandomNumber(_requestId);
        // Figure out how to use real randomizer......
        uint256 _randomNumber = uint256(keccak256(abi.encode(_requestId,
            609697701829039857854141943741550340)));
        _randomNumber = shittyRandom.requestRandomNumber(_randomNumber);

        uint256 mapTileId = _randomNumber % NUM_MAPTILES + 1;
        // +1 because maptiles must be 1 - 32
        return mapTileId;
    }


    // Need to adjust random number after calling this function.
    // Adjust be 8 * _amount bits.
    function _pickRandomUniqueCoordinates(
        uint8 _amount,
        uint256 _randomNumber
    ) private pure returns(uint8[2][] memory) {
        uint8[2][9] memory _gridCells = [
            [0,0],
            [0,1],
            [0,2],
            [1,0],
            [1,1],
            [1,2],
            [2,0],
            [2,1],
            [2,2]
        ];

        uint8 _numCells = 9;

        uint8[2][] memory _pickedCoordinates = new uint8[2][](_amount);

        for(uint256 i = 0; i < _amount; i++) {
            uint256 _cell = _randomNumber % _numCells;
            _pickedCoordinates[i] = _gridCells[_cell];
            _randomNumber >>= 8;
            _numCells--;
            if(_cell != _numCells) {
                _gridCells[_cell] = _gridCells[_numCells];
            }
        }

        return _pickedCoordinates;
    }


    // Need to adjust random number after calling this function.
    // Adjust be 8 * _amount bits.
    function _pickRandomUniqueTempleCoordinates(
        uint8 _amount,
        uint256 _randomNumber
    ) internal view returns(uint8[2][] memory) {

        // uint256 _randomNumber = appStorage.randomizer.revealRandomNumber(_requestId);
        _randomNumber = uint256(keccak256(abi.encode(_randomNumber,
            609697701829039857854141943741550340)));
        _randomNumber = shittyRandom.requestRandomNumber(_randomNumber);

        uint8[2][13] memory _gridCells = [
            [0,0],
            [1,0],
            [2,0],
            [3,0],
            [4,0],
            [5,0],
            [6,0],
            [7,0],
            [7,0],
            [7,1],
            [7,2],
            [7,3],
            [7,4]
        ];
        // can only be on the 1st col or 8th col.
        // can only be on the 1st row or 5th row.

        uint8 _numCells = 13;

        uint8[2][] memory _pickedCoordinates = new uint8[2][](_amount);

        for(uint256 i = 0; i < _amount; i++) {
            uint256 _cell = _randomNumber % _numCells;
            _pickedCoordinates[i] = _gridCells[_cell];
            _randomNumber >>= 8;
            _numCells--;
            if(_cell != _numCells) {
                _gridCells[_cell] = _gridCells[_numCells];
            }
        }

        return _pickedCoordinates;
    }
}