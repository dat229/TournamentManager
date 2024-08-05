require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
      bnb: {
        url: process.env.RPC_URL,
        accounts: [process.env.YOUR_PRIVATE_KEY],
      }
  }
  };
