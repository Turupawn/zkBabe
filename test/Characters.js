const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", function () {
  async function deployFixture() {
    const [owner, account1, account2] = await ethers.getSigners();

    const Characters = await hre.ethers.getContractFactory("Characters");
    const Wearables = await hre.ethers.getContractFactory("Wearables");
    const CharacterEquipment = await hre.ethers.getContractFactory("CharacterEquipment");
    const characters = await Characters.deploy();
    const wearables = await Wearables.deploy();
    const characterEquipment = await CharacterEquipment.deploy(characters.address, wearables.address);
  
    console.log("Characters:          ", characters.address);
    console.log("Wearables:           ", wearables.address);
    console.log("Character equipment: ", characterEquipment.address);

    return {characters, wearables, characterEquipment, owner, account1, account2}
  }

  describe("Deployment", function () {

    it("Should fail if the unlockTime is not in the future", async function () {
      const {
        characters,
        wearables,
        characterEquipment,
        owner, account1, account2
      } = await loadFixture(deployFixture);

      await characters.mint(account1.address)
      await wearables.mint(account1.address, "1")
      await wearables.connect(account1).approve(characterEquipment.address, "0")
      await characterEquipment.connect(account1).equip("0", "0")
    });
  });
});
