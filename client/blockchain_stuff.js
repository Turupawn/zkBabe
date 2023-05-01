const NETWORK_ID = 10

const METADA_API_URL = "https://dungeons.777blocks.com/api"

const CHARACTERS_ADDRESS = "0x24EF68753793b732972E83B67B70409D4049A487"
const CHARACTERS_ABI_PATH = "./json_abi/Characters.json"
var characters

const WEARABLES_ADDRESS = "0x399Aef07480Da9391f1185b0a4dFA5d568ddA1BD"
const WEARABLES_ABI_PATH = "./json_abi/Wearables.json"
var wearables

const CHARACTER_EQUIPMENT_ADDRESS = "0x73AC4AcA67a75a92e6F303C35925d37f395094D0"
const CHARACTER_EQUIPMENT_ABI_PATH = "./json_abi/CharacterEquipment.json"
var characterEquipment

const DUNGEONS_ADDRESS = "0xcBd7052a962fAd922AFf01D27B68A4DcA1EdA413"
const DUNGEONS_ABI_PATH = "./json_abi/Dungeons.json"
var dungeons

var accounts
var web3

// Game vars
mainCharacterId = null
currentDungeon = null
characterLevel = null
lootTimestamp = ""
currentTime = Math.round(Date.now() / 1000)

function readableTime(seconds) {
  if(seconds > 60*60)
  {
    return Math.ceil(seconds/60/60) + " hours"
  } else if (seconds > 60) {
    return Math.ceil(seconds/60) + " minutes"
  }
  return seconds + " seconds"
}

function metamaskReloadCallback() {
  window.ethereum.on('accountsChanged', (accounts) => {
    document.getElementById("web3_message").textContent="Se cambió el account, refrescando...";
    window.location.reload()
  })
  window.ethereum.on('networkChanged', (accounts) => {
    document.getElementById("web3_message").textContent="Se el network, refrescando...";
    window.location.reload()
  })
}

const getWeb3 = async () => {
  return new Promise((resolve, reject) => {
    if(document.readyState=="complete")
    {
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum)
        window.location.reload()
        resolve(web3)
      } else {
        reject("must install MetaMask")
        document.getElementById("web3_message").textContent="Error: Porfavor conéctate a Metamask";
      }
    }else
    {
      window.addEventListener("load", async () => {
        if (window.ethereum) {
          const web3 = new Web3(window.ethereum)
          resolve(web3)
        } else {
          reject("must install MetaMask")
          document.getElementById("web3_message").textContent="Error: Please install Metamask";
        }
      });
    }
  });
};

const getContract = async (web3, address, abi_path) => {
  const response = await fetch(abi_path);
  const data = await response.json();
  
  const netId = await web3.eth.net.getId();
  contract = new web3.eth.Contract(
    data,
    address
    );
  return contract
}

async function loadDapp() {
  metamaskReloadCallback()
  document.getElementById("web3_message").textContent="Please connect to Metamask"
  var awaitWeb3 = async function () {
    web3 = await getWeb3()
    web3.eth.net.getId((err, netId) => {
      if (netId == NETWORK_ID) {
        var awaitContract = async function () {
          characters = await getContract(web3, CHARACTERS_ADDRESS, CHARACTERS_ABI_PATH)
          wearables = await getContract(web3, WEARABLES_ADDRESS, WEARABLES_ABI_PATH)
          characterEquipment = await getContract(web3, CHARACTER_EQUIPMENT_ADDRESS, CHARACTER_EQUIPMENT_ABI_PATH)
          dungeons = await getContract(web3, DUNGEONS_ADDRESS, DUNGEONS_ABI_PATH)
          document.getElementById("web3_message").textContent="You are connected to Metamask"
          onContractInitCallback()
          web3.eth.getAccounts(function(err, _accounts){
            accounts = _accounts
            if (err != null)
            {
              console.error("An error occurred: "+err)
            } else if (accounts.length > 0)
            {
              onWalletConnectedCallback()
              document.getElementById("account_address").style.display = "block"
            } else
            {
              document.getElementById("connect_button").style.display = "block"
            }
          });
        };
        awaitContract();
      } else {
        document.getElementById("web3_message").textContent="Please connect to Optimism";
      }
    });
  };
  awaitWeb3();
}

async function connectWallet() {
  await window.ethereum.request({ method: "eth_requestAccounts" })
  accounts = await web3.eth.getAccounts()
  onWalletConnectedCallback()
}

loadDapp()

const onContractInitCallback = async () => {
}


