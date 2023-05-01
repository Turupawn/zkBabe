require("@nomicfoundation/hardhat-toolbox")
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: [process.env.SEPOLIA_PRIVATE_KEY  || ""]
    },
    optimism: {
      url: process.env.OPTIMISM_RPC_URL || "",
      accounts: [process.env.OPTIMISM_PRIVATE_KEY  || ""]
    },
  },
  etherscan: {
    apiKey: "TODO",
  },
};
