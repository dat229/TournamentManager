const { ethers } = require("hardhat");

async function main() {
const StorageContract = await ethers.getContractFactory("TokentestERC20");
const storageContract = await StorageContract.deploy(process.env.LOCATION);

await storageContract.waitForDeployment();
const tx = await storageContract.deploymentTransaction();

console.log("Contract deployed successfully.");
console.log(`Deployer: ${storageContract.runner.address}`);
console.log(`Deployed to: ${storageContract.target}`);
console.log(`Transaction hash: ${tx.hash}`);
}

main()
.then(() => process.exit(0))
.catch(error => {
    console.error(error);
    process.exit(1);
});