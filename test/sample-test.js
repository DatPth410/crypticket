const { expect } = require("chai");
const { ethers } = require("hardhat");

const checkBalance = async (tokenAddress, userAddress, tokenId) => {
  const balance = await tokenAddress.balanceOf(userAddress.address, tokenId);
  console.log(balance);
}

describe("Ticket1155Contract", function () {
  it("Test Ticket1155Contract", async function () {
    const [owner, eventOwner1, eventOwner2] =
        await ethers.getSigners();
    const Store = await ethers.getContractFactory("Store");
    const Ticket1155Contract = await ethers.getContractFactory("Ticket1155Contract");
    const Ticket1155Factory = await ethers.getContractFactory("Ticket1155Factory");

    const store = await Store.deploy();
    await store.deployed();

    const ticket1155Factory = await Ticket1155Factory.deploy();
    await ticket1155Factory.deployed();

    await ticket1155Factory.connect(eventOwner1).createEvent("Dat Pham Event");
    const eventAddress1 = await ticket1155Factory.getEventByIndex(0);
    const event1 = await Ticket1155Contract.attach(eventAddress1);

    // const ticket1155Contract = await Ticket1155Contract.deploy("Dat Pham Event");
    // await ticket1155Contract.deployed();

    const ticketName = await event1.getName();
    expect(ticketName).to.equal("Dat Pham Event");

    const ticketOwner = await event1.getOwner();
    expect(ticketOwner).to.equal(eventOwner1.address);

    await event1.initTicket(["VIP"],[20],[10]);
    const length = await event1.getLengthTicketInfo();
    // console.log(length);

    const ticketInfo = await event1.getTicketInfo(1);
    // console.log(ticketInfo);
    console.log(await event1.isApprovedForAll(store.address, event1.address))


  });

  it("Test store contract", async function () {
    const [owner, eventOwner1, ticketBuyer] =
        await ethers.getSigners();

    const Store = await ethers.getContractFactory("Store");
    const Ticket1155Contract = await ethers.getContractFactory("Ticket1155Contract");
    const Ticket1155Factory = await ethers.getContractFactory("Ticket1155Factory");

    const store = await Store.deploy();
    await store.deployed();

    const ticket1155Factory = await Ticket1155Factory.deploy();
    await ticket1155Factory.deployed();

    await ticket1155Factory.connect(eventOwner1).createEvent("Dat Pham Event");
    const eventAddress1 = await ticket1155Factory.getEventByIndex(0);
    const event1 = await Ticket1155Contract.attach(eventAddress1);
    await event1.connect(eventOwner1).initTicket(["VIP"],[20],[10]);
    await event1.connect(eventOwner1).setApprovalForAll(store.address, true);
    console.log(await event1.isApprovedForAll(eventOwner1.address, store.address));

    // await event1.connect(eventOwner1).setStore(store.address, [0]);
    const balanceMarket = await event1.balanceOf(store.address, 0);
    console.log(balanceMarket);
    // await event1.connect(eventOwner1).safeTransferFrom(eventOwner1.address, store.address, 0, 20, "0x");
    await store.connect(eventOwner1).setSell1155Ticket(event1.address, eventOwner1.address, [0], [20], [11]);
    const balanceMarketAfter = await event1.balanceOf(store.address, 0);
    console.log(balanceMarketAfter);

    // console.log("test1");
    console.log(await store.getTicket1155Data(event1.address));
    // console.log(await store.getLengthSellingEvent());
    // console.log(await store.listSellingEvent(0));
    //
    // console.log(await store.getTicket1155Data(event1.address))
    // console.log("test2");
    // expect(balanceMarket).to.equal(20);


    await checkBalance(event1, ticketBuyer, 0);
    await checkBalance(event1, store, 0);
    await store.connect(ticketBuyer).buy1155Ticket(event1.address, 0, 1, {
      value: ethers.utils.parseEther("1000")
    });
    await checkBalance(event1, ticketBuyer, 0);
    await checkBalance(event1, store, 0);
    const balanceUser = await event1.balanceOf(ticketBuyer.address, 0);
    expect(balanceUser).to.equal(1);
  });
});
