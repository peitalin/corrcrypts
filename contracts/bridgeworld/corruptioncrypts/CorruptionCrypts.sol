//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";
import "../legionmetadatastore/ILegionMetadataStore.sol";
import "./CorruptionCryptsState.sol";


import "hardhat/console.sol";
// import "./CorruptionCryptsBoardGeneration.sol";
import "./MapTiles.sol";


enum PlayerType {
    NONE,
    NATURE,
    USER
}


// Represents the information contained in a single cell of the game grid.
struct Cell {
    // The MapTile played on this cell. May be 0 if PlayerType == NONE
    uint256 tileId;

    // Treasure Fragments Ids on this cell. Loot.
    uint256[] treasureIds;

    // LegionIds on this cell.
    uint256[] legionIds;
}

// Coordinates
struct Coords {
    // The x coordinate of the location
    uint8 x;
    // The y coordinate of the location.
    uint8 y;

    MoveType moveType;
}

enum MoveType {
    PlaceTile,
    MoveLegion
}

// struct GameOutcome {
//     uint8 numberOfFlippedCards;
//     uint8 numberOfCorruptedCardsLeft;
//     bool playerWon;
// }

// struct PlayersBoard {
//     // 5x rows of Cell[8] columns = 5x8 Grid
//     Cell[8][5] board;
// }


contract CorruptionCrypts is Initializable, MapTiles, CorruptionCryptsState {


    mapping(address => Cell[8][5]) playersBoards;
    DoubleEndedQueue.Bytes32Deque tileQueue;

    uint256[] defaultNoTreasures;
    uint256[] defaultNoLegions;


    Cell defaultEmptyCell = Cell({
        tileId: 0, // None
        treasureIds: defaultNoTreasures,
        legionIds: defaultNoLegions
    });
    // 5x rows of Cell[8] columns = 5x8 Grid
    Cell[8][5] emptyBoard;

    event ViewCell(uint256, uint256[], uint256[]);
    event ViewMapTile(uint, bool, bool, bool, bool);
    event SetupBoardEvent(address);

    function initialize() external initializer {
        // CorruptionCryptsBoardGeneration.__CorruptionCryptsBoardGeneration_init();
        MapTiles.init();

        // initialize emptyBoard with emptyCells
        for (uint row = 0; row < 5; row++) {
            for (uint col = 0; col < 8; col++) {
                emptyBoard[row][col] = defaultEmptyCell;
            }
        }
    }

    function setupBoardForPlayer() public {

        Cell[8][5] storage board = emptyBoard;

        /// randomly pick 3 cells and put treasures on it
        uint256[] memory randomTreasures1 = new uint256[](1);
        uint256[] memory randomTreasures2 = new uint256[](2);
        uint256[] memory randomTreasures3 = new uint256[](1);
        randomTreasures1[0] = 11;
        randomTreasures2[0] = 22;
        randomTreasures2[1] = 23;
        randomTreasures3[0] = 38;

        board[0][0].treasureIds = randomTreasures1;
        board[0][1].treasureIds = randomTreasures2;
        board[0][2].treasureIds = randomTreasures3;

        playersBoards[msg.sender] = board;
        emit SetupBoardEvent(msg.sender);
        console.log("setup board for: ", msg.sender);
    }

    modifier legalTilePlacement(uint row, uint col) {
        require(row < 5 && row >= 0);
        require(col < 8 && col >= 0);
        Cell memory bcell = playersBoards[msg.sender][row][col];
        require(bcell.tileId == 0, "This cell already has a tile on it");
        _;
    }

    function moveLegionAcrossBoard(Coords[] calldata moves, uint legionId) public {

        LegionMetadata memory _legionMetadata = appStorage.legionMetadataStore.metadataForLegion(legionId);
    }

    function _checkCellsAreAdjacent(
        Coords calldata start,
        Coords calldata dest
    ) public pure {

        uint rowDistance;
        uint colDistance;

        rowDistance = (start.x > dest.x) ? start.x - dest.x : dest.x - start.x;
        require(rowDistance <= 1, "not in same/adjacent rows");

        colDistance = (start.y > dest.y) ? start.y - dest.y : dest.y - start.y;
        require(colDistance <= 1, "not in same/adjacent cols");

        require(rowDistance + colDistance < 2, "not adjacent");
    }

    function _checkCellsHaveMapTiles(
        Coords calldata start,
        Coords calldata dest
    ) public view {
        Cell memory cellA = playersBoards[msg.sender][start.y][start.x];
        Cell memory cellB = playersBoards[msg.sender][dest.y][dest.x];
        require(cellA.tileId != 0, "Current cell has no MapTile");
        require(cellB.tileId != 0, "Destination cell has no MapTile");
    }

    function checkCellsAreConnected(
        Coords calldata start,
        Coords calldata dest
    ) public returns (bool) {

        _checkCellsAreAdjacent(start, dest);
        _checkCellsHaveMapTiles(start, dest);

        Cell memory cellA = playersBoards[msg.sender][start.y][start.x];
        Cell memory cellB = playersBoards[msg.sender][dest.y][dest.x];

        MapTile memory mtileA = getMapTile(cellA.tileId);
        MapTile memory mtileB = getMapTile(cellB.tileId);

        console.log("mtileA tileId:", cellA.tileId);
        console.log("mtileB tileId:", cellB.tileId);

        if (start.x > dest.x) {
            // moving down, check mapTileA.south == mapTileB.north
            if (mtileA.south == mtileB.north) {
                console.log("mtileA.south == mtileB.north");
                return true;
            }
        }
        if (start.x < dest.x) {
            // moving up, check mapTileA.north == mapTileB.south
            if (mtileA.north == mtileB.south) {
                console.log("mtileA.north == mtileB.south");
                return true;
            }
        }
        if (start.y > dest.y) {
            // moving west, check mapTileA.west == mapTileB.east
            if (mtileA.west == mtileB.east) {
                console.log("mtileA.west == mtileB.east");
                return true;
            }
        }
        if (start.x < dest.y) {
            // moving east, check mapTileA.east == mapTileB.west
            if (mtileA.east == mtileB.west) {
                console.log("mtileA.east == mtileB.west");
                return true;
            }
        } else {
            return false;
        }
    }


    function placeMapTileOnBoard(
        uint tileId,
        uint x_col,
        uint y_row
    ) legalTilePlacement(y_row, x_col) public {
        // get MapTile
        MapTile memory mtile = getMapTile(tileId);
        // then place MapTile on the player's board
        playersBoards[msg.sender][y_row][x_col].tileId = mtile.tileId;
    }

    function getMapTile(uint mapTileId) public returns (MapTile memory) {
        // tileId is 1-indexed, subtract 1 to get 0-indexed maptile
        require(mapTileId > 0, "MapTileId cannot be less than 1");
        MapTile memory mtile = MapTiles.mapTiles[mapTileId-1];
        emit ViewMapTile(mtile.tileId, mtile.north, mtile.east, mtile.south, mtile.west);
        return mtile;
    }

    function getBoardCell(uint row, uint col) public returns (Cell memory) {
        Cell memory bcell = playersBoards[msg.sender][row][col];
        emit ViewCell(bcell.tileId, bcell.treasureIds, bcell.legionIds);
        return bcell;
    }

}