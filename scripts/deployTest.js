// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");

async function main() {
  const [owner, account1, account2] = await ethers.getSigners();
  const Babe = await hre.ethers.getContractFactory("Babe");
  const Wearables = await hre.ethers.getContractFactory("Wearables");
  const CharacterEquipment = await hre.ethers.getContractFactory("CharacterEquipment");
  const Dungeons = await hre.ethers.getContractFactory("Dungeons");

  // Smart Contract Deploy
  const babe = await Babe.deploy();
  const wearables = await Wearables.deploy();
  const characterEquipment = await CharacterEquipment.deploy(babe.address, wearables.address);
  const dungeons = await Dungeons.deploy(babe.address, wearables.address, characterEquipment.address);

  console.log("Babe:                ", babe.address);
  console.log("Wearables:           ", wearables.address);
  console.log("Character equipment: ", characterEquipment.address);
  console.log("Dungeons:            ", dungeons.address);

  // Initial setup

  await wearables.setMinter(dungeons.address, true)

  return;

  console.log("==All Dungeons==")
  for(i=1; i<=4; i++)
  {
    dungeon = await dungeons.dungeons(i)
    console.log("Dungeon " + i)
    console.log(
      " duration: " + dungeon[0] +
      " minimum level: " + dungeon[1])
    probabilities = ""
    for(j=1; j<=8; j++)
    {
      probability = await dungeons.getDungeonLootProbability(i, j)
      if(probability != 0)
      {
        probabilities += " wearable " + j + " " + probability/100 + "%,"
      }
    }
    console.log(probabilities)
  }
  console.log("== end ==")

  console.log("==All Wearables==")
  for(i=1; i<=4; i++)
  {

  }
  console.log("== end ==")

  // Game
  console.log("Let's mint two characters")
  await characters.mint(owner.address)
  await characters.mint(owner.address)

  console.log("==My Characters==")
  for(i=0; i<await characters.balanceOf(owner.address); i++)
  {
    characterId = await characters.tokenOfOwnerByIndex(owner.address, i)
    characterType = await characters.characterTypes(characterId)
    console.log("Id: " + characterId + ", " + " type: " + characterType)
  }
  console.log("== end ==")

  console.log("Now we enter the first dungeon with character 1 to dungeon 1 and wait")
  await dungeons.enterDungeon(1, 1);
  await time.increaseTo(1777820202);
  console.log("Now we loot")
  await dungeons.loot(1);
  console.log("We equip the looted equipment")
  await wearables.approve(characterEquipment.address, 1) 
  console.log("We equip to the character 1 the item 1")
  await characterEquipment.equip(1, 1)
  console.log("We now enter the dungeon 2")
  await dungeons.enterDungeon(1, 2);
  await time.increaseTo(1877820202);
  await dungeons.loot(1);
  await wearables.approve(characterEquipment.address, 2) 
  await characterEquipment.equip(1,2)
  //console.log("We now enter the dungeon 3")
  //await dungeons.enterDungeon(1, 3);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
