
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";
import { CardStats, TreasureTriadCardStats } from "./TreasureTriadCardStats.sol";


// Legions choose 5~8 treasures to use in the puzzle
// higher constellation lvls => can take more treasures with your (your deck)
// allow whitelisted foreign items as treasures


contract LegionDecks is Initializable {

    TreasureTriadCardStats public ttCardStats = new TreasureTriadCardStats();

    address owner;
    string[] temp_deck;

    mapping(address => uint) ownersToLegionIds;
    // each address is associated with a legion
    mapping(uint => string[]) legionDecks;
    // each legion tokenId associated with a deck of treasure cards

    event AddedLegionDeck(uint, string[]);
    event RemovedLegionDeck(uint);

    constructor() {
        owner = msg.sender;
    }

    function getLegionDeck(uint _legionId) public view returns (string[] memory) {
        return legionDecks[_legionId];
    }

    function removeDeck(uint _legionId) public {
        // call this when quest is complete to reset the deck
        require(ownersToLegionIds[msg.sender] == _legionId, "sender cannot remove this legion's deck");

        delete legionDecks[_legionId];
        delete ownersToLegionIds[msg.sender];
        emit RemovedLegionDeck(_legionId);
    }

    function addDeck(uint _legionId, string[] memory _cardnames) public {

        require(legionDecks[_legionId].length == 0, "deck for legion already exists, remove first");
        uint max_deck_size = _getDeckLimitBasedOnConstellationLvl(_legionId);
        require(_cardnames.length <= max_deck_size, "incorrect number of cards");


        // check _cardnames or tokenIds all exist
        for (uint i; i < _cardnames.length; i++) {
            CardStats memory card_stats = ttCardStats.getBaseCardStatsByName(_cardnames[i]);
            if (_doesCardStatsExist(card_stats.card_name)) {
                temp_deck.push(card_stats.card_name);
            }
        }
        // require(temp_deck.length <= max_deck_size, "some cardnames were invalid");

        // if deck is fine, assign deck to legionId
        legionDecks[_legionId] = temp_deck;
        // then assign legionId to msg.sender
        ownersToLegionIds[msg.sender] = _legionId;

        emit AddedLegionDeck(_legionId, temp_deck);
        delete temp_deck;
    }

    function _getDeckLimitBasedOnConstellationLvl(uint _legionId) private view returns (uint) {
        // determine max_length using legion's constellation levels;
        uint max_deck_size = 5;
        console.log(_legionId);
        // uint constellation_lvl = 1;
        // uint constellation_lvl = getMetaDataLegion(_legionId).constellation_lvl;
        // if (constellation_lvl > 6) {
        //     max_deck_size += 1;
        // }
        // if (constellation_lvl > 4) {
        //     max_deck_size += 1;
        // }
        // if (constellation_lvl > 2) {
        //     max_deck_size += 1;
        // }
        return max_deck_size;
    }

    function _doesCardStatsExist(string memory card_name) private pure returns (bool) {
        return bytes(card_name).length != 0;
    }
}
