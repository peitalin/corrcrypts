// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { run, ethers } from "hardhat";


async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const TreasureTriad = await ethers.getContractFactory("TreasureTriad");
  // const tTriad = await TreasureTriad .deploy();
  // await tTriad.deployed();

  // const TreasureTriadCardStats = await ethers.getContractFactory("TreasureTriadCardStats");
  // const tTriadCardStats = await TreasureTriadCardStats.deploy();
  // await tTriadCardStats .deployed();

  // console.log("TreasureTriad deployed to:", tTriad.address);
  // console.log("TreasureTriadCardStats  deployed to:", tTriadCardStats .address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
