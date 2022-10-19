//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract MapTiles is Initializable {

    struct MapTile {
        uint8 tileId;
        uint8 moves;
        bool north;
        bool east;
        bool south;
        bool west;
        // directions of roads on each MapTile
    }

    mapping(uint8 => MapTile) public mapTiles;

    function initMapTiles() internal {

        // See https://boardgamegeek.com/image/3128699/karuba
        // for the tile road directions

        mapTiles[0] = MapTile({
            tileId: 1,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[1] = MapTile({
            tileId: 2,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[2] = MapTile({
            tileId: 3,
            moves: 2,
            north: false,
            east: true,
            south: true,
            west: false
        });
        mapTiles[3] = MapTile({
            tileId: 4,
            moves: 2,
            north: false,
            east: false,
            south: true,
            west: true
        });
        mapTiles[4] = MapTile({
            tileId: 5,
            moves: 3,
            north: false,
            east: true,
            south: true,
            west: true
        });
        mapTiles[5] = MapTile({
            tileId: 6,
            moves: 3,
            north: false,
            east: true,
            south: true,
            west: true
        });

        mapTiles[6] = MapTile({
            tileId: 7,
            moves: 4,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[7] = MapTile({
            tileId: 8,
            moves: 4,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[8] = MapTile({
            tileId: 9,
            moves: 2,
            north: true,
            east: true,
            south: false,
            west: false
        });
        mapTiles[9] = MapTile({
            tileId: 10,
            moves: 2,
            north: true,
            east: false,
            south: false,
            west: true
        });
        mapTiles[10] = MapTile({
            tileId: 11,
            moves: 3,
            north: true,
            east: true,
            south: false,
            west: true
        });
        mapTiles[11] = MapTile({
            tileId: 12,
            moves: 3,
            north: true,
            east: true,
            south: false,
            west: true
        });

        mapTiles[12] = MapTile({
            tileId: 13,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[13] = MapTile({
            tileId: 14,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[14] = MapTile({
            tileId: 15,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[15] = MapTile({
            tileId: 16,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[16] = MapTile({
            tileId: 17,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[17] = MapTile({
            tileId: 18,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });

        mapTiles[18] = MapTile({
            tileId: 19,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[19] = MapTile({
            tileId: 20,
            moves: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[20] = MapTile({
            tileId: 21,
            moves: 2,
            north: false,
            east: true,
            south: true,
            west: false
        });
        mapTiles[21] = MapTile({
            tileId: 22,
            moves: 2,
            north: false,
            east: false,
            south: true,
            west: true
        });
        mapTiles[22] = MapTile({
            tileId: 23,
            moves: 3,
            north: true,
            east: true,
            south: true,
            west: false
        });
        mapTiles[23] = MapTile({
            tileId: 24,
            moves: 3,
            north: true,
            east: false,
            south: true,
            west: true
        });

        mapTiles[24] = MapTile({
            tileId: 25,
            moves: 4,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[25] = MapTile({
            tileId: 26,
            moves: 4,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[26] = MapTile({
            tileId: 27,
            moves: 2,
            north: true,
            east: true,
            south: false,
            west: false
        });
        mapTiles[27] = MapTile({
            tileId: 28,
            moves: 2,
            north: true,
            east: false,
            south: false,
            west: true
        });
        mapTiles[28] = MapTile({
            tileId: 29,
            moves: 3,
            north: true,
            east: true,
            south: true,
            west: false
        });
        mapTiles[29] = MapTile({
            tileId: 30,
            moves: 3,
            north: true,
            east: false,
            south: true,
            west: true
        });

        mapTiles[30] = MapTile({
            tileId: 31,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[31] = MapTile({
            tileId: 32,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[32] = MapTile({
            tileId: 33,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[33] = MapTile({
            tileId: 34,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[34] = MapTile({
            tileId: 35,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[35] = MapTile({
            tileId: 36,
            moves: 2,
            north: true,
            east: false,
            south: true,
            west: false
        });
    }


}