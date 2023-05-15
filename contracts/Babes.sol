// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./BabeApparel.sol";

contract Babes is ERC721, ERC721Enumerable, Ownable {
    
    using Counters for Counters.Counter;

    // Public variables
    Counters.Counter private tokenIds;
    mapping(uint babeId => uint babeType) public babeTypes;
    uint public babeTypeAmount;
    uint public mintPrice;
    address public initialApparelContract;

    // Internal variables
    uint randomNonce = 0;

    string public baseTokenURI = "http://localhost:3005/metadata/babe/";

    constructor(uint _mintPrice, uint _babeTypeAmount, address _initialApparelContract) ERC721("Babe", "BABE") {
        mintPrice = _mintPrice;
        babeTypeAmount = _babeTypeAmount;
        initialApparelContract = _initialApparelContract;
    }

    // Public functions

    function mint(address to, uint babeType) public payable {
        require(msg.value == mintPrice, "Invalid eth sent");
        require(babeType < babeTypeAmount, "Invalid babe type");
        tokenIds.increment();
        _mint(to, tokenIds.current());
        BabeApparel(initialApparelContract).mintInitialApparel(to);
        babeTypes[tokenIds.current()] = babeType;
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

    function setPrice(uint _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
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
}