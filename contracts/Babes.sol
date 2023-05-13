// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Babes is ERC721, ERC721Enumerable, Ownable {
    
    using Counters for Counters.Counter;

    // Public variables
    Counters.Counter private tokenIds;
    mapping(uint babeId => uint babeType) public babeTypes;
    mapping(address account => bool isWhitelisted) public whitelist;
    uint public babeTypeAmount = 4;

    // Internal variables
    uint randomNonce = 0;

    string public baseTokenURI = "http://localhost:3005/metadata/babe/";

    constructor() ERC721("Babe", "BABE") {}

    // Public functions

    function mint(address to) public {
        require(whitelist[msg.sender], "Must be whitelisted");
        whitelist[msg.sender] = false;
        tokenIds.increment();
        _mint(to, tokenIds.current());
        babeTypes[tokenIds.current()] = getRandomNumber(babeTypeAmount); 
    }

    // View Functions

    function getBabeType(uint babeId) public view returns(uint) {
        return babeTypes[babeId];
    }

    // Owner Functions

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setBabeTypeAmount(uint amount) public onlyOwner {
        babeTypeAmount = amount;
    }

    function setWhitelist(address[] memory accounts) public onlyOwner {
        for(uint256 i; i < accounts.length; i++){
            whitelist[accounts[i]] = true;
        }
    }

    // Overrided functions

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId, uint batchSize) internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // Internal functions

    function getRandomNumber(uint modulus) internal returns(uint)
    {
        randomNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randomNonce))) % modulus;
    }
}