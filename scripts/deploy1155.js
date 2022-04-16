const hre = require("hardhat");

async function main () { 
    const Contract = await hre.ethers.getContractFactory("AnimusRegnumArtifacts");
    const contract = await Contract.deploy()
    await contract.deployed();
    console.log("Contract deployed to ", contract.address);
    contract.mint("0x7A6fa150FDc54B3dCcBdC9A2906F25EBD98F4B34", 4);
}

main ()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });