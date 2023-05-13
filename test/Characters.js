const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", function () {
  async function deployFixture() {
    const [owner, account1, account2] = await ethers.getSigners();

    const Babe = await hre.ethers.getContractFactory("Babe");
    const Wearables = await hre.ethers.getContractFactory("Wearables");
    const CharacterEquipment = await hre.ethers.getContractFactory("CharacterEquipment");
    const babe = await Babe.deploy();
    const wearables = await Wearables.deploy();
    const characterEquipment = await CharacterEquipment.deploy(babe.address, wearables.address);
  
    console.log("Babe:                ", babe.address);
    console.log("Wearables:           ", wearables.address);
    console.log("Character equipment: ", characterEquipment.address);

    return {babe, wearables, characterEquipment, owner, account1, account2}
  }

  describe("Deployment", function () {

    it("Should fail if the unlockTime is not in the future", async function () {
      const {
        babe,
        wearables,
        characterEquipment,
        owner, account1, account2
      } = await loadFixture(deployFixture);

      await babe.mint(account1.address)
      await wearables.mint(account1.address, "1")
      await wearables.connect(account1).approve(characterEquipment.address, "0")
      await characterEquipment.connect(account1).equip("0", "0")
    });
  });
});
