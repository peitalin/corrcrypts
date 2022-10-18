//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

import "../legionmetadatastore/ILegionMetadataStore.sol";
import "./CorruptionCryptsState.sol";


import "hardhat/console.sol";
import "./CorruptionCryptsBoardGeneration.sol";
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

    // LegionSquadId on this cell. Only 1 squad can occupy a cell at a time per board
    LegionSquadId legionSquadId;
}

enum LegionSquadId {
    None,
    Squad1,
    Squad2,
    Squad3,
    Squad4
}

struct LegionSquad {
    // This legionSquad may only use the target Temple
    Temple targetTemple;
    // legionIds in this legionSquad
    uint[] legionIds;
}

// Coordinates
struct Coords {
    // The x coordinate of the location
    uint8 x;
    // The y coordinate of the location.
    uint8 y;
}

enum Temple {
    None,
    ForbiddenCrafts,
    Harvester1,
    Harvester2,
    Harvester3,
    Harvester4,
    Harvester5,
    Harvester6,
    Harvester7,
    Harvester8,
    Harvester9
}

enum MoveType {
    PlaceTile,
    MoveLegion,
    None
}



contract CorruptionCrypts is Initializable, MapTiles, CorruptionCryptsState, CorruptionCryptsBoardGeneration {

    //////////////////////////////////
    /////// Player Board Variables /////////
    //////////////////////////////////

    mapping(address => Cell[5][8]) playersBoards;
    // Every player has their own board, as they place MapTiles and legions uniquely
    // 8x columns of Cell[5] rows = 5x8 Grid
    Cell[5][8] emptyBoard; // For initializing new player boards
    mapping(address => mapping(LegionSquadId => LegionSquad)) playerLegionSquads;
    // playerAddress => LegionSquadId(0-3) => LegionSquad
    /// We will batch legions into squads and have them move around the map

    // keep a queue of MapTiles on the board and ability to look up their cell
    // these maptiles are on (so that we can remove it)
    DoubleEndedQueue.Bytes32Deque tileQueue;
    // https://docs.openzeppelin.com/contracts/4.x/api/utils#DoubleEndedQueue
    mapping(uint => Coords) mapTileIdToCell;
    uint MAX_TILES_ON_BOARD = 5;


    //////////////////////////////////
    /////// Epoch Variables /////////
    //////////////////////////////////

    // every epoch lasts 1 hrs, players can draw maptiles once every hour
    uint currentEpoch = 1;
    uint epochStartTime;
    uint epochEndTime;
    bool epochEnded;
    mapping(address => uint) epochPlayerLastDrewMapTile;
    // keep track of whether player drew a maptile this round
    uint cryptRound = 1;
    // increment this every time
    // MAX_LEGIONS_ON_TEMPLES_RESET_COUNT is reached
    // Then for each player, the next time they drawRandomMapTile, the temple
    // locations change for every player


    //////////////////////////////////
    /////// Temple Variables /////////
    //////////////////////////////////

    // Once MAX legions at temples reached, reset temple locations
    // Reset the epoch, a new round begins
    uint numLegionsReachedTemples;
    uint MAX_LEGIONS_ON_TEMPLES_RESET_COUNT = 2;
    // or if this limit isn't reached in a timely matter, every X days
    // anyone can call the reshuffleTemples() function
    Temple[5][8] globalTempleLocations;

    mapping(Temple => uint) totalLegionsOnTemple;
    // need to track #legions at each temple to calculate corruption diversion

    mapping(Temple => mapping(address => uint[])) playerLegionsOnTemple;
    // need actual player's legionsIds on temples to see which legions can craft


    //////////////////////////////////
    /////// Events /////////
    //////////////////////////////////

    event ViewCell(uint256, uint256[], LegionSquadId, uint[], Temple);
    event ViewMapTile(uint, uint, bool, bool, bool, bool);
    event SetupBoardEvent(address);

    event PlayerLegionsReachedTemple(uint[], Temple);
    event TotalLegionsReachedTemple(uint256);
    event MaxLegionsReachedTempleBeforeReset(uint256);
    event TempleCoordsReshuffled(Coords[], Temple[]);
    // list of new coords for temples, order matches order in Temple enum


    function initialize() external initializer {
        // CorruptionCryptsBoardGeneration.__CorruptionCryptsBoardGeneration_init();
        MapTiles.init();
    }

    function drawRandomMapTile(uint _requestId)
        external
        tryAdvanceEpoch
        returns (MapTile memory)
    {
        require(
            epochPlayerLastDrewMapTile[msg.sender] != currentEpoch,
            "Player has already moved this epoch"
        );
        uint mapTileId = CorruptionCryptsBoardGeneration.drawRandomMapTileId(_requestId);
        MapTile memory drawnMapTile = getMapTile(mapTileId);
        epochPlayerLastDrewMapTile[msg.sender] = currentEpoch;
        return drawnMapTile;
    }

    modifier tryAdvanceEpoch() {
        // try advance epoch if it's after epochEndTime
        advanceEpoch();
        _;
    }

    function advanceEpoch() public {
        // anyone can try advance the epoch
        if (block.timestamp >= epochEndTime) {
            epochStartTime = epochEndTime;
            epochEndTime = epochEndTime + 1 hours;
            ++currentEpoch;
        }
        // if epochs are left un-updated that's fine (no players), game pauses
        // until epochs begin advancing again
    }

    function setupBoardForPlayer() public {

        Cell[5][8] storage board = emptyBoard;

        /// randomly pick 3 cells and put treasures on it
        uint256[] memory randomTreasures1 = new uint256[](1);
        uint256[] memory randomTreasures2 = new uint256[](2);
        uint256[] memory randomTreasures3 = new uint256[](1);
        randomTreasures1[0] = 11;
        randomTreasures2[0] = 22;
        randomTreasures2[1] = 23;
        randomTreasures3[0] = 38;
        // board[x][y]
        board[0][0].treasureIds = randomTreasures1;
        board[1][0].treasureIds = randomTreasures2;
        board[2][0].treasureIds = randomTreasures3;

        /// Randomly pick 5 distinct tiles on the board edges and place temples on them
        // board[x][y]
        globalTempleLocations[1][4] = Temple.ForbiddenCrafts;
        globalTempleLocations[2][4] = Temple.Harvester1;
        globalTempleLocations[4][4] = Temple.Harvester2;
        globalTempleLocations[6][4] = Temple.Harvester3;
        globalTempleLocations[7][4] = Temple.Harvester4;

        playersBoards[msg.sender] = board;
        emit SetupBoardEvent(msg.sender);
    }

    function shuffleGlobalTempleLocations() internal {
        /// Randomly pick 5 distinct tiles on the board edges and place temples on them
        // board[x][y]
        for (uint y = 0; y < 5; y++) {
            for (uint x = 0; x < 8; x++) {
                globalTempleLocations[x][y] = Temple.None;
            }
        }

        uint randInt = block.timestamp;
        uint8 NUM_HARVESTERS = 4;
        uint8[2][] memory templeLocations = CorruptionCryptsBoardGeneration._pickRandomUniqueTempleCoordinates(
            NUM_HARVESTERS + 1,
            randInt
        );
        uint numTemples = templeLocations.length;
        require(numTemples == NUM_HARVESTERS + 1, "number of random coords for numTemples mismatched");
        // new temple locations
        uint8[2] memory t0 = templeLocations[0];

        globalTempleLocations[t0[0]][t0[1]] = Temple.ForbiddenCrafts;

        if (NUM_HARVESTERS >= 1) {
            uint8[2] memory t1 = templeLocations[1];
            globalTempleLocations[t1[0]][t1[1]] = Temple.Harvester1;
        }
        if (NUM_HARVESTERS >= 2) {
            uint8[2] memory t2 = templeLocations[2];
            globalTempleLocations[t2[0]][t2[1]] = Temple.Harvester2;
        }
        if (NUM_HARVESTERS >= 3) {
            uint8[2] memory t3 = templeLocations[3];
            globalTempleLocations[t3[0]][t3[1]] = Temple.Harvester3;
        }
        if (NUM_HARVESTERS >= 4) {
            uint8[2] memory t4 = templeLocations[4];
            globalTempleLocations[t4[0]][t4[1]] = Temple.Harvester4;
        }
        if (NUM_HARVESTERS >= 5) {
            uint8[2] memory t5 = templeLocations[5];
            globalTempleLocations[t5[0]][t5[1]] = Temple.Harvester5;
        }
        if (NUM_HARVESTERS >= 6) {
            uint8[2] memory t6 = templeLocations[6];
            globalTempleLocations[t6[0]][t6[1]] = Temple.Harvester6;
        }
        if (NUM_HARVESTERS >= 7) {
            uint8[2] memory t7 = templeLocations[7];
            globalTempleLocations[t7[0]][t7[1]] = Temple.Harvester7;
        }
        if (NUM_HARVESTERS >= 8) {
            uint8[2] memory t8 = templeLocations[8];
            globalTempleLocations[t8[0]][t8[1]] = Temple.Harvester8;
        }
        if (NUM_HARVESTERS >= 9) {
            uint8[2] memory t9 = templeLocations[9];
            globalTempleLocations[t9[0]][t9[1]] = Temple.Harvester9;
        }
    }

    modifier legalTilePlacement(Coords calldata coords) {
        require(coords.y < 5 && coords.y >= 0, "Not inside board rows");
        require(coords.x < 8 && coords.x >= 0, "Not inside board ");
        Cell memory bcell = playersBoards[msg.sender][coords.x][coords.y];
        require(bcell.tileId == 0, "This cell already has a tile on it");
        _;
    }

    function placeMapTileOrMoveLegion(MapTile calldata mapTile) external {
        // validate mapTile has mapTile.moves
        // either place the mapTile on the board
        // or move legion mapTile.moves
        // then delete mapTile from queue
    }

    function assignLegionSquadsAndPlaceOnMap(
        Coords calldata coords,
        LegionSquadId squadNumber,
        uint[] memory legionIds,
        Temple targetTemple
    ) public {
        // 1. Assign legions to a squad, then place them on the map
        _setLegionSquad(legionIds, squadNumber, targetTemple);
        playersBoards[msg.sender][coords.x][coords.y].legionSquadId = squadNumber;
    }

    function moveLegionAcrossBoard(
        Coords[] calldata moves,
        LegionSquadId _legionSquadId
    ) public {

        // LegionMetadata memory legionMetadata = appStorage.legionMetadataStore.metadataForLegion(legionId);
        uint nMoves = moves.length;

        require(nMoves >= 2, "must have at least 2 coords for start and end coordinates");
        require(
            playersBoards[msg.sender][moves[0].x][moves[0].y].legionSquadId == _legionSquadId,
            "player's legionSquad is not located at the starting move/coordinate"
        );

        Coords calldata start;
        Coords calldata dest;
        Coords memory endDest;

        // check each sequential move is legal
        for (uint i = 0; i < (nMoves - 1); i++) {
            start = moves[i];
            dest = moves[i+1];
            _checkCellsAreConnected(start, dest);
            endDest.x = dest.x;
            endDest.y = dest.y;
        }

        require(
            playersBoards[msg.sender][endDest.x][endDest.y].legionSquadId == LegionSquadId.None,
            "Cannot stack two legion squads on top of the same MapTile"
        );

        // if successfully loops through all moves, assign legion to endDestination
        // legionSquads cannot stack, only 1 may occupy a tile at a time
        playersBoards[msg.sender][endDest.x][endDest.y].legionSquadId = _legionSquadId;
        // clear legionIds on the previous tile the legionSquad was on.
        delete playersBoards[msg.sender][moves[0].x][moves[0].y].legionSquadId;

        uint[] memory legionsInSquad = playerLegionSquads[msg.sender][_legionSquadId].legionIds;
        uint numLegionsInSquad = legionsInSquad.length;

        ///////////////////////////////
        /// If legion lands on temple logic

        if (globalTempleLocations[endDest.x][endDest.y] != Temple.None) {

            Temple currentTemple = globalTempleLocations[endDest.x][endDest.y];
            numLegionsReachedTemples += numLegionsInSquad;
            // update legion count to divert corruption to the temple
            totalLegionsOnTemple[currentTemple] += numLegionsInSquad;
            playerLegionsOnTemple[currentTemple][msg.sender] = legionsInSquad;
            // only legions which have reached that temple may forge corruption
            emit PlayerLegionsReachedTemple(legionsInSquad, currentTemple);
            emit TotalLegionsReachedTemple(totalLegionsOnTemple[currentTemple]);
            // assign + emit event together to save gas

            _divertCorruption(totalLegionsOnTemple[currentTemple], currentTemple);

            if (numLegionsReachedTemples >= MAX_LEGIONS_ON_TEMPLES_RESET_COUNT) {
                shuffleGlobalTempleLocations();
            }
        }
        // Need to make it so legion can no longer move after reaching temple
        // until the next round when temple positions reset.
        // or they can move back and forth on the temple tile and increment
        // numLegionsReachedTemples counts

    }

    function _divertCorruption(uint totalLegionsOnTemple, Temple temple) internal {
        // some logic here to recalculate math for dividing the corruption flows
        // between the harvesters
    }

    mapping (uint => bool) hasLegionCraftedInForbiddenCrafts;

    function _enableForbiddenCrafts(uint[] calldata legionIds) internal {
        // enable forbidden crafts for just these legionIds
        // These legions can craft just once
        // check and updated: hasLegionCraftedInForbiddenCrafts
    }

    function _setLegionSquad(
        uint[] memory legionIds,
        LegionSquadId squadNumber,
        Temple targetTemple
    ) internal returns (LegionSquad memory newSquad) {

        require(squadNumber != LegionSquadId.None, "Squad number cannot be None");
        require(legionIds.length <= 20, "exceeded max limit of 20 legions per squad");

        newSquad = LegionSquad({
            legionIds: legionIds,
            targetTemple: targetTemple
        });

        playerLegionSquads[msg.sender][squadNumber] = newSquad;
    }

    function _getLegionsInSquad(
        LegionSquadId squadNumber
    ) public view returns (LegionSquad memory) {
        return playerLegionSquads[msg.sender][squadNumber];
    }

    modifier _checkCellsAreAdjacent(
        Coords calldata start,
        Coords calldata dest
    ) {
        uint rowDistance;
        uint colDistance;

        rowDistance = (start.x > dest.x) ? start.x - dest.x : dest.x - start.x;
        require(rowDistance <= 1, "not in same/adjacent rows");

        colDistance = (start.y > dest.y) ? start.y - dest.y : dest.y - start.y;
        require(colDistance <= 1, "not in same/adjacent cols");

        require(rowDistance + colDistance < 2, "not adjacent");
        _;
    }

    modifier _checkCellsHaveMapTiles(
        Coords calldata start,
        Coords calldata dest
    ) {
        Cell memory cellA = playersBoards[msg.sender][start.x][start.y];
        Cell memory cellB = playersBoards[msg.sender][dest.x][dest.y];
        require(cellA.tileId != 0, "Current cell has no MapTile");
        require(cellB.tileId != 0, "Destination cell has no MapTile");
        _;
    }

    function _checkCellsAreConnected(
        Coords calldata start,
        Coords calldata dest
    ) public
        _checkCellsHaveMapTiles(start, dest)
        _checkCellsAreAdjacent(start, dest)
        returns (bool traversable)
    {
        Cell memory cellA = playersBoards[msg.sender][start.x][start.y];
        Cell memory cellB = playersBoards[msg.sender][dest.x][dest.y];

        MapTile memory mtileA = getMapTile(cellA.tileId);
        MapTile memory mtileB = getMapTile(cellB.tileId);

        traversable = false;

        if (start.x > dest.x) {
            // start right of dest: moving east, check mapTileA.west == mapTileB.east
            if (mtileA.west == mtileB.east) {
                traversable = true;
            }
        }
        if (start.x < dest.x) {
            // start left of dest: moving west, check mapTileA.east == mapTileB.west
            if (mtileA.east == mtileB.west) {
                traversable = true;
            }
        }
        if (start.y > dest.y) {
            // start below dest: moving up, check mapTileA.north == mapTileB.south
            if (mtileA.north == mtileB.south) {
                traversable = true;
            }
        }
        if (start.y < dest.y) {
            // start above dest: moving down, check mapTileA.south == mapTileB.north
            if (mtileA.south == mtileB.north) {
                traversable = true;
            }
        }
        if (!traversable) {
            revert("MapTiles are not connected");
        }
    }


    function placeMapTileOnBoard(
        uint tileId,
        Coords calldata coords
    ) legalTilePlacement(coords) public {

        // if max number of mapTiles already placed
        if (DoubleEndedQueue.length(tileQueue) >= MAX_TILES_ON_BOARD) {
            // First check if oldestTile has legions on it
            uint oldestTileId = uint(DoubleEndedQueue.front(tileQueue));
            Coords memory oCoords = mapTileIdToCell[oldestTileId];
            Cell memory oldestTileCell = playersBoards[msg.sender][oCoords.x][oCoords.y];

            if (oldestTileCell.legionSquadId != LegionSquadId.None) {
                revert("Max MapTiles reached, cannot remove oldest MapTile as there are legions on it");
            }

            bytes32 _oldestTileId = DoubleEndedQueue.popFront(tileQueue);
            // console.log(">4 tiles on board, removing oldest tileId: ", uint(_oldestTileId));
            Coords memory mtileOldest = mapTileIdToCell[uint(_oldestTileId)];
            _removeMapTile(mtileOldest.x, mtileOldest.y, uint(_oldestTileId));
        }

        // get MapTile
        MapTile memory mtile = getMapTile(tileId);
        // then place MapTile on the player's board
        playersBoards[msg.sender][coords.x][coords.y].tileId = mtile.tileId;

        mapTileIdToCell[mtile.tileId] = Coords({ x: coords.x, y: coords.y });

        bytes32 tidNewest = bytes32(mtile.tileId);
        // console.log("tileId_Newest: ", uint(tidNewest));

        DoubleEndedQueue.pushBack(tileQueue, tidNewest);
    }

    function _removeMapTile(uint x_row, uint y_col, uint tileId) internal {
        playersBoards[msg.sender][x_row][y_col].tileId = 0;
        mapTileIdToCell[tileId].x = 0;
        mapTileIdToCell[tileId].y = 0;
    }

    function getMapTile(uint mapTileId) public returns (MapTile memory) {
        // tileId is 1-indexed, subtract 1 to get 0-indexed maptile
        require(mapTileId > 0, "MapTileId cannot be less than 1");
        MapTile memory mtile = MapTiles.mapTiles[mapTileId-1];
        emit ViewMapTile(mtile.tileId, mtile.moves, mtile.north, mtile.east, mtile.south, mtile.west);
        return mtile;
    }

    function getBoardCell(Coords memory coords) public returns (Cell memory) {
        Cell memory bcell = playersBoards[msg.sender][coords.x][coords.y];
        Temple ctemple = globalTempleLocations[coords.x][coords.y];
        LegionSquad memory legionsInSquad = _getLegionsInSquad(bcell.legionSquadId);
        // uint[] memory legionIds;
        uint[] memory legionIds = legionsInSquad.legionIds;
        emit ViewCell(bcell.tileId, bcell.treasureIds, bcell.legionSquadId, legionIds, ctemple);
        return bcell;
    }

}