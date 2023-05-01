// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Characters.sol";
import "./CharacterEquipment.sol";

contract Dungeons is Ownable {
    // Public variables
    uint wearablesAmount = 8;
    Characters public characters;
    Wearables public wearables;
    CharacterEquipment public characterEquipment;
    mapping(uint characterId => Registration) public registration;
    mapping(uint dungeonId => Dungeon) public dungeons;

    // Internal variables
    uint randomNonce;

    struct Dungeon
    {
        uint duration;
        uint minimumLevel;
        mapping(uint => uint) lootProbability;
    }

    struct Registration
    {
        address owner;
        uint dungeonId;
        uint advanceTimestamp;
    }

    constructor(address charactersAddress, address wearablesAddress, address characterEquipmentAddress) {
        characters = Characters(charactersAddress);
        wearables = Wearables(wearablesAddress);
        characterEquipment = CharacterEquipment(characterEquipmentAddress);

        dungeons[1].duration = 5 minutes;
        dungeons[1].minimumLevel = 0;
        dungeons[1].lootProbability[1] = 5000;
        dungeons[1].lootProbability[2] = 5000;

        dungeons[2].duration = 15 minutes;
        dungeons[2].minimumLevel = 1;
        dungeons[2].lootProbability[3] = 5000;
        dungeons[2].lootProbability[4] = 5000;

        dungeons[3].duration = 4 hours;
        dungeons[3].minimumLevel = 10;
        dungeons[3].lootProbability[5] = 4000;
        dungeons[3].lootProbability[6] = 3000;
        dungeons[3].lootProbability[7] = 3000;

        dungeons[4].duration = 8 hours;
        dungeons[4].minimumLevel = 20;
        dungeons[4].lootProbability[7] = 5000;
        dungeons[4].lootProbability[8] = 5000;
    }

    // Public functions

    function enterDungeon(uint characterId, uint dungeonId) public {
        require(characters.ownerOf(characterId) == msg.sender, "Must be Character holder");
        require(registration[characterId].dungeonId == 0, "Character is already in a dungeon");
        require(registration[characterId].dungeonId == 0, "Character has not the minimum level");
        require(dungeons[dungeonId].duration != 0, "Invalid Dungeon Id");
        require(characterEquipment.getCharacterLevel(characterId, 2) >= dungeons[dungeonId].minimumLevel, "Character has not enough level");
        registration[characterId] =
            Registration(
                msg.sender,
                dungeonId,
                block.timestamp + dungeons[dungeonId].duration
            );
    }

    function loot(uint characterId) public {
        require(registration[characterId].dungeonId != 0, "Character is not in a dungeon");
        require(block.timestamp >= registration[characterId].advanceTimestamp, "Character is still fighting");

        uint randomness = getRandomNumber(10000);
        uint probabilitySum;
        for(uint i=1; i<=wearablesAmount; i++)
        {
            uint probability = dungeons[registration[characterId].dungeonId].lootProbability[i];
            if(randomness < probability + probabilitySum)
            {
                wearables.mint(msg.sender, i);
                registration[characterId].dungeonId = 0;
                return;
            }
            probabilitySum += probability;
        }
        revert("Invalid loot");
    }

    // View functions

    function getDungeonDuration(uint dungeonId) public view returns(uint)
    {
        return dungeons[dungeonId].duration;
    }

    function getDungeonMinimumLevel(uint dungeonId) public view returns(uint)
    {
        return dungeons[dungeonId].minimumLevel;
    }

    function getDungeonLootProbability(uint dungeonId, uint wearableId) public view returns(uint)
    {
        return dungeons[dungeonId].lootProbability[wearableId];
    }

    // Owner functions

    function setDungeonDuration(uint dungeonId, uint duration) public onlyOwner {
        dungeons[dungeonId].duration = duration;
    }

    function setMinimumLevel(uint dungeonId, uint minimumLevel) public onlyOwner {
        dungeons[dungeonId].minimumLevel = minimumLevel;
    }

    function setDungeonLootProbability(uint dungeonId, uint wearableId, uint probability) public onlyOwner {
        dungeons[dungeonId].lootProbability[wearableId] = probability;
    }

    function setWearablesAmount(uint amount) public onlyOwner {
        wearablesAmount = amount;
    }

    // Internal functions

    function getRandomNumber(uint modulus) internal returns(uint)
    {
        randomNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randomNonce))) % modulus;
    }
}