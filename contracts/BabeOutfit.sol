// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Babes.sol";
import "./BabeApparel.sol";

contract BabeOutfit {
    Babes public babes;
    BabeApparel public babeApparel;

    mapping(uint babeId => mapping(uint babeApparelCategory => uint babeApparelId)) public babeOutfit;

    constructor(address babesAddress, address babeApparelAddress) {
        babes = Babes(babesAddress);
        babeApparel = BabeApparel(babeApparelAddress);
    }

    // Public functions

    function equip(uint babeId, uint babeApparelId) public {
        require(babes.ownerOf(babeId) == msg.sender, "Sender must be the Babe owner.");
        require(babeApparel.ownerOf(babeApparelId) == msg.sender, "Sender must be the apparel owner.");

        uint babeApparelCategory = babeApparel.getCategory(babeApparel.getType(babeApparelId));

        if(babeOutfit[babeId][babeApparelCategory] != 0)
        {
            unequip(babeId, babeApparelCategory);
        }
    
        babeOutfit[babeId][babeApparelCategory] = babeApparelId;
        babeApparel.transferFrom(msg.sender, address(this), babeApparelId);
    }

    function unequip(uint babeId, uint babeApparelCategory) public {
        require(babes.ownerOf(babeId) == msg.sender, "Sender must be the babe owner.");
        uint babeApparelId = babeOutfit[babeId][babeApparelCategory];
        babeOutfit[babeId][babeApparelCategory] = 0;
        babeApparel.transferFrom(address(this), msg.sender, babeApparelId);
    }

    // View functions

    function getBabeOutfit(uint babeId, uint babeApparelCategory) public view returns(uint) {
        return babeOutfit[babeId][babeApparelCategory];
    }

    function getCharacterLevel(uint babeId, uint babeApparelCategoryAmount) public view returns(uint) {
        uint totalLevel;
        for(uint i=1; i<=babeApparelCategoryAmount; i++)
        {
            totalLevel += babeApparel.getLevel(getBabeOutfit(babeId, i));
        }
        return totalLevel;
    }
}