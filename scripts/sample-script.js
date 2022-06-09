// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const {ethers} = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Greeter = await hre.ethers.getContractFactory("Greeter");
  const Ticket1155Factory = await ethers.getContractFactory("Ticket1155Factory");
  const Store = await ethers.getContractFactory("Store");
  const Marketplace = await ethers.getContractFactory("Marketplace");

  const greeter = await Greeter.deploy("Hello, Hardhat!");

  await greeter.deployed();

  console.log("Greeter deployed to:", greeter.address);



  const ticket1155Factory = await Ticket1155Factory.deploy();
  await ticket1155Factory.deployed();
  console.log("Ticket1155Factory deployed to:", ticket1155Factory.address);

  const store = await Store.deploy();
  await store.deployed();
  console.log("Store deployed to:", store.address);

  const marketplace = await Marketplace.deploy();
  await marketplace.deployed();
  console.log("Marketplace deployed to:", marketplace.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
