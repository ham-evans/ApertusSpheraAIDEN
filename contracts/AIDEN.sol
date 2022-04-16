// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/****************************************
 * @author: @hammm.eth                  *
 * @team:   GoldenX                     *
 ****************************************
 *   Blimpie-ERC721 provides low-gas    *
 *           mints + transfers          *
 ****************************************/

import './Delegated.sol';
import './ERC721Batch.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

interface IApertusSphera {
	function balanceOf(address account, uint256 id) external view returns (uint256);
    function burn( address account, uint id, uint quantity ) external payable;
    function exists( uint id ) external view returns (bool);
}

contract AIDEN is Delegated, ERC721Batch {
    using Strings for uint;

    uint public MAX_SUPPLY = 3333;

    bool public PAUSED = false;

    IApertusSphera public ApertusSpheraProxy = IApertusSphera(0x683776E1768FdDBF1Ce43E505703F2f4df64FD12);

    string private _tokenURIPrefix;
    string private _tokenURISuffix;

    constructor()
        Delegated()
        ERC721B("A.I.D.E.N.", "AIDEN", 0){
    }

  //external payable
  fallback() external payable {}
  receive() external payable {}

  function tokenURI(uint tokenId) external view override returns (string memory) {
    require(_exists(tokenId), "URI query for nonexistent token");
    return string(abi.encodePacked(_tokenURIPrefix, tokenId.toString(), _tokenURISuffix));
  }

  function claimSingle ( uint tokenId ) external {
    require( !PAUSED , "Claim is paused." );
    require( ApertusSpheraProxy.exists( tokenId ), "Invalid Apertus Sphera Token Id" );
    require( totalSupply() < MAX_SUPPLY, "Total supply exceeded" );

    uint balance = ApertusSpheraProxy.balanceOf( msg.sender, tokenId );
    require( balance > 0, "Must own an Apertus Sphera to claim" );

    ApertusSpheraProxy.burn( msg.sender, tokenId, 1 );

    mint1 ( msg.sender );
  }

  function claimAll ( uint tokenId ) external {
    require( !PAUSED , "Claim is paused." );
    require( ApertusSpheraProxy.exists( tokenId ), "Invalid Apertus Sphera Token Id" );

    uint balance = ApertusSpheraProxy.balanceOf( msg.sender, tokenId );
    require( balance > 0, "Must own an Apertus Sphera to claim" );
    require( totalSupply() + balance < MAX_SUPPLY, "Quantity must be below max supply" );


    ApertusSpheraProxy.burn( msg.sender, tokenId, balance );

    for( uint i; i < balance; ++i ) {
        mint1 ( msg.sender );
    }
  }

  function setURI(string calldata _newPrefix, string calldata _newSuffix) external onlyDelegates{
    _tokenURIPrefix = _newPrefix;
    _tokenURISuffix = _newSuffix;
  }

  function togglePause () external onlyDelegates {
    PAUSED = !PAUSED;
  }

  function setMaxSupply ( uint _newMaxSupply ) external onlyDelegates { 
    require( totalSupply() < _newMaxSupply, "New supply must be greater than current supply");
    MAX_SUPPLY = _newMaxSupply;
  }

  function setApertusSpheraContract(address _apertusSphera) external onlyDelegates {
    if( address(ApertusSpheraProxy) != _apertusSphera )
      ApertusSpheraProxy = IApertusSphera(_apertusSphera);
  }

  function mint1( address to ) internal {
    uint tokenId = _next();
    tokens.push(Token(to));

    _safeMint( to, tokenId, "" );
  }

  function _mint(address to, uint tokenId) internal override {
    emit Transfer(address(0), to, tokenId);
  }
}