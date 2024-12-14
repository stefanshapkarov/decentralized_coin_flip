# CoinFlip smart contract

A smart contract which essentially is a decentralized betting game of coin flip made with the help of hardhat.
(A deployed version on the Sepolia test network - 0xFeD1Afd53853A52F80Dd2140e13Bf36c367B8fa6)

## Deployment

To deploy this project first make sure you have npm and run
(Make sure you are inside the Contract directory)

```bash
  npm install
```

Then in the same folder run the following command to compile the contract

```bash
  npx hardhat compile
```

In the hardhat configuration there is already one for sepolia testnet, but you can add more,

Optionally, you can deploy to a local node for which first you need to run

```bash
  npx hardhat node
```

Then to deploy the contract run the following command

```bash
  npx hardhat ignition deploy ignition/modules/deploy.js --network <network-name>
```

(If you want to deploy to localhost simply write localhost as the network name)
## Bonus

To interact with the contract through console run

```bash
npx hardhat console --network <network-name>
```

