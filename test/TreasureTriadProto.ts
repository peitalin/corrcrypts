import "@nomiclabs/hardhat-waffle"
import { ethers } from "hardhat";
import { expect } from "chai"
import { Signer} from "ethers";
import {getBlockTime, mineBlock, getCurrentTime, setNextBlockTime} from './utils';

import { TreasureTriadProto, GridCellStructOutput } from "../typechain-types/TreasureTriadProto";
import { TreasureTriadCardStats } from "../typechain-types/TreasureTriadCardStats";
import { ShittyRandom } from "../typechain-types/ShittyRandom";
import { LegionDecks } from "../typechain-types/LegionDecks";

// const DISABLE_LOGS = true;
const DISABLE_LOGS = false;




describe("TreasureTriadPrototype", function () {

    // declare some variables, and assign them in the `before` and `beforeEach` callbacks.
    let TreasureTriadProto
    let TreasureTriadCardStats
    let ShittyRandom
    let LegionDecks

    let tTriad: TreasureTriadProto
    let ttCardStats: TreasureTriadCardStats
    let sRandom: ShittyRandom
    let legionDecks: LegionDecks
    let decoder = new ethers.utils.AbiCoder();

    let gridSize = 3
    let owner
    let addrs

    const tryStakeAndPrint = async (
        row: number,
        col: number,
        treasure: string,
        player: Player,
        disablePrint: boolean = false
    ) => {
        try {
            if (player === Player.nature) {
                await tTriad.stakeTreasureCardAsNature(row, col, treasure);
            } else {
                await tTriad.stakeTreasureCard(row, col, treasure, player);
            }
        } catch(e) {
            console.log(e)
        } finally {
            if (!DISABLE_LOGS) {
                if (!disablePrint) {
                    await printGrid(tTriad);
                }
            }
        }
    }

    // `beforeEach` runs before each test, re-deploying the contract every time.
    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        TreasureTriadProto = await ethers.getContractFactory("TreasureTriadProto");
        TreasureTriadCardStats = await ethers.getContractFactory("TreasureTriadCardStats");
        ShittyRandom = await ethers.getContractFactory("ShittyRandom");
        LegionDecks = await ethers.getContractFactory("LegionDecks");

        [owner, ...addrs] = await ethers.getSigners();

        tTriad = await TreasureTriadProto.deploy();
        await tTriad.initialize(gridSize);
        ttCardStats = await TreasureTriadCardStats.deploy();
        sRandom = await ShittyRandom.deploy();
        legionDecks = await LegionDecks.deploy();

    });


    // it("Stakes and looks up cards (ox, cow, donkey) with correct stats", async function () {

    //     let player_legion = Player.assassin
    //     try {
    //         await tTriad.stakeTreasureCard(0, 0, "ox", player_legion);
    //     } catch(e) {
    //         console.log(e)
    //     }
    //     try {
    //         await tTriad.stakeTreasureCard(0, 1, "cow", player_legion);
    //     } catch(e) {
    //         console.log(e)
    //     }
    //     try {
    //         await tTriad.stakeTreasureCard(0, 2, "donkey", player_legion);
    //     } catch(e) {
    //         console.log(e)
    //     }
    //     const oxCard = await tTriad.getGridCell(0, 0);
    //     const cowCard = await tTriad.getGridCell(0, 1);
    //     const donkeyCard = await tTriad.getGridCell(0, 2);

    //     const ox = await ttCardStats.getBaseCardStatsByName(oxCard.card_name);
    //     const cow = await ttCardStats.getBaseCardStatsByName(cowCard.card_name);
    //     const donkey = await ttCardStats.getBaseCardStatsByName(donkeyCard.card_name);

    //     expect(ox.n.toNumber()).to.equal(5)
    //     expect(cow.n.toNumber()).to.equal(4)
    //     expect(donkey.n.toNumber()).to.equal(5)
    // })

    // it("Staking a card on a cell with prexisting card reverts", async function () {
    //     let player_legion = Player.assassin
    //     await tTriad.stakeTreasureCard(0, 0, "ox", Player.nature);
    //     // try add another card on top of existing card
    //     let tx2 = tTriad.stakeTreasureCard(0, 0, "grin", player_legion);
    //     await expect(tx2).to.be.revertedWith("Cell Occupied");
    // })

    // it("Staking cards in cells outside of row indexes 0-2 reverts", async function () {
    //     // https://github.com/NomicFoundation/hardhat/issues/2234
    //     // Issues with revertWith messages matching on things they shouldn't
    //     let player_legion = Player.assassin
    //     expect(tTriad.stakeTreasureCard(-1, 0, "ox", player_legion))
    //         .to.be.revertedWith("row must be >= 0");

    //     expect(tTriad.stakeTreasureCard(3, 0, "grin", player_legion))
    //         .to.be.revertedWith("row must be < gridRows");
    // })

    // it("Staking cards in cells outside of column indexes 0-2 reverts", async function () {
    //     // https://github.com/NomicFoundation/hardhat/issues/2234
    //     // Issues with revertWith messages matching on things they shouldn't
    //     let player_legion = Player.assassin
    //     expect(tTriad.stakeTreasureCard(0, -1, "grin", player_legion))
    //         .to.be.revertedWith("col must be >= 0");

    //     expect(tTriad.stakeTreasureCard(0, 3, "grin", player_legion))
    //         .to.be.revertedWith("col must be < gridCols");
    // })

    // it("Emits event on stakeTreasureCard", async () => {
    //     let tx1 = tTriad.stakeTreasureCard(0, 0, "ox", Player.nature);
    //     expect(tx1)
    //         .to.emit(tx1, "CardStaked")
    //         .withArgs(0, 0, "ox", Player.nature)
    // })

    // it("Nature draws 3 cards without replacement", async function () {

    //     let naturesTx = await tTriad.naturePlacesInitialCards(3);
    //     let receipt2 = await naturesTx?.wait();
    //     let logs2 = receipt2?.events?.filter(x => x.event === "NaturesInitialCells") ?? []

    //     let naturesCells = decoder.decode(
    //         ['uint8[2][]'],
    //         ethers.utils.hexDataSlice(logs2?.[0]?.data, 0)
    //     )

    //     let naturesCards = (await Promise.all(naturesCells?.[0].map(async (cell: number[]) => {
    //         let n1 = await tTriad.getGridCell(cell[0], cell[1]);
    //         return n1
    //     }))).filter((card: GridCellStructOutput) => !!card.card_name)

    //     await printGrid(tTriad)

    //     expect(naturesCards.length).to.equal(3)
    // })


    // it("Nature draws and places 2 random affinity effects", async function () {

    //     // 1. Nature (contract) randomly chooses 2 cells to place 2 random affinities
    //     // affinities (alchemy, corruption, etc) give a +1 boost if the right treasures
    //     // are placed on it, by the right legions

    //     let n = 2
    //     let affTx = await tTriad.naturePlacesInitialAffinities(n);
    //     let receipt2 = await affTx?.wait();
    //     let logs2 = receipt2?.events?.filter(x => x.event === "NaturesInitialAffinityCells") ?? []

    //     let naturesCells = decoder.decode(
    //         ['uint8[2][]'],
    //         ethers.utils.hexDataSlice(logs2?.[0]?.data, 0)
    //     )

    //     let naturesAffinities = (await Promise.all(naturesCells?.[0].map(async (cell: number[]) => {
    //         let n1 = await tTriad.getGridCell(cell[0], cell[1]);
    //         return n1
    //     }))).filter((cell: GridCellStructOutput) => !!cell.cell_affinity)

    //     expect(naturesAffinities.length).to.equal(n)
    // })


    // it("Place <+1 leather> card on a <leather>-affinity cell with a <+1 leather>affinity legion for +2 stat boost", async function () {

    //     await tTriad.setCellWithAffinity(0, 1, Affinity.leather_working)
    //     await tTriad.setCellWithAffinity(0, 2, Affinity.leather_working)

    //     // donkey affinity: "leather working";
    //     // reverse order so +2 doesn't flip +1 boosted card
    //     // NOTE: if we were to switch order, the +2 card would flip +1 card,
    //     // and Nature would flip to Assassin

    //     // +2 affinityBoost for Leather Working
    //     await tryStakeAndPrint(0, 2, "donkey", Player.assassin, true);
    //     // +1 affinityBoost for Leather Working
    //     await tryStakeAndPrint(0, 1, "donkey", Player.nature, true);
    //     // +0 affinityBoost for Leather Working
    //     await tryStakeAndPrint(0, 0, "donkey", Player.nature, true);

    //     const donkeyTx1 = await tTriad.getCardStatsAtCell(0, 0);
    //     const donkeyTx2 = await tTriad.getCardStatsAtCell(0, 1);
    //     const donkeyTx3 = await tTriad.getCardStatsAtCell(0, 2);

    //     let receipt1 = await donkeyTx1?.wait();
    //     let receipt2 = await donkeyTx2?.wait();
    //     let receipt3 = await donkeyTx3?.wait();

    //     let logs1 = receipt1?.events?.filter(x => x.event === "CardStatsAtCell") ?? []
    //     let logs2 = receipt2?.events?.filter(x => x.event === "CardStatsAtCell") ?? []
    //     let logs3 = receipt3?.events?.filter(x => x.event === "CardStatsAtCell") ?? []

    //     // struct CardStats {
    //     //     uint n;
    //     //     uint e;
    //     //     uint s;
    //     //     uint w;
    //     //     Affinity affinity;
    //     //     uint tokenId;
    //     //     string card_name;
    //     // }
    //     let d1 = decoder.decode(
    //         ['uint', 'uint', 'uint', 'uint', 'uint', 'uint', 'string'],
    //         ethers.utils.hexDataSlice(logs1?.[0]?.data, 0)
    //     )
    //     let d2 = decoder.decode(
    //         ['uint', 'uint', 'uint', 'uint', 'uint', 'uint', 'string'],
    //         ethers.utils.hexDataSlice(logs2?.[0]?.data, 0)
    //     )
    //     let d3 = decoder.decode(
    //         ['uint', 'uint', 'uint', 'uint', 'uint', 'uint', 'string'],
    //         ethers.utils.hexDataSlice(logs3?.[0]?.data, 0)
    //     )

    //     let donkey1 = {
    //         n: d1[0],
    //         e: d1[1],
    //         s: d1[2],
    //         w: d1[3],
    //         affinity: affinityToText(Number(d1[4])),
    //         tokenId: d1[5],
    //         cardName: d1[6]
    //     }
    //     let donkey2 = {
    //         n: d2[0],
    //         e: d2[1],
    //         s: d2[2],
    //         w: d2[3],
    //         affinity: affinityToText(Number(d2[4])),
    //         tokenId: d2[5],
    //         cardName: d2[6]
    //     }
    //     let donkey3 = {
    //         n: d3[0],
    //         e: d3[1],
    //         s: d3[2],
    //         w: d3[3],
    //         affinity: affinityToText(Number(d3[4])),
    //         tokenId: d3[5],
    //         cardName: d3[6]
    //     }
    //     // if (!DISABLE_LOGS) {
    //     //     console.log("CardStats 1", donkey1)
    //     //     console.log("CardStats 2", donkey2)
    //     //     console.log("CardStats 3", donkey3)
    //     // }

    //     // +2 boost to stats
    //     expect(donkey3.n).to.equal(7);
    //     // +1 boost to stats
    //     expect(donkey2.n).to.equal(6);
    //     // +0 boost to stats
    //     expect(donkey1.n).to.equal(5);
    // })

    // it("stakeMultipleCardsAndFinishGame places and converts 3 cards", async function () {

    //     await tryStakeAndPrint(0, 0, "donkey", Player.nature, true);
    //     await tryStakeAndPrint(0, 1, "donkey", Player.nature, true);
    //     await tryStakeAndPrint(0, 2, "donkey", Player.nature, true);

    //     await tTriad.setCellWithAffinity(0, 0, Affinity.corruption)
    //     await tTriad.setCellWithAffinity(0, 1, Affinity.corruption)
    //     await tTriad.setCellWithAffinity(0, 2, Affinity.corruption)

    //     let tx = await tTriad.stakeMultipleCardsAndFinishGame(
    //         [[1,0], [1,1], [1,2]],
    //         ["grin", "grin", "grin"],
    //         Player.fighter,
    //     );
    //     await printGrid(tTriad);

    //     let receipt2 = await tx?.wait();
    //     let logs2 = receipt2?.events?.filter(x => x.event === "GameEndingStats") ?? []

    //     let gameEndingStats = decoder.decode(
    //         ['int', 'int'],
    //         ethers.utils.hexDataSlice(logs2?.[0]?.data, 0)
    //     )
    //     console.log("convertedCards: ", gameEndingStats[0])
    //     console.log("corruptedCellCount: ", gameEndingStats[1])
    //     // flipped 3 cards
    //     expect(gameEndingStats[0]).to.equal(3);
    //     // 3 corruption cells converted, 0 remaining
    //     expect(gameEndingStats[1]).to.equal(0);
    // })

    // it("Python Test 1: Stakes cards and flips cards", async function () {

    //     console.log("\nBefore: ")
    //     await printGrid(tTriad);

    //     let c00: GridCellStructOutput
    //     let c01: GridCellStructOutput
    //     let c02: GridCellStructOutput
    //     let c10: GridCellStructOutput
    //     let c11: GridCellStructOutput
    //     let c12: GridCellStructOutput
    //     let c20: GridCellStructOutput
    //     let c21: GridCellStructOutput
    //     let c22: GridCellStructOutput

    //     let player_legion = Player.assassin
    //     let	convertedCards

    //     console.log("Staking dragon tail in: ", [0,1])
    //     await tryStakeAndPrint(0, 1, "dragon tail", Player.nature);
    //     c01 = await tTriad.getGridCell(0, 1)
    //     expect(c01.card_name).to.equal("dragon tail")
    //     expect(c01.player).to.equal(Player.nature) // nature: 0
    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(0);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards)
    //         console.log("\n")
    //     }


    //     console.log("Staking honeycomb in: ", [0,0])
    //     await tryStakeAndPrint(0, 0, "honeycomb", player_legion);
    //     c01 = await tTriad.getGridCell(0, 1)
    //     c00 = await tTriad.getGridCell(0, 0)
    //     expect(c01.card_name).to.equal("dragon tail")
    //     expect(c01.player).to.equal(player_legion)
    //     expect(c00.card_name).to.equal("honeycomb")
    //     expect(c00.player).to.equal(player_legion)
    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(1);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards )
    //         console.log("\n")
    //     }


    //     console.log("Staking grin in: ", [1,0])
    //     await tryStakeAndPrint(1, 0, "grin", Player.nature);
    //     c00 = await tTriad.getGridCell(0, 0)
    //     c10 = await tTriad.getGridCell(1, 0)
    //     expect(c00.card_name).to.equal("honeycomb")
    //     expect(c00.player).to.equal(player_legion)
    //     expect(c10.card_name).to.equal("grin")
    //     expect(c10.player).to.equal(Player.nature)
    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(1);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards )
    //         console.log("\n")
    //     }

    //     console.log("Staking ox in: ", [1,2])
    //     await tryStakeAndPrint(1, 2, "ox", player_legion);
    //     console.log("Staking bottomless elixer in: ", [0,2])
    //     await tryStakeAndPrint(0, 2, "bottomless elixer", Player.nature);
    //     c01 = await tTriad.getGridCell(0, 1)
    //     c02 = await tTriad.getGridCell(0, 2)
    //     c12 = await tTriad.getGridCell(1, 2)
    //     expect(c01.card_name).to.equal("dragon tail")
    //     expect(c01.player).to.equal(Player.nature)
    //     expect(c02.card_name).to.equal("bottomless elixer")
    //     expect(c02.player).to.equal(Player.nature)
    //     expect(c12.card_name).to.equal("ox")
    //     expect(c12.player).to.equal(Player.nature)
    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(-1);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards )
    //         console.log("\n")
    //     }

    //     console.log("Staking donkey in: ", [1,1])
    //     await tryStakeAndPrint(1, 1, "donkey", player_legion);
    //     c01 = await tTriad.getGridCell(0, 1)
    //     c10 = await tTriad.getGridCell(1, 0)
    //     c11 = await tTriad.getGridCell(1, 1)
    //     c12 = await tTriad.getGridCell(1, 2)
    //     expect(c01.card_name).to.equal("dragon tail")
    //     expect(c01.player).to.equal(player_legion)
    //     expect(c10.card_name).to.equal("grin")
    //     expect(c10.player).to.equal(player_legion)
    //     expect(c11.card_name).to.equal("donkey")
    //     expect(c11.player).to.equal(player_legion)
    //     expect(c12.card_name).to.equal("ox")
    //     expect(c12.player).to.equal(player_legion)
    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(2);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards )
    //         console.log("\n")
    //     }

    //     console.log("Staking small bird in: ", [2,2])
    //     await tryStakeAndPrint(2, 2, "small bird", Player.nature);
    //     c12 = await tTriad.getGridCell(1, 2)
    //     c22 = await tTriad.getGridCell(2, 2)
    //     expect(c12.card_name).to.equal("ox")
    //     expect(c12.player).to.equal(Player.nature)
    //     expect(c22.card_name).to.equal("small bird")
    //     expect(c22.player).to.equal(Player.nature)
    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(1);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards )
    //         console.log("\n")
    //     }

    //     console.log("Staking immovable stone in: ", [2,1])
    //     await tryStakeAndPrint(2, 1, "immovable stone", player_legion);
    //     c21 = await tTriad.getGridCell(2, 1)
    //     c22 = await tTriad.getGridCell(2, 2)
    //     expect(c21.card_name).to.equal("immovable stone")
    //     expect(c21.player).to.equal(player_legion)
    //     expect(c22.card_name).to.equal("small bird")
    //     expect(c22.player).to.equal(player_legion)
    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(2);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards )
    //         console.log("\n")
    //     }

    //     console.log("Staking red feather in: ", [2,0])
    //     await tryStakeAndPrint(2, 0, "red feather", Player.nature);
    //     c20 = await tTriad.getGridCell(2, 0)
    //     c21 = await tTriad.getGridCell(2, 1)
    //     expect(c20.card_name).to.equal("red feather")
    //     expect(c20.player).to.equal(Player.nature)
    //     expect(c21.card_name).to.equal("immovable stone")
    //     expect(c21.player).to.equal(Player.nature)

    //     convertedCards = await tTriad.getConvertedCards();
    //     expect(convertedCards).to.equal(1);
    //     if (!DISABLE_LOGS) {
    //         console.log("convertedCards: ", convertedCards )
    //         console.log("\n")
    //     }
    // })

    // it("Python Test 2: +2 Affinity boost Donkey converts all 4 cards on n, e, s, w directions", async function () {

    //     await tTriad.setCellWithAffinity(1, 1, Affinity.leather_working)
    //     // donkey affinity: "leather working";

    //     await tryStakeAndPrint(0, 1, "bait for monsters", Player.nature, true);
    //     await tryStakeAndPrint(1, 0, "mollusk shell", Player.nature, true);
    //     await tryStakeAndPrint(1, 2, "common bead", Player.nature, true);
    //     await tryStakeAndPrint(2, 1, "jar of fairies", Player.nature, true);

    //     if (!DISABLE_LOGS) {
    //         console.log("\nBefore")
    //     }
    //     await printGrid(tTriad)

    //     await tryStakeAndPrint(1, 1, "donkey", Player.assassin, true);

    //     if (!DISABLE_LOGS) {
    //         console.log("\nAfter")
    //     }
    //     await printGrid(tTriad)

    //     let receipt0 = await (await tTriad.getCardStatsAtCell(1, 1))?.wait();
    //     let logs0 = receipt0?.events?.filter(x => x.event === "CardStatsAtCell") ?? []

    //     let d0 = decoder.decode(
    //         ['uint', 'uint', 'uint', 'uint', 'uint', 'uint', 'string'],
    //         ethers.utils.hexDataSlice(logs0?.[0]?.data, 0)
    //     )
    //     let donkey0 = {
    //         n: d0[0],
    //         e: d0[1],
    //         s: d0[2],
    //         w: d0[3],
    //         affinity: affinityToText(Number(d0[4])),
    //         tokenId: d0[5],
    //         cardName: d0[6]
    //     }
    //     // +2 boost to Donkey's normal 5 stats
    //     expect(donkey0.n).to.equal(7);

    //     let receipt1 = await tTriad.getGridCell(0, 1);
    //     let receipt2 = await tTriad.getGridCell(1, 0);
    //     let receipt3 = await tTriad.getGridCell(1, 2);
    //     let receipt4 = await tTriad.getGridCell(2, 1);
    //     expect(receipt1.player).to.equal(Player.assassin);
    //     expect(receipt2.player).to.equal(Player.assassin);
    //     expect(receipt3.player).to.equal(Player.assassin);
    //     expect(receipt4.player).to.equal(Player.assassin);

    //     let receipt5 = await tTriad.getConvertedCards();
    //     expect(receipt5).to.equal(4);
    // })


    // it("Python Test 3: Counts 0 corrupted cells after converting 3 corrupted cells", async function () {

    //     console.log("\nSetting 3 cells with corruption...")
    //     await tTriad.setCellWithAffinity(0, 0, Affinity.corruption)
    //     await tTriad.setCellWithAffinity(0, 1, Affinity.corruption)
    //     await tTriad.setCellWithAffinity(1, 0, Affinity.corruption)

    //     console.log("Staking 2 cards on corrupted cells...")
    //     await tryStakeAndPrint(0, 0, "bait for monsters", Player.nature, true);
    //     await tryStakeAndPrint(1, 0, "bait for monsters", Player.nature, true);

    //     if (!DISABLE_LOGS) {
    //         console.log("Before")
    //     }
    //     await printGrid(tTriad)

    //     console.log("Player stakes 2 donkeys adjacent to corrupted cells...")
    //     await tryStakeAndPrint(1, 1, "donkey", Player.seige, true);
    //     await tryStakeAndPrint(0, 1, "donkey", Player.range, true);

    //     if (!DISABLE_LOGS) {
    //         console.log("After")
    //     }
    //     await printGrid(tTriad)

    //     let corruptionCount = await tTriad.getCorruptedCellCount();
    //     if (!DISABLE_LOGS) {
    //         console.log("CorruptionCellCount", corruptionCount);
    //     }

    //     expect(corruptionCount).to.equal(0);
    //     // if corruption > 0, put legion in stasis for 1 day
    //     // for every point of corruption
    // })




})



