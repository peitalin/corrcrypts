import { ethers } from "hardhat";
import { expect } from "chai"
import { ShittyRandom, ShittyRandomInterface } from "../typechain-types/ShittyRandom";


describe("ShittyRandom", function () {

    // declare some variables, and assign them in the `before` and `beforeEach` callbacks.
    let ShittyRandom
    let sRandom: ShittyRandom

    // `beforeEach` runs before each test, re-deploying the contract every time.
    beforeEach(async function () {
        ShittyRandom = await ethers.getContractFactory("ShittyRandom");
        sRandom = await ShittyRandom.deploy();
    });

    it("ShittyRandom.sampleRandomGridCellCoords samples 2 gridCells without replacement", async function () {

        const decoder = new ethers.utils.AbiCoder();
        let numDraws = 2;

        let arrOfCellCoordsTx = await sRandom.sampleRandomGridCellCoords(numDraws);
        let receipt2 = await arrOfCellCoordsTx.wait();
        let logs2 = receipt2.events?.filter(x => x.event === "ArrayOfSampledCellCoords") ?? []
        let randomCells = decoder.decode(
            ['uint8[2][]'],
            ethers.utils.hexDataSlice(logs2?.[0].data, 0)
        )
        // console.log("Random Sampled Cells: ", randomCells)
        expect(randomCells[0].length).to.be.eq(numDraws)
    })

})

