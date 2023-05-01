// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Wearables is ERC721, ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;

    // Public variables
    Counters.Counter private tokenIds;
    mapping(uint wearableId => uint wearableType) public wearableTypes;
    mapping(uint wearableType => uint wearableCategory) public wearableCategories;
    mapping(uint wearableType => uint level) public wearableTypeLevel;
    mapping(address account => bool isMinter) public isMinter;

    string public baseTokenURI = "http://localhost:3005/metadata/wearables/";

    constructor() ERC721("My NFT", "MNFT") {
        wearableTypeLevel[1] = 2;
        wearableTypeLevel[2] = 8;
        wearableTypeLevel[3] = 5;
        wearableTypeLevel[4] = 10;
        wearableTypeLevel[5] = 10;
        wearableTypeLevel[6] = 15;
        wearableTypeLevel[7] = 25;
        wearableTypeLevel[8] = 50;

        wearableCategories[1] = 1;
        wearableCategories[2] = 2;
        wearableCategories[3] = 1;
        wearableCategories[4] = 2;
        wearableCategories[5] = 1;
        wearableCategories[6] = 2;
        wearableCategories[7] = 2;
        wearableCategories[8] = 2;
    }

    // Public functions

    function mint(address to, uint wearableType) public {
        require(isMinter[msg.sender], "Sender is not minter");
        tokenIds.increment();
        _mint(to, tokenIds.current());
        wearableTypes[tokenIds.current()] = wearableType;
    }

    // Owner Functions

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setWearableTypeLevel(uint wearableType, uint level) public onlyOwner {
        wearableTypeLevel[wearableType] = level;
    }

    function setWearableCategory(uint wearableCategory, uint level) public onlyOwner {
        wearableCategories[wearableCategory] = level;
    }

    function setMinter(address address_, bool value) public onlyOwner {
        isMinter[address_] = value;
    }

    // Overrided functions

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // View functions

    function getLevel(uint wearableId) public view returns(uint) {
        return wearableTypeLevel[wearableTypes[wearableId]];
    }

    function getType(uint wearableId) public view returns(uint) {
        return wearableTypes[wearableId];
    }

    function getCategory(uint wearableId) public view returns(uint) {
        return wearableCategories[wearableId];
    }
}