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
  const Babes = await hre.ethers.getContractFactory("Babes");
  const BabeApparel = await hre.ethers.getContractFactory("BabeApparel");
  const BabeOutfit = await hre.ethers.getContractFactory("BabeOutfit");
  const BabeApparelCeremony = await hre.ethers.getContractFactory("BabeApparelCeremony");
  const RandomnessCeremonyProtocol = await hre.ethers.getContractFactory("RandomnessCeremonyProtocol");
  
  // Smart Contract Deploy
  const babeApparel = await BabeApparel.deploy();
  const babes = await Babes.deploy(ethers.utils.parseEther("0.005"), 1, babeApparel.address);
  const babeOutfit = await BabeOutfit.deploy(babes.address);
  const randomnessCeremonyProtocol = await RandomnessCeremonyProtocol.deploy();
  const babeApparelCeremony = await BabeApparelCeremony.deploy(randomnessCeremonyProtocol.address, babeApparel.address);

  console.log("Babes:                    ", babes.address);
  console.log("BabeApparel:              ", babeApparel.address);
  console.log("BabeOutfit:               ", babeOutfit.address);
  console.log("Randomness Protocol:      ", randomnessCeremonyProtocol.address);
  console.log("Babe Apparel Ceremony:    ", babeApparelCeremony.address);

  // Initial setup

  await babeApparel.setMinter(babes.address, true)
  await babeApparel.setMinter(babeApparelCeremony.address, true)
  await babeOutfit.setBabeApparel(babeApparel.address, true)

  // Minting babes

  console.log("Let's mint two babes")
  await babes.mint(owner.address, 0, {value: ethers.utils.parseEther("0.005")})
  await babes.mint(owner.address, 0, {value: ethers.utils.parseEther("0.005")})

  // 

  console.log("==My Babes==")
  for(i=0; i<await babes.balanceOf(owner.address); i++)
  {
    babeId = await babes.tokenOfOwnerByIndex(owner.address, i)
    babeType = await babes.getBabeType(babeId)
    console.log("Id: " + babeId + ", " + " type: " + babeType)
  }
  console.log("== end ==")



  console.log("Let's generate some randomness")

  const currentTimestamp = Math.round(Date.now() / 1000)
  const commitmentDeadline = currentTimestamp + 24 * 60 * 60 // in one day
  const revealDeadline = currentTimestamp + 2* (24 * 60 * 60) // in two days
  await babeApparelCeremony.createBabeApparelCeremony(
    commitmentDeadline,
    revealDeadline,
    ethers.utils.parseEther("0.1")
  );
  
  secret1 = ethers.utils.formatBytes32String("secret example hello yeah")
  hash1 = ethers.utils.keccak256(secret1)
  secret2 = ethers.utils.formatBytes32String("woo!")
  hash2 = ethers.utils.keccak256(secret2)
  
  console.log("Committing two hashes")
  
  await babeApparelCeremony.commit(0, hash1, {value: ethers.utils.parseEther("0.1")})
  await babeApparelCeremony.commit(0, hash2, {value: ethers.utils.parseEther("0.1")})
  
  await time.increaseTo(commitmentDeadline + 1);
  
  console.log("Revealing the two secrets")
  
  await babeApparelCeremony.reveal(0, hash1, secret1)
  await babeApparelCeremony.reveal(0, hash2, secret2)
  
  await time.increaseTo(revealDeadline + 1);
  
  console.log("Randomness: " + await randomnessCeremonyProtocol.getRandomness(0))
  
  console.log("Now claiming the random reward:")
  await babeApparelCeremony.claim(0)
  
  console.log("==My Apparel==")
  for(i=0; i<await babeApparel.balanceOf(owner.address); i++)
  {
    apparelId = await babeApparel.tokenOfOwnerByIndex(owner.address, i)
    apparelType = await babeApparel.getType(apparelId)
    apparelCategory = await babeApparel.getCategory(apparelId)
    console.log("Id: " + apparelId + ", " + " type: " + apparelType + ", " + " category: " + apparelCategory)
  }
  console.log("== end ==")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
