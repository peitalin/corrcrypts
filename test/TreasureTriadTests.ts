import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Utilities } from "./utilities";
const { ethers } = require("hardhat");
import LegionRarity = Utilities.LegionRarity;
import LegionClass = Utilities.LegionClass;
import LegionGeneration = Utilities.LegionGeneration;
import { deployments } from "hardhat";
import { LegionMetadataStore, Randomizer, TreasureMetadataStore, TreasureTriad } from "../typechain-types";
import { MockTreasure } from "../typechain-types/MockTreasure";
import { BigNumber } from "ethers";
import { randomBytes } from "ethers/lib/utils";
import { GridCellStruct } from "../typechain-types/TreasureTriad";
import { UserMoveStruct } from "../typechain-types/ITreasureTriad";



describe("TreasureTriad", function () {
    let _ownerWallet: SignerWithAddress;

    let TreasureTriadContractFactory;
    let treasureTriad: TreasureTriad;
    let _treasureTriad: TreasureTriad;

    beforeEach(async () => {
        Utilities.changeAutomineEnabled(true);

        let signers = await ethers.getSigners();
        _ownerWallet = signers[0];

        await deployments.fixture(['deployments'], { fallbackToGlobal: false });

        TreasureTriadContractFactory = await ethers.getContractFactory("TreasureTriad");
        treasureTriad = await TreasureTriadContractFactory.deploy();
        // treasureTriad = await Utilities.getDeployedContract<TreasureTriad>('TreasureTriad', _ownerWallet);
    });

    it("Should not be allowed to pass bad indices", async function () {
        await expect(treasureTriad.playGame(
            <[GridCellStruct, GridCellStruct, GridCellStruct]><unknown>[
                [createEmptyCell(), createEmptyCell(), createEmptyCell()],
                [createEmptyCell(), createEmptyCell(), createEmptyCell()],
                [createEmptyCell(), createEmptyCell(), createEmptyCell()]
            ],
            Utilities.LegionClass.ALL_CLASS,
            [
                createPlayerMove(54, 3, 3)
            ]
            )).to.be.revertedWith("TreasureTriad: Bad move indices");
    });

    it("Should not be allowed to place a card on nature's cells", async function () {
        await expect(treasureTriad.playGame(
            <[GridCellStruct, GridCellStruct, GridCellStruct]><unknown>[
                [createNatureCell(54), createEmptyCell(), createEmptyCell()],
                [createNatureCell(54), createEmptyCell(), createEmptyCell()],
                [createNatureCell(54), createEmptyCell(), createEmptyCell()]
            ],
            Utilities.LegionClass.ALL_CLASS,
            [
                createPlayerMove(54, 0, 1)
            ]
            )).to.be.revertedWith("TreasureTriad: Cell is occupied");
    });

    it("Should not be allowed to place a card on the same cell twice", async function () {
        await expect(treasureTriad.playGame(
            <[GridCellStruct, GridCellStruct, GridCellStruct]><unknown>[
                [createNatureCell(54), createEmptyCell(), createEmptyCell()],
                [createNatureCell(54), createEmptyCell(), createEmptyCell()],
                [createNatureCell(54), createEmptyCell(), createEmptyCell()]
            ],
            Utilities.LegionClass.ALL_CLASS,
            [
                createPlayerMove(54, 1, 0),
                createPlayerMove(54, 1, 0)
            ]
            )).to.be.revertedWith("TreasureTriad: Cell is occupied");
    });

    it("Should be able to flip nature cards with affinity boost", async function () {
        // 98 stats are - 5, 6, 5, 6 ENCHANTER

        let outcome = await treasureTriad.playGame(
            <[GridCellStruct, GridCellStruct, GridCellStruct]><unknown>[
                [createEmptyCell(), createNatureCell(98, false, 0, true), createEmptyCell()],
                [createNatureCell(98), createEmptyCell(false, 0, true), createNatureCell(98)],
                [createEmptyCell(), createNatureCell(98), createEmptyCell()]
            ],
            Utilities.LegionClass.NUMERAIRE,
            [
                createPlayerMove(98, 1, 1)
            ]
        );

        // Uncorrupted the center tile, but not the corrupted tile under nature's cell.
        expect(outcome.numberOfCorruptedCardsLeft)
            .to.equal(1);
        // Didn't flip any because they were the same treasure and no boost from legion or tile.
        expect(outcome.numberOfFlippedCards)
            .to.equal(0);

        let outcomeWithBoost = await treasureTriad.playGame(
            <[GridCellStruct, GridCellStruct, GridCellStruct]><unknown>[
                [createEmptyCell(), createNatureCell(98, false, 0, true), createEmptyCell()],
                [createNatureCell(98), createEmptyCell(true, Utilities.TreasureCategory.ENCHANTER, true), createNatureCell(98)],
                [createEmptyCell(), createNatureCell(98), createEmptyCell()]
            ],
            Utilities.LegionClass.NUMERAIRE,
            [
                createPlayerMove(98, 1, 1)
            ]
        );
        // Flipped all and removed both corruptions
        // expect(outcomeWithBoost.numberOfCorruptedCardsLeft)
        //     .to.equal(0);
        // expect(outcomeWithBoost.numberOfFlippedCards)
        //     .to.equal(4);
    });

    it("Should be able to place cards in the corner", async function () {
        // 98 stats are - 5, 6, 5, 6 ENCHANTER

        let outcome = await treasureTriad.playGame(
            <[GridCellStruct, GridCellStruct, GridCellStruct]><unknown>[
                [createEmptyCell(true, Utilities.TreasureCategory.ALCHEMY), createNatureCell(98), createEmptyCell()],
                [createNatureCell(98), createEmptyCell(), createEmptyCell()],
                [createEmptyCell(), createEmptyCell(), createEmptyCell()]
            ],
            Utilities.LegionClass.ALL_CLASS,
            [
                createPlayerMove(98, 0, 0)
            ]
        );

        expect(outcome.numberOfCorruptedCardsLeft)
            .to.equal(0);
        // Flipped both. No affinity boost from treasure, but ALL_CLASS can handle alchemy.
        expect(outcome.numberOfFlippedCards)
            .to.equal(2);
    });

    function createEmptyCell(
        hasAffinity: boolean = false,
        affinity: Utilities.TreasureCategory = Utilities.TreasureCategory.ALCHEMY,
        isCorrupted: boolean = false)
    : GridCellStruct
    {
        return {
            "playerType": Utilities.PlayerType.NONE,
            "treasureId": 0,
            "hasAffinity": hasAffinity,
            "affinity": affinity,
            "isFlipped": false,
            "isCorrupted": isCorrupted
        };
    }

    function createNatureCell(
        treasureId: number,
        hasAffinity: boolean = false,
        affinity: Utilities.TreasureCategory = Utilities.TreasureCategory.ALCHEMY,
        isCorrupted: boolean = false)
    : GridCellStruct
    {
        return {
            "playerType": Utilities.PlayerType.NATURE,
            "treasureId": treasureId,
            "hasAffinity": hasAffinity,
            "affinity": affinity,
            "isFlipped": false,
            "isCorrupted": isCorrupted
        };
    }

    function createPlayerMove(treasureId: number, x: number, y: number): UserMoveStruct {
        return {
            "treasureId": treasureId,
            "x": x,
            "y": y
        };
    }
});
