
import { deployments, ethers, network } from "hardhat";
import { ContractTransaction, BigNumber, Contract, BigNumberish } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Legion, LegionMetadataStore, Randomizer } from "../typechain-types";

export module Utilities {

    export enum PlayerType {
        NONE = 0,
        NATURE = 1,
        USER = 2
    }

    export enum LegionGeneration {
        GENESIS = 0,
        AUXILIARY = 1,
        RECRUIT = 2
    }

    export enum LegionRarity {
        LEGENDARY = 0,
        RARE = 1,
        SPECIAL = 2,
        UNCOMMON = 3,
        COMMON = 4,
        RECRUIT = 5
    }

    export enum LegionClass {
        RECRUIT = 0,
        SIEGE = 1,
        FIGHTER = 2,
        ASSASSIN = 3,
        RANGED = 4,
        SPELLCASTER = 5,
        RIVERMAN = 6,
        NUMERAIRE = 7,
        ALL_CLASS = 8,
        ORIGIN = 9
    }

    export enum TreasureCategory {
        ALCHEMY = 0,
        ARCANA = 1,
        BREWING = 2,
        ENCHANTER = 3,
        LEATHERWORKING = 4,
        SMITHING = 5
    }

    export enum Constellation {
        FIRE = 0,
        EARTH = 1,
        WIND = 2,
        WATER = 3,
        LIGHT = 4,
        DARK = 5
    }

    export enum QuestDifficulty {
        EASY = 0,
        MEDIUM = 1,
        HARD = 2
    }

    export enum RecipeDifficulty {
        EASY = 0,
        MEDIUM = 1,
        HARD = 2
    }

    export async function changeAutomineEnabled(enabled: boolean) {
        await network.provider.send("evm_setAutomine", [enabled]);
    }

    export async function mine(...args: ContractTransaction[]) {
        await ethers.provider.send("evm_mine", []);
        for(var txn of args) {
            await txn.wait();
        }
    }

    export async function mineForward(forwardSeconds: number) {
        const now = await blockNow();
        await ethers.provider.send("evm_mine", [now.add(forwardSeconds).toNumber()]);
    }

    export async function increaseTime(seconds: number) {
        await ethers.provider.send('evm_increaseTime', [seconds]);
        await ethers.provider.send("evm_mine", []);
    }

    export async function currentBlockNumber() : Promise<number> {
        return await ethers.provider.getBlockNumber();
    }

    export async function blockNow() : Promise<BigNumber> {
        const blockNumber = await currentBlockNumber();
        const block = await ethers.provider.getBlock(blockNumber)
        return BigNumber.from(block.timestamp);
    }

    export async function getDeployedContract<T extends Contract>(name: string, deployer: SignerWithAddress) : Promise<T> {
        const deployment = await deployments.get(name);
        return new Contract(
            deployment.address,
            deployment.abi,
            deployer
        ) as T;
    }

    export async function getAnyDeployedContract(name: string, deployer: SignerWithAddress) : Promise<Contract> {
        const deployment = await deployments.get(name);
        return new Contract(
            deployment.address,
            deployment.abi,
            deployer
        );
    }

    export async function mintLegion(legion: Legion, legionMetadataStore: LegionMetadataStore, address: string, generation: LegionGeneration, rarity: LegionRarity = LegionRarity.RARE, legionClass: LegionClass = LegionClass.ASSASSIN, questLevel: number = 1, craftLevel: number = 1) : Promise<number> {
        await(await legion.safeMint(address)).wait();

        let tokenId = await legion.totalSupply();

        await(await legionMetadataStore.setInitialMetadataForLegion(address, tokenId, generation, legionClass, rarity, 0)).wait();

        for(var i = 1; i < questLevel; i++) {
            await(await legionMetadataStore.increaseQuestLevel(tokenId)).wait();
        }

        for(var i = 1; i < craftLevel; i++) {
            await(await legionMetadataStore.increaseCraftLevel(tokenId)).wait();
        }

        return tokenId.toNumber();
    }

    export async function setRandomNumber(randomizer: Randomizer, random: BigNumberish) {
        await(await randomizer.incrementCommitId()).wait();
        await(await randomizer.addRandomForCommit(random)).wait();
    }
}
