const { expect } = require("chai");
const { ethers } = require("hardhat");

const ApertusSpheraContract = artifacts.require( 'contracts/AnimusRegnum/AnimusRegnumArtifacts.sol' );
const PFPContract = artifacts.require( 'contracts/AIDEN.sol' );

let apertus, pfp;
contract( 'Combined', async function( accts ){

  beforeEach(async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    apertus = await ApertusSpheraContract.new();
    //console.info({ 'Apertus.contract.address': apertus.address });

    pfp = await PFPContract.new();
    //console.info({ 'PFP.contract.address': pfp.address });

    await apertus.setDelegate( pfp.address, true );
    await apertus.setToken( 0, "", "www.amazon.com", 100, 100, true, 0, true, 0 );
    await pfp.setApertusSpheraContract( apertus.address );
  });

  it( "should not claim max supply", async () => {
    await apertus.mint(0, 10);
    await pfp.setMaxSupply(8);
    await expect(pfp.claimAll( 0 )).to.be.revertedWith('Quantity must be below max supply')
  });

  it( "should not claim none minted", async () => {
    await expect(pfp.claimSingle( 0 )).to.be.revertedWith('Must own an Apertus Sphera to claim')
  });

  it( "should not claim sale paused", async () => {
    await apertus.mint(0, 10);
    await pfp.togglePause();
    await expect(pfp.claimSingle( 0 )).to.be.revertedWith('Claim is paused.')
  });

  it( "should not claim invalid id", async () => {
    await apertus.mint(0, 10);
    await expect(pfp.claimSingle( 1 )).to.be.revertedWith('Invalid Apertus Sphera Token Id')
  });

  it( "Total supply of apertus should reduce", async () => {
    await apertus.mint(0, 10);
    let curr = (await apertus.totalSupply(0)).toNumber();
    await pfp.claimSingle( 0 );
    expect((await apertus.totalSupply(0)).toNumber()).to.equal(curr - 1);
  });

  it( "Confirm and change token uri", async () => {
    await apertus.mint(0, 10);
    await pfp.claimSingle( 0 );
    await expect(pfp.tokenURI( 1 )).to.be.revertedWith('URI query for nonexistent token');
    await pfp.setURI('www.hello.com/', '.json');
    expect(await pfp.tokenURI(0)).to.equal('www.hello.com/0.json');
  });
});