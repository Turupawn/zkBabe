// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Characters.sol";
import "./Wearables.sol";

contract CharacterEquipment {
    Characters public characters;
    Wearables public wearables;

    mapping(uint characterId => mapping(uint wearableCategory => uint wearableId)) public characterEquipment;

    constructor(address charactersAddress, address wearablesAddress) {
        characters = Characters(charactersAddress);
        wearables = Wearables(wearablesAddress);
    }

    // Public functions

    function equip(uint characterId, uint wearableId) public {
        require(characters.ownerOf(characterId) == msg.sender, "Sender must be the character owner.");
        require(wearables.ownerOf(wearableId) == msg.sender, "Sender must be the wearable owner.");

        uint wearableCategory = wearables.getCategory(wearables.getType(wearableId));

        if(characterEquipment[characterId][wearableCategory] != 0)
        {
            unequip(characterId, wearableCategory);
        }
    
        characterEquipment[characterId][wearableCategory] = wearableId;
        wearables.transferFrom(msg.sender, address(this), wearableId);
    }

    function unequip(uint characterId, uint wearableCategory) public {
        require(characters.ownerOf(characterId) == msg.sender, "Sender must be the character owner.");
        uint wearableId = characterEquipment[characterId][wearableCategory];
        characterEquipment[characterId][wearableCategory] = 0;
        wearables.transferFrom(address(this), msg.sender, wearableId);
    }

    // View functions

    function getCharacterEquipment(uint characterId, uint wearableCategory) public view returns(uint) {
        return characterEquipment[characterId][wearableCategory];
    }

    function getCharacterLevel(uint characterId, uint wearableCategoryAmount) public view returns(uint) {
        uint totalLevel;
        for(uint i=1; i<=wearableCategoryAmount; i++)
        {
            totalLevel += wearables.getLevel(getCharacterEquipment(characterId, i));
        }
        return totalLevel;
    }
}