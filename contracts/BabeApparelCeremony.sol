// SPDX-License-Identifier: MIT
pragma solidity  0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./BabeApparel.sol";
import "./RandomnessCeremonyProtocol.sol";

contract BabeApparelCeremony is Ownable {
    RandomnessCeremonyProtocol randomnessCeremonyProtocol;
    BabeApparel babeApparel;

    struct BabeCeremony {
        uint randomnessId;
        bool isClaimed;
        uint ticketCount;
    }

    mapping(uint babeCeremonyId => BabeCeremony) babeCeremonies;
    uint babeCeremoniesCount;
    mapping(uint ceremonyId => mapping(uint ticketId => address ticketOwner)) tickets;

    constructor(address randomnessCeremonyProtocolAddress, address babeApparelAddress) {
        randomnessCeremonyProtocol = RandomnessCeremonyProtocol(payable(randomnessCeremonyProtocolAddress));
        babeApparel = BabeApparel(payable(babeApparelAddress));
    }

    function createBabeApparelCeremony(uint commitmentDeadline, uint revealDeadline, uint stakeAmount) public {
        uint randomnessId = randomnessCeremonyProtocol.generateRandomness(commitmentDeadline, revealDeadline, stakeAmount);
        babeCeremonies[babeCeremoniesCount] = BabeCeremony(
            randomnessId,
            false,
            0
        );
    }

    function commit(uint babeCeremonyId, bytes32 hashedValue) public payable {
        randomnessCeremonyProtocol.commit{value:msg.value}(babeCeremonies[babeCeremonyId].randomnessId, hashedValue);
        tickets[babeCeremonyId][babeCeremonies[babeCeremonyId].ticketCount] = msg.sender;
        babeCeremonies[babeCeremonyId].ticketCount += 1;
    }

    function reveal(uint babeCeremonyId, bytes32 hashedValue, bytes32 secretValue) public /** TODO Reentrancy */ {
        randomnessCeremonyProtocol.reveal(babeCeremonies[babeCeremonyId].randomnessId, hashedValue, secretValue);
    }

    function claimSlashedETH(uint randomnessId, bytes32 hashedValue) public /** Slashed eth nao wat */  {
        randomnessCeremonyProtocol.claimSlashedETH(randomnessId, hashedValue);
    }

    function claim(uint ceremonyId) public {
        require(!babeCeremonies[ceremonyId].isClaimed, "Already claimed");
        babeCeremonies[ceremonyId].isClaimed = true;
        uint randomness = uint(randomnessCeremonyProtocol.getRandomness(ceremonyId));
        uint randomTicket = randomness % babeCeremonies[ceremonyId].ticketCount;
        address winner = tickets[ceremonyId][randomTicket];
        babeApparel.mint(winner, 1);
    }

    fallback() external payable {
    }

    receive() external payable {
    }
}