function fmt(treasure: string, player: number, affinity: number) {

    let _t =  treasure.trim() != "" ? treasure.trim() : "----------------"
    let _player = playerToText(player)
    let _affinity = affinityToText(affinity)
    let label = _t

    if (_player) {
        label += ` (${_player})`
    }
    if (_affinity) {
        label += ` <${_affinity}>`
    }
    return label
}

enum Player {
    none = 0,
    nature = 1,
    all_class = 2,
    range = 3,
    fighter = 4,
    spellcaster = 5,
    seige = 6,
    assassin = 7,
    riverman = 8,
    numeraire = 9,
    common = 10
}
const playerToText = (p: number) => {
    switch (p) {
        case Player.none: { return "" }
        case Player.nature: { return "Nature" }
        case Player.all_class: { return "all class" }
        case Player.range: { return "range" }
        case Player.fighter: { return "fighter" }
        case Player.spellcaster: { return "spellcaster" }
        case Player.seige: { return "seige" }
        case Player.assassin: { return "assassin" }
        case Player.riverman: { return "riverman" }
        case Player.numeraire: { return "numeraire" }
        case Player.common: { return "common" }
        default: { return "" }
    }
}

enum Affinity {
    none = 0,
    alchemy = 1,
    arcana = 2,
    brewing = 3,
    enchanting = 4,
    leather_working = 5,
    smithing = 6,
    corruption = 7
}

