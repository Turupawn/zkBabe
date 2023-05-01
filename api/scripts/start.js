var MAX_SUPPLY = 99999999

const CHARACTERS_ADDRESS = "0x24EF68753793b732972E83B67B70409D4049A487"
const WEARABLES_ADDRESS = "0x399Aef07480Da9391f1185b0a4dFA5d568ddA1BD"
const CHARACTER_EQUIPMENT_ADDRESS = "0x73AC4AcA67a75a92e6F303C35925d37f395094D0"
const metadataAPIURL = "https://dungeons.777blocks.com/api"

const PORT = 3005
const IS_REVEALED = true
const UNREVEALED_METADATA = {
  "name":"Unrevealed Character",
  "description":"???",
  "image":"http://134.209.33.178:3000/unrevealed/image.png",
  "attributes":[{"???":"???"}]
}

const fs = require('fs')
const express = require('express')
var cors = require('cors');
const Web3 = require('web3')
require('dotenv').config()
const charactersABI = require('../json_abi/Characters.json')
const wearablesABI = require('../json_abi/Wearables.json')
const characterEquipmentABI = require('../json_abi/CharacterEquipment.json')
const Contract = require('web3-eth-contract')
Contract.setProvider(process.env.RPC_URL)
const charactersContract = new Contract(charactersABI, CHARACTERS_ADDRESS)
const wearablesContract = new Contract(wearablesABI, WEARABLES_ADDRESS)
const characterEquipmentContract = new Contract(characterEquipmentABI, CHARACTER_EQUIPMENT_ADDRESS)
var images = require("images")

const app = express()
app.use(cors());

app.use(express.static('images'))
app.use('/unrevealed', express.static(__dirname + '/unrevealed'));

async function initAPI() {
  //MAX_SUPPLY = parseInt(await contract.methods.MAX_SUPPLY().call())
  console.log("MAX_SUPPLY is: " + MAX_SUPPLY)
  app.listen(PORT, () => {
    console.log(`Listening to port ${PORT}`)
  })
}

async function serveMetadataCharacters(res, nft_id) {
  var token_count = parseInt(await charactersContract.methods.totalSupply().call())
  let return_value = {}
  if(nft_id <= 0)
  {
    return_value = {error: "NFT ID must be greater than 1"}
  }
  else if(nft_id >= MAX_SUPPLY)
  {
    return_value = {error: "NFT ID must be lesser than max supply"}
  }else if (nft_id - 1 >= token_count)
  {
    return_value = {error: "NFT ID must be already minted"}
  }else
  {
    return_value = {
      "name":"Dungeon Crawler Character#" + nft_id,
      "description":"Playable character. Equip weapons, deafeat dungeons, loot more weapons.",
      "image": metadataAPIURL + "/charactersEquiped/" + nft_id + ".png",
      "attributes":[
        /*
        {"trait_type":"Fondos","value":"z"},
        */
      ]
    }
    //return_value = fs.readFileSync("./metadata/characters/" + nft_id).toString().trim()
  }
  res.send(return_value)
}

async function serveMetadataWearables(res, nft_id) {
  var token_count = parseInt(await wearablesContract.methods.totalSupply().call())
  var wearableType = parseInt(await wearablesContract.methods.getType(nft_id).call())
  let return_value = {}
  if(nft_id < 0)
  {
    return_value = {error: "NFT ID must be greater than 0"}
  }else if(nft_id >= MAX_SUPPLY)
  {
    return_value = {error: "NFT ID must be lesser than max supply"}
  }
  /*
  else if (nft_id >= token_count)
  {
    return_value = {error: "NFT ID must be already minted"}
  }
  */
  else
  {
    return_value = {
      "name":"Dungeon Crawler Weapon#" + nft_id,
      "description":"Equip this to your character to level up.",
      "image": metadataAPIURL + "/wearableTypes/" + wearableType + ".png",
      "attributes":[
        /*
        {"trait_type":"Fondos","value":"z"},
        */
      ]
    }
    //return_value = fs.readFileSync("./metadata/wearables/" + nft_id).toString().trim()
  }
  res.send(return_value)
}

app.get('/metadata/characters/:id', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  if(isNaN(req.params.id))//in not number
  {
    res.send(UNREVEALED_METADATA)    
  }
  else if(!IS_REVEALED)
  {
    res.send(
      )
  }else
  {
    serveMetadataCharacters(res, req.params.id)
  }
})

app.get('/metadata/wearables/:id', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  if(isNaN(req.params.id))//in not number
  {
    res.send(UNREVEALED_METADATA)    
  }
  else if(!IS_REVEALED)
  {
    res.send(
      )
  }else
  {
    serveMetadataWearables(res, req.params.id)
  }
})

async function updateMetadata(res, characterId) {
  var shieldEquipmentId = parseInt(await characterEquipmentContract.methods.getCharacterEquipment(characterId, "1").call());
  var weaponEquipmentId = parseInt(await characterEquipmentContract.methods.getCharacterEquipment(characterId, "2").call());

  // Reset uhm
  var characterTypeId = await charactersContract.methods.getCharacterType(characterId).call()
  mergeImages("./images/charactersTypes/" + characterTypeId + ".png",
  "./images/charactersTypes/" + characterTypeId + ".png",
  "./images/charactersEquiped/" + characterId + ".png")
  console.log(characterTypeId)
  console.log(characterTypeId)

  if(shieldEquipmentId != "0")
  {
    var wearableType = parseInt(await wearablesContract.methods.getType(shieldEquipmentId).call())
    mergeImages("./images/charactersTypes/" + characterTypeId + ".png",
      "./images/wearableTypes/" + wearableType + ".png",
      "./images/charactersEquiped/" + characterId + ".png")
  }
  if(weaponEquipmentId != "0")
  {
    var wearableType = parseInt(await wearablesContract.methods.getType(weaponEquipmentId).call())
    mergeImages("./images/charactersEquiped/" + characterId + ".png",
      "./images/wearableTypes/" + wearableType + ".png",
      "./images/charactersEquiped/" + characterId + ".png")
  }

  if(shieldEquipmentId)

  res.setHeader('Content-Type', 'application/json');
  res.send({result: "Updated stuff"})
}

async function mergeImages(imageA, imageB, destination) {
  images(imageA).
    draw(images(imageB), 0, 0).
    save(destination);
}

app.get('/update/:id', (req, res) => {
  updateMetadata(res, req.params.id)
})

initAPI()