function onCharacterDataRetieved(characterId, characterLevel, jsonMetadata)
{
  var characterIdElement = document.createElement("span");
  characterIdElement.innerHTML = "Character id: " + characterId
  var characterLevelElement = document.createElement("span");
  characterLevelElement.innerHTML = "Level: " + characterLevel
  var img = document.createElement("img");
  img.src = jsonMetadata["image"];
  img.setAttribute("style", "max-width: 250px;");

  let updateMetadataButton = document.createElement("button");
  updateMetadataButton.innerHTML = "Update metadata";
  updateMetadataButton.characterId = "" + characterId;
  updateMetadataButton.onclick = function (eventParam) {
    updateMetadata(eventParam.srcElement.characterId)
  };

  var div = document.getElementById("characterImages");
  div.appendChild(img);
  div.appendChild(document.createElement("br"));
  div.appendChild(characterIdElement);
  div.appendChild(document.createElement("br"));
  div.appendChild(characterLevelElement);
  div.appendChild(document.createElement("br"));
  div.appendChild(updateMetadataButton);
  div.appendChild(document.createElement("br"));
  div.setAttribute("style", "text-align:center");
}

function addCharacterImage(tokenId, characterLevel, tokenURI)
{
  fetch(tokenURI)
  .then(res => res.json())
  .then(out =>
    onCharacterDataRetieved(tokenId, characterLevel, out))
  .catch();
}

function onWearableDataRetieved(wearableId, wearableType, wearableLevel, jsonMetadata)
{
  var wearableIdElement = document.createElement("span");
  wearableIdElement.innerHTML = "Wearable id: " + wearableId
  var wearableLevelElement = document.createElement("span");
  wearableLevelElement.innerHTML = "Level: " + wearableLevel
  var img = document.createElement("img");
  img.src = jsonMetadata["image"];
  img.setAttribute("style", "max-width: 250px;");

  let approveButton = document.createElement("button");
  approveButton.innerHTML = "Approve";
  approveButton.wearableId = "" + wearableId;
  approveButton.onclick = function (eventParam) {
    approve(eventParam.srcElement.wearableId)
  };

  let equipButton = document.createElement("button");
  equipButton.innerHTML = "Equip";
  equipButton.wearableId = "" + wearableId;
  equipButton.onclick = function (eventParam) {
    equip(eventParam.srcElement.wearableId)
  };

  var div = document.getElementById("wearableImages");
  div.appendChild(img);
  div.appendChild(document.createElement("br"));
  div.appendChild(wearableIdElement);
  div.appendChild(document.createElement("br"));
  div.appendChild(wearableLevelElement);
  div.appendChild(document.createElement("br"));
  div.appendChild(approveButton);
  div.appendChild(equipButton);
  div.appendChild(document.createElement("br"));
  div.setAttribute("style", "text-align:center");
}

function addWearableImage(wearableId, wearableType, wearableLevel, tokenURI)
{
  fetch(tokenURI)
  .then(res => res.json())
  .then(out =>
    onWearableDataRetieved(wearableId, wearableType, wearableLevel, out))
  .catch();
}

