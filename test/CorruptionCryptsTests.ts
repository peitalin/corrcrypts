import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers, deployments } from "hardhat";
import { BigNumber } from "ethers";
import { randomBytes, Result } from "ethers/lib/utils";

import { Utilities } from "./utilities";
import LegionRarity = Utilities.LegionRarity;
import LegionClass = Utilities.LegionClass;
import LegionGeneration = Utilities.LegionGeneration;

import { MockTreasure } from "../typechain-types/MockTreasure";
import { LegionMetadataStore, Randomizer, CorruptionCrypts } from "../typechain-types";
import { MapTiles, CoordsStruct } from "../typechain-types/CorruptionCrypts";


let CorruptionCrypts: CorruptionCrypts;
let decoder = new ethers.utils.AbiCoder();


describe("CorruptionCrypts", function () {

    let _ownerWallet: SignerWithAddress;

    let CorruptionCryptsContractFactory;
    let CorruptionCrypts: CorruptionCrypts;


    beforeEach(async () => {
        Utilities.changeAutomineEnabled(true);

        let signers = await ethers.getSigners();
        _ownerWallet = signers[0];

        await deployments.fixture(['deployments'], { fallbackToGlobal: false });

        CorruptionCryptsContractFactory = await ethers.getContractFactory("CorruptionCrypts");
        CorruptionCrypts = await CorruptionCryptsContractFactory.deploy();

        await CorruptionCrypts.initialize();
        await CorruptionCrypts.setupBoardForPlayer();

        // CorruptionCrypts = await Utilities.getDeployedContract<CorruptionCrypts>('CorruptionCrypts', _ownerWallet);
    });

    it("5 Board Cells are connected", async function () {

        // place tiles
        await CorruptionCrypts.placeMapTileOnBoard(1, 0, 0);
        await CorruptionCrypts.placeMapTileOnBoard(6, 1, 0);
        await CorruptionCrypts.placeMapTileOnBoard(29, 1, 1);
        await CorruptionCrypts.placeMapTileOnBoard(27, 1, 2);
        await CorruptionCrypts.placeMapTileOnBoard(4, 2, 2);

        let coord1: CoordsStruct = { "x": 0, "y": 0, "moveType": 0 }
        let coord2: CoordsStruct = { "x": 1, "y": 0, "moveType": 0 }
        let coord3: CoordsStruct = { "x": 1, "y": 1, "moveType": 0 }
        let coord4: CoordsStruct = { "x": 1, "y": 2, "moveType": 0 }
        let coord5: CoordsStruct = { "x": 2, "y": 2, "moveType": 0 }

        await CorruptionCrypts.checkCellsAreConnected(
            coord1,
            coord2
        )
        await CorruptionCrypts.checkCellsAreConnected(
            coord2,
            coord3
        )
        await CorruptionCrypts.checkCellsAreConnected(
            coord3,
            coord4
        )
        await CorruptionCrypts.checkCellsAreConnected(
            coord4,
            coord5
        )
        printBoard(CorruptionCrypts);
    });



    // it("Step 1", async function () {
    //     await CorruptionCrypts.placeMapTileOnBoard(1, 0, 0);
    //     printBoard(CorruptionCrypts);
    // });

    // it("Step 2", async function () {
    //     await CorruptionCrypts.placeMapTileOnBoard(1, 0, 0);
    //     await CorruptionCrypts.placeMapTileOnBoard(6, 1, 0);
    //     printBoard(CorruptionCrypts);
    // });

    // it("Step 3", async function () {
    //     await CorruptionCrypts.placeMapTileOnBoard(1, 0, 0);
    //     await CorruptionCrypts.placeMapTileOnBoard(6, 1, 0);
    //     await CorruptionCrypts.placeMapTileOnBoard(29, 1, 1);
    //     printBoard(CorruptionCrypts);
    // });


    it("Print Board Cell", async function () {
        getBoardCellTS(0, 0, true);
        getBoardCellTS(0, 1, true);
        getBoardCellTS(0, 2, true);
    });



    // function createEmptyCell(
    //     hasAffinity: boolean = false,
    //     affinity: Utilities.TreasureCategory = Utilities.TreasureCategory.ALCHEMY,
    //     isCorrupted: boolean = false)
    // : CellStruct
    // {
    //     return {
    //         "playerType": Utilities.PlayerType.NONE,
    //         "treasureId": 0,
    //         "hasAffinity": hasAffinity,
    //         "affinity": affinity,
    //         "isFlipped": false,
    //         "isCorrupted": isCorrupted
    //     };
    // }

    // function createNatureCell(
    //     treasureId: number,
    //     hasAffinity: boolean = false,
    //     affinity: Utilities.TreasureCategory = Utilities.TreasureCategory.ALCHEMY,
    //     isCorrupted: boolean = false)
    // : CellStruct
    // {
    //     return {
    //         "playerType": Utilities.PlayerType.NATURE,
    //         "treasureId": treasureId,
    //         "hasAffinity": hasAffinity,
    //         "affinity": affinity,
    //         "isFlipped": false,
    //         "isCorrupted": isCorrupted
    //     };
    // }



    const enumToPlayer = (playerType: number): string => {
        switch (playerType) {
            case 0: {
                return "NONE"
            }
            case 1: {
                return "NATURE"
            }
            case 2: {
                return "USER"
            }
            default: {
                return "NONE"
            }
        }
    }


    const getBoardCellTS = async (row: number, col: number, print=false): Promise<BoardCellTS> => {

        const convertBoardCellData = async (d: Result): Promise<BoardCellTS> => {
            const tileId = d[0].toNumber();
            return {
                tileId: tileId,
                mapTile: await getMapTile(tileId),
                treasureIds: d[1].map((n: BigNumber) => n.toNumber()),
                legionIds: d[2].map((n: BigNumber) => n.toNumber()),
            }
        }

        const boardCell = await convertBoardCellData(
            decodeTx({
                eventName: "ViewCell",
                eventType: ['uint256', 'uint256[]', 'uint256[]'],
                tx: await (await CorruptionCrypts.getBoardCell(row, col))?.wait()
            })
        )

        if (print) {
            console.log("BoardCell", boardCell)
        }
        return boardCell
    }

    const getMapTile = async (tileId: number): Promise<MapTileTS> => {

        const MAX_TILES = 32 // only 32 mapTiles
        const convertMapTileData = (d: Result): MapTileTS => ({
            tileId: d[0].toNumber(),
            north: d[1],
            east: d[2],
            south: d[3],
            west: d[4],
        })

        if (0 < tileId && tileId <= MAX_TILES) {
            return convertMapTileData(
                decodeTx({
                    eventName: "ViewMapTile",
                    eventType: ['uint256', 'bool', 'bool', 'bool', 'bool'],
                    tx: await (await CorruptionCrypts.getMapTile(tileId))?.wait()
                })
            )
        } else {
            return {
                tileId: 0,
                north: false,
                east: false,
                south: false,
                west: false,
            }
        }
    }

    interface BoardCellTS {
        tileId: number,
        mapTile: MapTileTS,
        treasureIds: number[],
        playerType: String,
    }
    interface MapTileTS {
        tileId: number,
        north: boolean,
        east: boolean,
        south: boolean,
        west: boolean,
    }

    interface DecodeTxInput {
        eventName: string,
        eventType: any[],
        tx: any
    }

    const decodeTx = ({ eventName, eventType, tx }: DecodeTxInput) => {
        const logData = tx?.events?.filter((x: any) => x.event === eventName) ?? []
        return decoder.decode(
            eventType,
            ethers.utils.hexDataSlice(logData?.[0]?.data, 0)
        )
    }

    const fmtRow = async (row: number) => {
        const _c0 = await getBoardCellTS(row, 0);
        const _c1 = await getBoardCellTS(row, 1);
        const _c2 = await getBoardCellTS(row, 2);
        const _c3 = await getBoardCellTS(row, 3);
        const _c4 = await getBoardCellTS(row, 4);
        const _c5 = await getBoardCellTS(row, 5);
        const _c6 = await getBoardCellTS(row, 6);
        const _c7 = await getBoardCellTS(row, 7);

        const asciiCell = (_c0: BoardCellTS) => ({
            id: _c0.tileId < 10 ? ` ${_c0.tileId} ` : ` ${_c0.tileId}`,
            n: _c0.mapTile.north ? "↑" : " ",
            e: _c0.mapTile.east ? "→" : " ",
            s: _c0.mapTile.south ? "↓" : " ",
            w: _c0.mapTile.west ? "←" : " ",
        })

        const c0 = asciiCell(_c0)
        const c1 = asciiCell(_c1)
        const c2 = asciiCell(_c2)
        const c3 = asciiCell(_c3)
        const c4 = asciiCell(_c4)
        const c5 = asciiCell(_c5)
        const c6 = asciiCell(_c6)
        const c7 = asciiCell(_c7)

        const rrow =
        `|    ${c0.n}    |    ${c1.n}    |    ${c2.n}    |    ${c3.n}    |    ${c4.n}    |    ${c5.n}    |    ${c6.n}    |    ${c7.n}    |
|${c0.w}  ${c0.id}  ${c0.e}|${c1.w}  ${c1.id}  ${c1.e}|${c2.w}  ${c2.id}  ${c2.e}|${c3.w}  ${c3.id}  ${c3.e}|${c4.w}  ${c4.id}  ${c4.e}|${c5.w}  ${c5.id}  ${c5.e}|${c6.w}  ${c6.id}  ${c6.e}|${c7.w}  ${c7.id}  ${c7.e}|
|    ${c0.s}    |    ${c1.s}    |    ${c2.s}    |    ${c3.s}    |    ${c4.s}    |    ${c5.s}    |    ${c5.s}    |    ${c6.s}    |`
        return rrow
    }

    const printBoard = async (cCrypt: CorruptionCrypts) => {

        const row0 = fmtRow(0)
        const row1 = fmtRow(1)
        const row2 = fmtRow(2)
        const row3 = fmtRow(3)
        const row4 = fmtRow(4)

        const grid = await Promise.all([
            row0,
            row1,
            row2,
            row3,
            row4,
        ])

        grid.forEach(row => {
            console.log(row)
        })
        console.log("\n")
    }
});
