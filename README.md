# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

## Sepolia deploy

Deploy #1
```
Babe:                 0x28EDA267FcB76Da69D7ba358BbBB2e7180C32227
Wearables:            0x28Af59a8688b0EBaDAb6ad0480459a6Eb0dfd13e
Character equipment:  0xE0E2ee0FFB00814a17bD75552421a9D6De7E8e57
Dungeons:             0x1D59e95cd7daA226cD718B3CBaFbBbB8AF528D66
```

Deploy #2
```
Babe:                 0x5FbDB2315678afecb367f032d93F642f64180aa3
Wearables:            0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Character equipment:  0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
Dungeons:             0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
```

## Optimism deploy
Babe:                 0x24EF68753793b732972E83B67B70409D4049A487
Wearables:            0x399Aef07480Da9391f1185b0a4dFA5d568ddA1BD
Character equipment:  0x73AC4AcA67a75a92e6F303C35925d37f395094D0
Dungeons:             0xcBd7052a962fAd922AFf01D27B68A4DcA1EdA413

## Launch step by step

First we launch the contracts.

```
npx hardhat run scripts/deployTest.js --network optimism
```

Then we verify them.

```
npx hardhat verify ... --network optimism
```

* Update contracts in JS and Node
* Launch the API backend on digital ocean
* Test if API is running correctly
* Bind domain name to API
* Set the new domain name on API Backend and relaunch 
* Set new domain on client code
* Set new domain dame on-chain with `TODO`
* Launch the frontend on netlify
* Whitelist on the netlify frontend with `setWhitelist(["0x707e55a12557E89915D121932F83dEeEf09E5d70"])`