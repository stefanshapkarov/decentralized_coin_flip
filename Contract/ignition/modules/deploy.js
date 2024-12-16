const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CoinFlip", (m) => {
    const coinFlip = m.contract("CoinFlip", []);
  
    return { coinFlip };
});