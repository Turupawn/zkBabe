// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Babes.sol";
import "./BabeApparel.sol";

contract BabeOutfit is Ownable {
    Babes public babes;
    mapping(address contractAddress => bool isBabeApparel) babeApparels;

    struct ApparelOnOutfit {
        address babeApparelContractAddress;
        uint babeApparelId;
    }

    mapping(uint babeId => mapping(uint babeApparelCategory => ApparelOnOutfit)) public babeOutfit;
    mapping(uint babeId => mapping(uint babeApparelCategory => address babeApparelContractAddress)) public babeApparelContractAddress; 

    constructor(address babesAddress) {
        babes = Babes(babesAddress);
    }

    // Owner functions
    function setBabeApparel(address contractAddress, bool isBabeApparel) public onlyOwner {
        babeApparels[contractAddress] = isBabeApparel;
    }

    // Public functions

    function putOnApparel(uint babeId, address babeApparelAddress, uint babeApparelId) public {
        require(babes.ownerOf(babeId) == msg.sender, "Sender must be the Babe owner.");
        require(babeApparels[babeApparelAddress], "Invalid BabeApparel contract");
        BabeApparel babeApparel = BabeApparel(payable(babeApparelAddress));
        require(babeApparel.ownerOf(babeApparelId) == msg.sender, "Sender must be the apparel owner.");

        uint babeApparelCategory = babeApparel.getCategory(babeApparel.getType(babeApparelId));

        if(babeOutfit[babeId][babeApparelCategory].babeApparelId != 0)
        {
            takeOffApparel(babeId, babeApparelCategory);
        }
    
        babeOutfit[babeId][babeApparelCategory].babeApparelId = babeApparelId;
        babeApparel.transferFrom(msg.sender, address(this), babeApparelId);
    }

    function takeOffApparel(uint babeId, uint babeApparelCategory) public {
        require(babes.ownerOf(babeId) == msg.sender, "Sender must be the babe owner.");
        BabeApparel babeApparel = BabeApparel(payable(getBabeApparelContractAddress(babeId, babeApparelCategory)));

        uint babeApparelId = babeOutfit[babeId][babeApparelCategory].babeApparelId;
        babeOutfit[babeId][babeApparelCategory].babeApparelId = 0;
        babeApparel.transferFrom(address(this), msg.sender, babeApparelId);
    }

    // View functions

    function getBabeApparelId(uint babeId, uint babeApparelCategory) public view returns(uint) {
        return babeOutfit[babeId][babeApparelCategory].babeApparelId;
    }

    function getBabeApparelContractAddress(uint babeId, uint babeApparelCategory) public view returns(address) {
        return babeOutfit[babeId][babeApparelCategory].babeApparelContractAddress;
    }

    function getCharacterRarity(uint babeId, uint babeApparelCategoryAmount) public view returns(uint) {
        uint totalRarity;
        for(uint i=1; i<=babeApparelCategoryAmount; i++)
        {
            BabeApparel babeApparel = BabeApparel(payable(getBabeApparelContractAddress(babeId, i)));
            totalRarity += babeApparel.getRarity(getBabeApparelId(babeId, i));
        }
        return totalRarity;
    }

    fallback() external payable {
    }

    receive() external payable {
    }
}