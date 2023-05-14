// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BabeApparel is ERC721, ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;

    // Public variables
    Counters.Counter private tokenIds;
    mapping(uint apparelId => uint apparelType) public apparelTypes;
    mapping(uint apparelType => uint apparelCategory) public apparelCategories;
    mapping(uint apparelType => uint level) public apparelTypeLevel;
    mapping(address account => bool isMinter) public isMinter;

    string public baseTokenURI = "http://localhost:3005/metadata/apparel/";

    constructor() ERC721("My NFT", "MNFT") {
        apparelTypeLevel[1] = 2;
        apparelTypeLevel[2] = 8;
        apparelTypeLevel[3] = 5;
        apparelTypeLevel[4] = 10;
        apparelTypeLevel[5] = 10;
        apparelTypeLevel[6] = 15;
        apparelTypeLevel[7] = 25;
        apparelTypeLevel[8] = 50;

        apparelCategories[1] = 1;
        apparelCategories[2] = 2;
        apparelCategories[3] = 1;
        apparelCategories[4] = 2;
        apparelCategories[5] = 1;
        apparelCategories[6] = 2;
        apparelCategories[7] = 2;
        apparelCategories[8] = 2;
    }

    // Public functions

    function mint(address to, uint apparelType) public {
        require(isMinter[msg.sender], "Sender is not minter");
        tokenIds.increment();
        _mint(to, tokenIds.current());
        apparelTypes[tokenIds.current()] = apparelType;
    }

    // Owner Functions

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setApparelTypeLevel(uint apparelType, uint level) public onlyOwner {
        apparelTypeLevel[apparelType] = level;
    }

    function setApparelCategory(uint apparelCategory, uint level) public onlyOwner {
        apparelCategories[apparelCategory] = level;
    }

    function setMinter(address address_, bool value) public onlyOwner {
        isMinter[address_] = value;
    }

    // Overrided functions

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId, uint batchSize) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // View functions

    function getLevel(uint apparelId) public view returns(uint) {
        return apparelTypeLevel[apparelTypes[apparelId]];
    }

    function getType(uint apparelId) public view returns(uint) {
        return apparelTypes[apparelId];
    }

    function getCategory(uint apparelId) public view returns(uint) {
        return apparelCategories[apparelId];
    }
}