const onWalletConnectedCallback = async () => {
  accountCharacterBalance = await characters.methods.balanceOf(accounts[0]).call()

  if(accountCharacterBalance <= 0)
  {
    document.getElementById("characterStatusElement").textContent = "You must be whitelisted to mint your first character.";
    
    accountIsWhitelisted = await characters.methods.whitelist(accounts[0]).call()
    if(accountIsWhitelisted)
    {
      document.getElementById("mintElement").style.display = "block";
    }
  } else
  {
    document.getElementById("gameElement").style.display = "block";
    accountWearableBalance = await wearables.methods.balanceOf(accounts[0]).call()

    mainCharacterId = await characters.methods.tokenOfOwnerByIndex(accounts[0], 0).call()
    
    accountCharacters = []
    accountCharactersURI = []
    for(i=0; i<accountCharacterBalance; i++)
    {
      let tokenId  = await characters.methods.tokenOfOwnerByIndex(accounts[0], i).call()
      let tokenURI = await characters.methods.tokenURI(tokenId).call()
      let characterLevel = await characterEquipment.methods.getCharacterLevel(tokenId, "2").call()
      accountCharacters.push(tokenId)
      accountCharactersURI.push(tokenURI)
      addCharacterImage(tokenId, characterLevel, tokenURI)
    }

    let registration = await dungeons.methods.registration(accountCharacters[0]).call()
    characterStatus = ""
    if(registration.dungeonId != "0")
    {
      currentDungeon = registration.dungeonId
      lootTimestamp = registration.advanceTimestamp
      characterStatus = "Your character is currently at dungeon #"+ registration.dungeonId + ". "
      if(currentTime > lootTimestamp)
      {
        characterStatus += "Go loot now!"
      } else
      {
        characterStatus += "Come back in " + readableTime(lootTimestamp - currentTime)
      }

    } else
    {
      characterStatus = "Your character is ready to enter a dungeon."
    }
    document.getElementById("characterStatusElement").textContent = characterStatus;

    let characterLevel = await characterEquipment.methods.getCharacterLevel(mainCharacterId, "2").call()
    characterLevel = characterLevel

    accountWearables = []
    accountWearablesURI = []
    for(i=0; i<accountWearableBalance; i++)
    {
      let tokenId  = await wearables.methods.tokenOfOwnerByIndex(accounts[0], i).call()
      let tokenURI = await wearables.methods.tokenURI(tokenId).call()
      let wearableType = await wearables.methods.getType(tokenId).call()
      let wearableLevel = await wearables.methods.getLevel(tokenId).call()
      accountWearables.push(tokenId)
      accountWearablesURI.push(tokenURI)
      addWearableImage(tokenId, wearableType, wearableLevel, tokenURI)
    }


    for(dungeonId=1; dungeonId<=4; dungeonId+=1)
    {
      dungeon = await dungeons.methods.dungeons(dungeonId).call()
      let dungeonLevel = dungeon[1]
      if(characterLevel && parseInt(dungeonLevel) <= parseInt(characterLevel))
      {
        let dungeonDuration = readableTime(dungeon[0])

        const dungeonText = document.createTextNode(
          "Dungeon #" + dungeonId +
          " | Duration: " + dungeonDuration +
          " | Minimum level: " + dungeonLevel
        );
        var dungeonsElement = document.getElementById("dungeonsElement");
        var dungeonImage = document.createElement("img");
        dungeonImage.src = "/img/dungeons/" + dungeonId + ".png";
        dungeonImage.height = "250";
        dungeonsElement.appendChild(dungeonText);
        dungeonsElement.appendChild(document.createElement("br"));
        dungeonsElement.appendChild(dungeonImage);
        dungeonsElement.appendChild(document.createElement("br"));
      
        /*
        probabilities = ""
        for(wearableId=1; wearableId<=8; wearableId++)
        {
          probability = await dungeons.methods.getDungeonLootProbability(dungeonId, wearableId).call()
          if(probability != 0)
          {
            probabilities += " wearable " + wearableId + " " + probability/100 + "%,"
          }
        }
        const dungeonProbabilitiesText = document.createTextNode(
          probabilities
        );
        dungeonsElement.appendChild(dungeonProbabilitiesText);
        */
        if(!currentDungeon)
        {
          let enterDungeonButton = document.createElement("button");
          enterDungeonButton.innerHTML = "Enter Dungeon";
          enterDungeonButton.dungeonId = "" + dungeonId;
          enterDungeonButton.onclick = function (eventParam) {
            enterDungeon(mainCharacterId, eventParam.srcElement.dungeonId)
          };
          dungeonsElement.appendChild(enterDungeonButton);
        }
        if(dungeonId == currentDungeon && currentTime > lootTimestamp)
        {        
          let lootButton = document.createElement("button");
          lootButton.innerHTML = "Loot";
          lootButton.onclick = function () {
            loot(mainCharacterId)
          };
          dungeonsElement.appendChild(lootButton);
        }

        dungeonsElement.appendChild(document.createElement("br"));
        dungeonsElement.appendChild(document.createElement("br"));
      }
    }
  }
}

//// Functions ////

const approve = async (wearableId) => {
  const result = await wearables.methods.approve(CHARACTER_EQUIPMENT_ADDRESS, wearableId)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Confirming...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Refreshing now...";
    window.location.reload()
  })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}

const mintCharacter = async (wearableId) => {
  const result = await characters.methods.mint(accounts[0])
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Confirming...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Refreshing now...";
    window.location.reload()
  })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}

const enterDungeon = async (characterId, dungeonId) => {
  const result = await dungeons.methods.enterDungeon(characterId, dungeonId)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Confirming...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Refreshing now...";
    window.location.reload()
  })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}

const loot = async (characterId) => {
  const result = await dungeons.methods.loot(characterId)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Confirming...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Refreshing now...";
    window.location.reload()
  })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}

const equip = async (wearableId) => {
  const result = await characterEquipment.methods.equip(mainCharacterId, wearableId)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Confirming...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Refreshing now...";
    updateMetadata(mainCharacterId)
  })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}

const unequip = async (wearableType) => {
  const result = await characterEquipment.methods.unequip(mainCharacterId, wearableType)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Confirming...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Refreshing now...";
    updateMetadata(mainCharacterId)
  })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}

const setWhitelist = async (whitelistAccounts) => {
  const result = await characters.methods.setWhitelist(whitelistAccounts)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Confirming...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success! Refreshing now...";
    window.location.reload()
  })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}

const updateMetadata = async (characterId) => {
  fetch(METADA_API_URL + "/update/" + characterId)
  .then(res => res.json())
  .then(out =>
    window.location.reload())
  .catch();
}