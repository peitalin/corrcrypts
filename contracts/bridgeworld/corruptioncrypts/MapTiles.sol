//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract MapTiles is Initializable {

    struct MapTile {
        uint tileId;
        bool north;
        bool east;
        bool south;
        bool west;
        // directions of roads on each MapTile
    }

    mapping(uint256 => MapTile) public mapTiles;
    // MapTile[36] mapTiles;

    function init() internal {
        // CorruptionCryptsBoardGeneration.__CorruptionCryptsBoardGeneration_init();

        // See https://boardgamegeek.com/image/3128699/karuba
        // for the tile road directions
        mapTiles[0] = MapTile({
            tileId: 1,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[1] = MapTile({
            tileId: 2,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[2] = MapTile({
            tileId: 3,
            north: false,
            east: true,
            south: true,
            west: false
        });
        mapTiles[3] = MapTile({
            tileId: 4,
            north: false,
            east: false,
            south: true,
            west: true
        });
        mapTiles[4] = MapTile({
            tileId: 5,
            north: false,
            east: true,
            south: true,
            west: true
        });
        mapTiles[5] = MapTile({
            tileId: 6,
            north: false,
            east: true,
            south: true,
            west: true
        });

        mapTiles[6] = MapTile({
            tileId: 7,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[7] = MapTile({
            tileId: 8,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[8] = MapTile({
            tileId: 9,
            north: true,
            east: true,
            south: false,
            west: false
        });
        mapTiles[9] = MapTile({
            tileId: 10,
            north: true,
            east: false,
            south: false,
            west: true
        });
        mapTiles[10] = MapTile({
            tileId: 11,
            north: true,
            east: true,
            south: false,
            west: true
        });
        mapTiles[11] = MapTile({
            tileId: 12,
            north: true,
            east: true,
            south: false,
            west: true
        });

        mapTiles[12] = MapTile({
            tileId: 13,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[13] = MapTile({
            tileId: 14,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[14] = MapTile({
            tileId: 15,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[15] = MapTile({
            tileId: 16,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[16] = MapTile({
            tileId: 17,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[17] = MapTile({
            tileId: 18,
            north: true,
            east: false,
            south: true,
            west: false
        });

        mapTiles[18] = MapTile({
            tileId: 19,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[19] = MapTile({
            tileId: 20,
            north: false,
            east: true,
            south: false,
            west: true
        });
        mapTiles[20] = MapTile({
            tileId: 21,
            north: false,
            east: true,
            south: true,
            west: false
        });
        mapTiles[21] = MapTile({
            tileId: 22,
            north: false,
            east: false,
            south: true,
            west: true
        });
        mapTiles[22] = MapTile({
            tileId: 23,
            north: true,
            east: true,
            south: true,
            west: false
        });
        mapTiles[23] = MapTile({
            tileId: 24,
            north: true,
            east: false,
            south: true,
            west: true
        });

        mapTiles[24] = MapTile({
            tileId: 25,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[25] = MapTile({
            tileId: 26,
            north: true,
            east: true,
            south: true,
            west: true
        });
        mapTiles[26] = MapTile({
            tileId: 27,
            north: true,
            east: true,
            south: false,
            west: false
        });
        mapTiles[27] = MapTile({
            tileId: 28,
            north: true,
            east: false,
            south: false,
            west: true
        });
        mapTiles[28] = MapTile({
            tileId: 29,
            north: true,
            east: true,
            south: true,
            west: false
        });
        mapTiles[29] = MapTile({
            tileId: 30,
            north: true,
            east: false,
            south: true,
            west: true
        });

        mapTiles[30] = MapTile({
            tileId: 31,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[31] = MapTile({
            tileId: 32,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[32] = MapTile({
            tileId: 33,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[33] = MapTile({
            tileId: 34,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[34] = MapTile({
            tileId: 35,
            north: true,
            east: false,
            south: true,
            west: false
        });
        mapTiles[35] = MapTile({
            tileId: 36,
            north: true,
            east: false,
            south: true,
            west: false
        });
    }


}