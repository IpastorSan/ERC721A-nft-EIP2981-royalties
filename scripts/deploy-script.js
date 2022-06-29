const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

//run with this for testing: npx hardhat run scripts/deploy-script.js --network rinkeby || mainnet || poligonMumbai || matic

// We get the contract to deploy
  let deployment_base_uri = "ipfs://someipfsCIDherewouldbenice/"
  const NFTContractContract = await hre.ethers.getContractFactory("BlueGhost");
  const NFTContract = await NFTContractContract.deploy(deployment_base_uri);

  await NFTContract.deployed();

  console.log("NFTContract deployed to:", NFTContract.address);
  //Uncomment the command that applies
  // console.log(`See collection in Opensea: https://testnets.opensea.io/${NFTContract.address}`)
  // console.log(`See collection in Opensea: https://opensea.io/${NFTContract.address}`)

}


const runMain = async () => {
  try {
      await main();
      process.exit(0);
  } catch (error) {
      console.log(error);
      process.exit(1);
  }
};


runMain();
