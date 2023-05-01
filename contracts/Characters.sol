// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Characters is ERC721, ERC721Enumerable, Ownable {
    
    using Counters for Counters.Counter;

    // Public variables
    Counters.Counter private tokenIds;
    mapping(uint characterId => uint characterType) public characterTypes;
    mapping(address account => bool isWhitelisted) public whitelist;
    uint public characterTypeAmount = 4;

    // Internal variables
    uint randomNonce = 0;

    string public baseTokenURI = "http://localhost:3005/metadata/characters/";

    constructor() ERC721("Character", "CHAR") {}

    // Public functions

    function mint(address to) public {
        require(whitelist[msg.sender], "Must be whitelisted");
        whitelist[msg.sender] = false;
        tokenIds.increment();
        _mint(to, tokenIds.current());
        characterTypes[tokenIds.current()] = getRandomNumber(characterTypeAmount); 
    }

    // View Functions

    function getCharacterType(uint characterId) public view returns(uint) {
        return characterTypes[characterId];
    }

    // Owner Functions

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setCharacterTypeAmount(uint amount) public onlyOwner {
        characterTypeAmount = amount;
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

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
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