const affinityToText = (a: number) => {
    switch (a) {
        case Affinity.none: { return "" }
        case Affinity.alchemy: { return "alchemy" }
        case Affinity.arcana: { return "arcana" }
        case Affinity.brewing: { return "brewing" }
        case Affinity.enchanting: { return "enchanting" }
        case Affinity.leather_working: { return "leather_working" }
        case Affinity.smithing: { return "smithing" }
        case Affinity.corruption: { return "corruption" }
        default: { return "" }
    }
}

const printGrid = async (tTriad: TreasureTriad) => {
    const _c00 = await tTriad.getGridCell(0, 0);
    const _c01 = await tTriad.getGridCell(0, 1);
    const _c02 = await tTriad.getGridCell(0, 2);
    const _c10 = await tTriad.getGridCell(1, 0);
    const _c11 = await tTriad.getGridCell(1, 1);
    const _c12 = await tTriad.getGridCell(1, 2);
    const _c20 = await tTriad.getGridCell(2, 0);
    const _c21 = await tTriad.getGridCell(2, 1);
    const _c22 = await tTriad.getGridCell(2, 2);

    const row0 = [
        fmt(_c00.card_name, _c00.player, _c00.cell_affinity),
        fmt(_c01.card_name, _c01.player, _c01.cell_affinity),
        fmt(_c02.card_name, _c02.player, _c02.cell_affinity)
    ].join(",\t")
    const row1 = [
        fmt(_c10.card_name, _c10.player, _c10.cell_affinity),
        fmt(_c11.card_name, _c11.player, _c11.cell_affinity),
        fmt(_c12.card_name, _c12.player, _c12.cell_affinity)
    ].join(",\t")
    const row2 = [
        fmt(_c20.card_name, _c20.player, _c20.cell_affinity),
        fmt(_c21.card_name, _c21.player, _c21.cell_affinity),
        fmt(_c22.card_name, _c22.player, _c22.cell_affinity)
    ].join(",\t")

    if (!DISABLE_LOGS) {
        console.log("[", row0, "]")
        console.log("[", row1, "]")
        console.log("[", row2, "]")
        console.log("\n")
    }
}