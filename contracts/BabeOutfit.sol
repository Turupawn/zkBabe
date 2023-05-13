// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Babes.sol";
import "./Wearables.sol";

contract BabeOutfit {
    Babes public babes;
    Wearables public wearables;

    mapping(uint babeId => mapping(uint wearableCategory => uint wearableId)) public babeOutfit;

    constructor(address babesAddress, address wearablesAddress) {
        babes = Babes(babesAddress);
        wearables = Wearables(wearablesAddress);
    }

    // Public functions

    function equip(uint babeId, uint wearableId) public {
        require(babes.ownerOf(babeId) == msg.sender, "Sender must be the Babe owner.");
        require(wearables.ownerOf(wearableId) == msg.sender, "Sender must be the wearable owner.");

        uint wearableCategory = wearables.getCategory(wearables.getType(wearableId));

        if(babeOutfit[babeId][wearableCategory] != 0)
        {
            unequip(babeId, wearableCategory);
        }
    
        babeOutfit[babeId][wearableCategory] = wearableId;
        wearables.transferFrom(msg.sender, address(this), wearableId);
    }

    function unequip(uint babeId, uint wearableCategory) public {
        require(babes.ownerOf(babeId) == msg.sender, "Sender must be the babe owner.");
        uint wearableId = babeOutfit[babeId][wearableCategory];
        babeOutfit[babeId][wearableCategory] = 0;
        wearables.transferFrom(address(this), msg.sender, wearableId);
    }

    // View functions

    function getBabeOutfit(uint babeId, uint wearableCategory) public view returns(uint) {
        return babeOutfit[babeId][wearableCategory];
    }

    function getCharacterLevel(uint babeId, uint wearableCategoryAmount) public view returns(uint) {
        uint totalLevel;
        for(uint i=1; i<=wearableCategoryAmount; i++)
        {
            totalLevel += wearables.getLevel(getBabeOutfit(babeId, i));
        }
        return totalLevel;
    }
}