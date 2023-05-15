// SPDX-License-Identifier: MIT
pragma solidity  0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./BabeApparel.sol";

contract BabeRandomnessProtocol is Ownable {

    using Counters for Counters.Counter;
    enum CommitmentState {NotCommitted, Committed, Revealed, Slashed}
    BabeApparel public babeApparel;

    struct Randomness
    {
        bytes32 randomBytes;
        uint commitmentDeadline;
        uint revealDeadline;
        bool rewardIsClaimed;
        uint stakeAmount;
        address creator;
    }

    struct Commitment
    {
        address committer;
        bytes32 hashedValue;
        CommitmentState state;
    }

    Counters.Counter private randomnessIds;
    mapping(uint randomnessId => Randomness) public randomness;
    mapping(uint randomnessId => uint commitmentAmount) commitmentAmounts;
    mapping(uint randomnessId => mapping(uint commitmentId => Commitment commitment)) commitments;
    mapping(address generator => bool isAllowed) generators;

    constructor(address babeApparelAddress) {
        babeApparel = BabeApparel(babeApparelAddress);
        setGenerator(msg.sender, true);
    }

    // Public Functions

    function commit(uint randomnessId, bytes32 hashedValue) public payable {
        require(msg.value == randomness[randomnessId].stakeAmount, "Invalid stake amount");
        require(block.timestamp <= randomness[randomnessId].commitmentDeadline, "Can't commit at this moment.");
        commitments[randomnessId][commitmentAmounts[randomnessId]] = Commitment(msg.sender, hashedValue, CommitmentState.Committed);
        commitmentAmounts[randomnessId] += 1;
    }

    function sendViaCall(address payable _to, uint amount) public {
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        data;
        require(sent, "Failed to send Ether");
    }

    function reveal(uint randomnessId, uint commitmentId, bytes32 secretValue) public {
        require(block.timestamp > randomness[randomnessId].commitmentDeadline &&
            block.timestamp <= randomness[randomnessId].revealDeadline, "Can't reveal at this moment.");
        require(commitments[randomnessId][commitmentId].state == CommitmentState.Committed, "Hash is not commited");
        require(commitments[randomnessId][commitmentId].hashedValue == keccak256(abi.encodePacked(secretValue)), "Invalid secret value");

        commitments[randomnessId][commitmentId].state = CommitmentState.Revealed;

        randomness[randomnessId].randomBytes = randomness[randomnessId].randomBytes ^ secretValue;

        sendViaCall(
            payable(commitments[randomnessId][commitmentId].committer),
            randomness[randomnessId].stakeAmount
        );
    }

    function claimReward(uint randomnessId) public {
        require(!randomness[randomnessId].rewardIsClaimed, "Reward already claimed.");
        randomness[randomnessId].rewardIsClaimed = true;
        address winner = commitments[randomnessId][uint(getRandomness(randomnessId)) % commitmentAmounts[randomnessId]].committer;
        babeApparel.mint(winner, 1);
    }

    function getRandomness(uint randomnessId) public view returns(bytes32) {
        require(block.timestamp > randomness[randomnessId].revealDeadline,
            "Randomness not ready yet.");
        return randomness[randomnessId].randomBytes;
    }

    // Owner functions

    function setGenerator(address generator, bool value) public onlyOwner {
        generators[generator] = value;
    }

    // Generator functions

    modifier onlyGenerator() {
        require(generators[msg.sender], "Sender is not generator");
        _;
    }

    function generateRandomness(uint commitmentDeadline, uint revealDeadline, uint stakeAmount) public onlyGenerator {
        randomness[randomnessIds.current()] = Randomness(
            bytes32(0),
            commitmentDeadline,
            revealDeadline,
            false,
            stakeAmount,
            msg.sender
        );
        randomnessIds.increment();
    }

    function claimSlashedETH(uint randomnessId, uint commitmentId) public onlyGenerator {
        require(randomness[randomnessId].creator == msg.sender, "Only creator can claim slashed");
        require(block.timestamp > randomness[randomnessId].revealDeadline, "Slashing period has not happened yet");
        require(commitments[randomnessId][commitmentId].state == CommitmentState.Committed, "This commitment was not slashed");
        commitments[randomnessId][commitmentId].state = CommitmentState.Slashed;
        sendViaCall(
            payable(msg.sender),
            randomness[randomnessId].stakeAmount
        );
    }
}