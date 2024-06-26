import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers, deployments } from "hardhat";
import { BigNumber, Contract } from "ethers";
import { randomBytes, Result } from "ethers/lib/utils";

import * as Utilities from "./utils";
import { MockTreasure } from "../typechain-types/MockTreasure";
import { LegionMetadataStore, Randomizer, CorruptionCrypts } from "../typechain-types";
import { MapTiles, CoordsStruct } from "../typechain-types/CorruptionCrypts";


let CorruptionCrypts: CorruptionCrypts;
let decoder = new ethers.utils.AbiCoder();

export async function getDeployedContract<T extends Contract>(name: string, deployer: SignerWithAddress) : Promise<T> {
    const deployment = await deployments.get(name);
    return new Contract(
        deployment.address,
        deployment.abi,
        deployer
    ) as T;
}

enum LegionSquadId {
    None,
    Squad1,
    Squad2,
    Squad3,
    Squad4
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
    PlaceMapTile,
    MoveLegion,
    None
}


const DEBUG_PRINT = true;


describe("CorruptionCrypts", function () {

    let _ownerWallet: SignerWithAddress;
    let player1Wallet: SignerWithAddress;

    let CorruptionCryptsContractFactory;
    let CCrypts: CorruptionCrypts;
    let randomizerContractFactory;
    let randomizer: Randomizer;


    beforeEach(async () => {

        let signers = await ethers.getSigners();
        _ownerWallet = signers[0];
        player1Wallet = signers[1];

        await deployments.fixture(['deployments'], { fallbackToGlobal: false });

        // CCrypts = await getDeployedContract('CorruptionCrypts', _ownerWallet);

        CorruptionCryptsContractFactory = await ethers.getContractFactory("CorruptionCrypts");
        CCrypts = await CorruptionCryptsContractFactory.deploy();
        await CCrypts.deployed();

        // manually call initialize to set msg.sender as owner
        await CCrypts.initialize();

        await CCrypts.addAdmin(_ownerWallet.address)
        console.log("\nOwner of CCrypts:\t", await CCrypts.owner())
        console.log("Signer of CCrypts:\t", await CCrypts.signer.getAddress())
        console.log("_ownerWallet:\t\t", _ownerWallet.address)
        console.log(`isAdmin of CCrypts:\t${await CCrypts.isAdmin(_ownerWallet.address)}\n`)

        await CCrypts.setupBoardForPlayer();
    });


    // it("As Epochs advance over time, player draws the correct #MapTiles", async function () {

    //     const convertPendingMapTiles = (d: Result): MapTileTS => ({
    //         tileId: d[0],
    //         moves: d[1],
    //         north: d[2],
    //         east: d[3],
    //         south: d[4],
    //         west: d[5],
    //     })

    //     // random int between 0 ~ 100
    //     let requestId0 = Math.round(Math.random() * 100);
    //     let requestId1 = Math.round(Math.random() * 100);
    //     let requestId2 = Math.round(Math.random() * 100);
    //     let requestId3 = Math.round(Math.random() * 100);

    //     //////////////////////////////////////////////////////
    //     // Epoch 0: 1 card to draw on Epoch 0
    //     //////////////////////////////////////////////////////

    //     await (await CCrypts.connect(_ownerWallet)._testSetCurrentEpoch(0))?.wait()

    //     let drawnPendingMaptiles0 = (decodeTx({
    //         eventName: "ViewPendingMoves",
    //         eventType: ['(uint,uint,uint,bool,bool,bool,bool)[]'],
    //         tx: await (await CCrypts.drawMapTilesForPreviousEpochs(requestId0))?.wait(),
    //     })?.[0] ?? []).map((d: any) => convertPendingMapTiles(d))


    //     expect(drawnPendingMaptiles0.length).to.equal(1);
    //     drawnPendingMaptiles0.map((d: any) => {
    //         expect(d).to.have.all.keys('tileId', 'moves', 'north', 'east', 'south', 'west');
    //     })

    //     //////////////////////////////////////////////////////
    //     // Epoch 0: Trying to draw more cards reverts
    //     //////////////////////////////////////////////////////

    //     await expect(CCrypts.drawMapTilesForPreviousEpochs(requestId1))
    //         .to.be.revertedWith('Player already moved this epoch');

    //     //////////////////////////////////////////////////////
    //     // Epoch 2: fast foward 9hrs, and advance epoch twice to Epoch 2
    //     // draw 2 new MapTiles
    //     //////////////////////////////////////////////////////

    //     Utilities.increaseTime(60 * 60 * 9)
    //     await (await CCrypts.advanceManyEpochsToPresent())?.wait()

    //     let drawnPendingMaptiles2 = (decodeTx({
    //         eventName: "ViewPendingMoves",
    //         eventType: ['(uint,uint,uint,bool,bool,bool,bool)[]'],
    //         tx: await (await CCrypts.drawMapTilesForPreviousEpochs(requestId2))?.wait(),
    //     })?.[0] ?? []).map((d: any) => convertPendingMapTiles(d))

    //     expect(drawnPendingMaptiles2.length).to.equal(2);
    //     drawnPendingMaptiles2.map((d: any) => {
    //         expect(d).to.have.all.keys('epoch', 'tileId', 'moves', 'north', 'east', 'south', 'west');
    //     })
    //     debugPrint('drawnPendingMaptiles2: ', drawnPendingMaptiles2)

    //     //////////////////////////////////////////////////////
    //     // Epoch 7: fast foward 33hrs,
    //     // epoch advanced 8x but only 5 MapTiles can be drawn
    //     //////////////////////////////////////////////////////

    //     Utilities.increaseTime(60 * 60 * 33)
    //     let tx1 = await (await CCrypts.advanceManyEpochsToPresent())?.wait()

    //     let drawnPendingMaptiles3 = (decodeTx({
    //         eventName: "ViewPendingMoves",
    //         eventType: ['(uint,uint,uint,bool,bool,bool,bool)[]'],
    //         tx: await (await CCrypts.drawMapTilesForPreviousEpochs(requestId3))?.wait(),
    //     })?.[0] ?? []).map((d: any) => convertPendingMapTiles(d))

    //     let advancedEpoch = decodeTx({
    //         eventName: "AdvancedEpoch",
    //         eventType: ['(uint8, uint8)'],
    //         tx: tx1,
    //     }).map((d: any) => {
    //         return {
    //             currentEpoch: d[0],
    //             numTimesToAdvance: d[1]
    //         }
    //     })?.[0]

    //     debugPrint('drawnPendingMaptiles3', drawnPendingMaptiles3)
    //     debugPrint('advancedEpoch', advancedEpoch)

    //     // Even though we advanced 8 epochs (33 / 4 hrs)
    //     // only 6 maximum MapTiles can be built up and drawn
    //     expect(advancedEpoch.numTimesToAdvance).to.equal(8);
    //     expect(drawnPendingMaptiles3.length).to.equal(6);
    //     drawnPendingMaptiles3.map((d: any) => {
    //         expect(d).to.have.all.keys('epoch', 'tileId', 'moves', 'north', 'east', 'south', 'west');
    //     })

    // });




    it("Drawing 6 MapTiles at a time", async function () {


        // random int between 0 ~ 100
        let requestId0 = Math.round(Math.random() * 100);
        let requestId1 = Math.round(Math.random() * 100);
        let requestId2 = Math.round(Math.random() * 100);
        let requestId3 = Math.round(Math.random() * 100);


        //////////////////////////////////////////////////////
        // Epoch 2: fast foward 9hrs, and advance epoch twice to Epoch 2
        // draw 3 MapTiles
        //////////////////////////////////////////////////////

        Utilities.increaseTime(60 * 60 * 9)
        await (await CCrypts.advanceManyEpochsToPresent())?.wait()

        let drawnPendingMaptiles2 = (decodeTx({
            eventName: "ViewPendingMoves",
            eventType: ['(uint,uint,uint,bool,bool,bool,bool)[]'],
            tx: await (await CCrypts.drawMapTilesForPreviousEpochs(requestId2))?.wait(),
        })?.[0] ?? []).map((d: any) => convertPendingMapTiles(d))

        expect(drawnPendingMaptiles2.length).to.equal(3);
        drawnPendingMaptiles2.map((d: any) => {
            expect(d).to.have.all.keys('epoch', 'tileId', 'moves', 'north', 'east', 'south', 'west');
        })
        // debugPrint('drawnPendingMaptiles2: ', drawnPendingMaptiles2)

        //////////////////////////////////////////////////////
        // Epoch 7: fast foward 33hrs,
        // epoch advanced 8x but only 6 MapTiles can be drawn
        //////////////////////////////////////////////////////

        await (await CCrypts.useCurrentHandOfMapTiles([
            {
                coords: [
                    { x: 0, y: 0 }
                ],
                moveType: MoveType.PlaceMapTile,
                epoch: 2,
                tileId: 10,
                legionSquadId: LegionSquadId.None,
            },
            {
                coords: [
                    { x: 1, y: 0 }
                ],
                moveType: MoveType.PlaceMapTile,
                epoch: 1,
                tileId: 11,
                legionSquadId: LegionSquadId.None,
            },
            {
                coords: [
                    { x: 1, y: 2 }
                ],
                moveType: MoveType.PlaceMapTile,
                epoch: 0,
                tileId: 12,
                legionSquadId: LegionSquadId.None,
            },
        ])).wait();

        Utilities.increaseTime(60 * 60 * 33)
        let tx1 = await (await CCrypts.advanceManyEpochsToPresent())?.wait()

        let drawnPendingMaptiles3 = (decodeTx({
            eventName: "ViewPendingMoves",
            eventType: ['(uint,uint,uint,bool,bool,bool,bool)[]'],
            tx: await (await CCrypts.drawMapTilesForPreviousEpochs(requestId3))?.wait(),
        })?.[0] ?? []).map((d: any) => convertPendingMapTiles(d))

        let advancedEpoch = decodeTx({
            eventName: "AdvancedEpoch",
            eventType: ['(uint8, uint8)'],
            tx: tx1,
        }).map((d: any) => {
            return {
                currentEpoch: d[0],
                numTimesToAdvance: d[1]
            }
        })?.[0]

        debugPrint('drawnPendingMaptiles3', drawnPendingMaptiles3)
        debugPrint('advancedEpoch', advancedEpoch)

        // Even though we advanced 8 epochs (33 / 4 hrs)
        // only 6 maximum MapTiles can be built up and drawn
        expect(advancedEpoch.numTimesToAdvance).to.equal(8);
        expect(drawnPendingMaptiles3.length).to.equal(6);
        drawnPendingMaptiles3.map((d: any) => {
            expect(d).to.have.all.keys('epoch', 'tileId', 'moves', 'north', 'east', 'south', 'west');
        })

    });








    it("Places Maptiles and moves Legions, validating moves", async function () {

        let coord1: CoordsStruct = { "x": 0, "y": 0 }
        let coord2: CoordsStruct = { "x": 1, "y": 0 }
        let coord3: CoordsStruct = { "x": 1, "y": 1 }
        let coord4: CoordsStruct = { "x": 1, "y": 2 }
        let coord5: CoordsStruct = { "x": 2, "y": 2 }
        let coord6: CoordsStruct = { "x": 2, "y": 3 }
        let coord7: CoordsStruct = { "x": 2, "y": 4 }
        let coord8: CoordsStruct = { "x": 3, "y": 4 }

        // 1. Print Empty Board
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 2. place tiles
        await CCrypts.placeMapTileOnBoard(1, coord1);
        await CCrypts.placeMapTileOnBoard(6, coord2);
        await CCrypts.placeMapTileOnBoard(29, coord3);
        await CCrypts.placeMapTileOnBoard(27, coord4);

        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        const legionSquad1 = {
            squadNumber: LegionSquadId.Squad1,
            legionIds: [1111, 1502, 345]
        }
        const legionSquad2 = {
            squadNumber: LegionSquadId.Squad2,
            legionIds: [22, 33, 44, 55, 66]
        }

        // make it easy to trigger a new Round for testing purposes
        await CCrypts.setMaxLegionsOnTemplesBeforeReset(2);


        // 3a. Move squad 1 across the board
        await CCrypts.assignLegionSquadsAndPlaceOnMap(
            coord1,
            legionSquad1.squadNumber,
            legionSquad1.legionIds,
            Temple.ForbiddenCrafts,
        );
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        await CCrypts.moveLegionAcrossBoard([ coord1, coord2 ], legionSquad1.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        await CCrypts.moveLegionAcrossBoard([ coord2, coord3 ], legionSquad1.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        await CCrypts.moveLegionAcrossBoard([ coord3, coord4 ], legionSquad1.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));


        // 4a. Move squad 2 across the board
        await CCrypts.assignLegionSquadsAndPlaceOnMap(
            coord1,
            legionSquad2.squadNumber,
            legionSquad2.legionIds,
            Temple.Harvester1,
        );
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));
        await CCrypts.moveLegionAcrossBoard([ coord1, coord2 ], legionSquad2.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 4b. Move squad 2 across the board
        await CCrypts.moveLegionAcrossBoard([ coord2, coord3 ], legionSquad2.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 5. place 5th tile after legions have crossed, or it will cause the 1st tile to be removed
        // before the legions have crossed, making it impossible for a legion to move
        await CCrypts.placeMapTileOnBoard(4, coord5);
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 6. move legionSquad1
        await CCrypts.moveLegionAcrossBoard([ coord4, coord5 ], legionSquad1.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 7. place next map tile
        await CCrypts.placeMapTileOnBoard(18, coord6);
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 8. move legionSquad1
        await CCrypts.moveLegionAcrossBoard([ coord5, coord6 ], legionSquad1.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 9. place next map tile
        await CCrypts.placeMapTileOnBoard(27, coord7);
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 10. move legionSquad1 to temple destination
        await CCrypts.moveLegionAcrossBoard([ coord6, coord7 ], legionSquad1.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 11. move legionSquad2 to temple destination
        await CCrypts.moveLegionAcrossBoard([ coord3, coord4 ], legionSquad2.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 12. move legionSquad2 to temple destination
        await CCrypts.moveLegionAcrossBoard([ coord4, coord5 ], legionSquad2.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 13. move legionSquad2 to temple destination
        // this triggers a new Round and Temples reshuffle
        await CCrypts.moveLegionAcrossBoard([ coord5, coord6 ], legionSquad2.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 14. move legionSquad2 to temple destination
        // cannot stack 2 legionSquads by the same player
        await expect(
            CCrypts.moveLegionAcrossBoard([ coord6, coord7 ], legionSquad2.squadNumber)
        ).to.be.revertedWith("Cannot stack two legion squads on the same MapTile");
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 15. place next map tile
        await CCrypts.placeMapTileOnBoard(20, coord8);
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        // 16. move legionSquad1 from temple destination
        await CCrypts.moveLegionAcrossBoard([ coord7, coord8 ], legionSquad1.squadNumber)
        printBoard(CCrypts);
        await new Promise(resolve => setTimeout(resolve, 500));

        /// Need to move to squads, to handle over lap
        await new Promise(resolve => setTimeout(resolve, 1000));
        debugPrint("Simulation Ended")
    });


    // it("Print Board Cell", async function () {
    //     await CCrypts.placeMapTileOnBoard(1, 0, 0);
    //     await CCrypts.placeMapTileOnBoard(6, 1, 0);
    //     await CCrypts.placeMapTileOnBoard(29, 1, 1);
    //     await CCrypts.placeMapTileOnBoard(27, 1, 2);
    //     await CCrypts.placeMapTileOnBoard(4, 2, 2);
    //     const legionIds = [1];
    //     await CCrypts.moveLegionAcrossBoard([
    //         { "x": 0, "y": 0 },
    //         { "x": 1, "y": 0 },
    //         { "x": 1, "y": 1 },
    //         { "x": 1, "y": 2 },
    //         { "x": 2, "y": 2 },
    //     ], legionIds)
    // });


    //////////////////////////////
    //////////////////////////////
    // Helper Functions
    //////////////////////////////
    //////////////////////////////


    const convertPendingMapTiles = (d: Result): MapTileTS => ({
        epoch: d[0].toNumber(),
        tileId: d[1].toNumber(),
        moves: d[2].toNumber(),
        north: d[3],
        east: d[4],
        south: d[5],
        west: d[6],
    })

    const getBoardCellTS = async (row: number, col: number, print=false): Promise<BoardCellTS> => {

        const getTempleName = (i: number) => {
            switch (i) {
                case 0: {
                    return undefined
                }
                case 1: {
                    return "H1"
                }
                case 2: {
                    return "H2"
                }
                case 3: {
                    return "H3"
                }
                case 4: {
                    return "H4"
                }
                case 5: {
                    return "H5"
                }
                case 6: {
                    return "H6"
                }
                case 7: {
                    return "H7"
                }
                case 8: {
                    return "H8"
                }
                case 9: {
                    return "H9"
                }
                case 10: {
                    return "FC"
                }
                default: {
                    return undefined
                }
            }
        }

        const convertBoardCellData = async (d: Result): Promise<BoardCellTS> => {
            const tileId = d[0].toNumber();
            const data: BoardCellTS = {
                tileId: tileId,
                mapTile: await getMapTile(tileId),
                treasureIds: d[1].map((n: BigNumber) => n.toNumber()),
                legionSquadId: d[2].toNumber(),
                legionIds: d[3].map((n: BigNumber) => n.toNumber()),
                temple: getTempleName(d[4].toNumber())
            }
            // console.log("dataaaaaa", data)
            return data
        }

        const boardCell = await convertBoardCellData(
            decodeTx({
                eventName: "ViewCell",
                eventType: ['uint256', 'uint256[]', 'uint', 'uint[]', 'uint'],
                tx: await (await CCrypts.getBoardCell({
                    x: col,
                    y: row
                }))?.wait()
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
            moves: d[1].toNumber(),
            north: d[2],
            east: d[3],
            south: d[4],
            west: d[5],
        })

        if (0 < tileId && tileId <= MAX_TILES) {
            return convertMapTileData(
                decodeTx({
                    eventName: "ViewMapTile",
                    eventType: ['uint256', 'uint256', 'bool', 'bool', 'bool', 'bool'],
                    tx: await (await CCrypts.getMapTile(tileId))?.wait()
                })
            )
        } else {
            return {
                tileId: 0,
                moves: 0,
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
        legionSquadId: number,
        legionIds: number[],
        temple?: string
    }
    interface MapTileTS {
        tileId: number,
        moves: number,
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
            // id: (_c0.tileId >= 0 && _c0.tileId < 10)
            //     ? ` ${_c0.tileId} `
            //     : ` ${_c0.tileId}`,
            id: (_c0.tileId >= 0 && _c0.tileId < 10)
                ? ` ${_c0.legionIds.length} `
                : ` ${_c0.legionIds.length} `,
            t: _c0.treasureIds.length == 0
                ? "  "
                : _c0.treasureIds.length == 1
                    ? " *"
                    : "**",
            n: _c0.mapTile.north ? "↑" : " ",
            e: _c0.mapTile.east ? "→" : " ",
            s: _c0.mapTile.south ? "↓" : " ",
            w: _c0.mapTile.west ? "←" : " ",
            z: !!_c0.temple
                ? `${_c0.temple}`
                : "  "
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
        `|    ${c0.n}  ${c0.t}|    ${c1.n}  ${c1.t}|    ${c2.n}  ${c2.t}|    ${c3.n}  ${c3.t}|    ${c4.n}  ${c4.t}|    ${c5.n}  ${c5.t}|    ${c6.n}  ${c6.t}|    ${c7.n}  ${c7.t}|
|${c0.w}  ${c0.id}  ${c0.e}|${c1.w}  ${c1.id}  ${c1.e}|${c2.w}  ${c2.id}  ${c2.e}|${c3.w}  ${c3.id}  ${c3.e}|${c4.w}  ${c4.id}  ${c4.e}|${c5.w}  ${c5.id}  ${c5.e}|${c6.w}  ${c6.id}  ${c6.e}|${c7.w}  ${c7.id}  ${c7.e}|
|    ${c0.s}  ${c0.z}|    ${c1.s}  ${c1.z}|    ${c2.s}  ${c2.z}|    ${c3.s}  ${c3.z}|    ${c4.s}  ${c4.z}|    ${c5.s}  ${c5.z}|    ${c6.s}  ${c6.z}|    ${c7.s}  ${c7.z}|`
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

        console.log("\n")
        console.log("_________________________________________________________________________________")
        grid.forEach(row => {
            console.log(row)
        })
        console.log("‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾")
        console.log("• * and ** = 1 or 2 treasure fragments on the tile")
        console.log("• Numbers in the center represent #legions on the tile")
        console.log("• Arrows represent MapTile paths on the north, east, south, and west")
        console.log("\n")
    }
});


const debugPrint = (msg?: any, ...optional: any) => {
    DEBUG_PRINT ? console.log(msg, ...optional) : undefined
}