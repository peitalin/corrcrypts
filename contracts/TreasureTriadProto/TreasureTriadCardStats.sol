//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import { TreasureCard, Player } from "./TreasureTriadProto.sol";

struct CardStats {
    uint n;
    uint e;
    uint s;
    uint w;
    Affinity card_affinity;
    uint tokenId;
    string card_name;
}
// north, east, south, west

// if reordering, update enum in tests as well. Typechain doesnt generate
enum Affinity {
    none,
    alchemy,
    arcana,
    brewing,
    enchanting,
    leather_working,
    smithing,
    corruption
}



contract TreasureTriadCardStats {

    mapping(string => CardStats) cards;
    mapping(uint => CardStats) cardsByTokenId;

    mapping(Player => Affinity[]) legionAffinities;

    Affinity[] legionAffinityKeys;
    string[] cardNames;
    uint[] cardTokenIds;
    address owner;

    event AddedNewCard(CardStats);
    event SetLegionAffinity(Player, Affinity[]);

    constructor() {

        owner = msg.sender;

        // Find a way to store/get this data from IPFS

        _setInitialLegionAffinities();

        _addInitialManyCards([
            CardStats({
                n: 2,
                e: 8,
                s: 8,
                w: 4,
                card_affinity: Affinity.leather_working,
                card_name: 'honeycomb',
                tokenId: 97
            }),
            CardStats({
                n: 8,
                e: 2,
                s: 8,
                w: 2,
                card_affinity: Affinity.arcana,
                card_name: 'grin',
                tokenId: 95
            }),
            CardStats({
                n: 4,
                e: 2,
                s: 7,
                w: 7,
                card_affinity: Affinity.enchanting,
                card_name: 'bottomless elixer',
                tokenId: 51
            }),
            CardStats({
                n: 2,
                e: 8,
                s: 5,
                w: 3,
                card_affinity: Affinity.smithing,
                card_name: 'cap of invisibility',
                tokenId: 52
            }),
            CardStats({
                n: 7,
                e: 7,
                s: 5,
                w: 3,
                card_affinity: Affinity.brewing,
                card_name: 'ancient relic',
                tokenId: 39
            }),
            CardStats({
                n: 3,
                e: 6,
                s: 5,
                w: 7,
                card_affinity: Affinity.alchemy,
                card_name: 'castle',
                tokenId: 54
            }),
            // T2
            CardStats({
                n: 7,
                e: 5,
                s: 3,
                w: 4,
                card_affinity: Affinity.arcana,
                card_name: 'thread of divine silk',
                tokenId: 161
            }),
            CardStats({
                n: 5,
                e: 6,
                s: 5,
                w: 6,
                card_affinity: Affinity.enchanting,
                card_name: 'immovable stone',
                tokenId: 98
            }),
            CardStats({
                n: 6,
                e: 2,
                s: 7,
                w: 3,
                card_affinity: Affinity.enchanting,
                card_name: 'snow white feather',
                tokenId:153
            }),
            CardStats({
                n: 3,
                e: 7,
                s: 3,
                w: 6,
                card_affinity: Affinity.alchemy,
                card_name: 'ivory breast pin',
                tokenId: 99
            }),
            CardStats({
                n: 7,
                e: 4,
                s: 4,
                w: 4,
                card_affinity: Affinity.smithing,
                card_name: 'military stipend',
                tokenId: 104
            }),
            CardStats({
                n: 7,
                e: 3,
                s: 6,
                w: 1,
                card_affinity: Affinity.brewing,
                card_name: 'bait for monsters',
                tokenId:47
            }),
            CardStats({
                n: 1,
                e: 6,
                s: 4,
                w: 7,
                card_affinity: Affinity.leather_working,
                card_name: 'mollusk shell',
                tokenId: 105
            }),
            CardStats({
                n: 2,
                e: 7,
                s: 6,
                w: 3,
                card_affinity: Affinity.brewing,
                card_name: 'red feather',
                tokenId: 132
            }),
            CardStats({
                n: 4,
                e: 6,
                s: 2,
                w: 7,
                card_affinity: Affinity.arcana,
                card_name: 'divine hourglass',
                tokenId: 74
            }),
            CardStats({
                n: 6,
                e: 5,
                s: 6,
                w: 5,
                card_affinity: Affinity.leather_working,
                card_name: 'bag of mushrooms',
                tokenId: 46
            }),
            CardStats({
                n: 2,
                e: 3,
                s: 6,
                w: 7,
                card_affinity: Affinity.smithing,
                card_name: 'carriage',
                tokenId: 53
            }),
            // T3
            CardStats({
                n: 7,
                e: 2,
                s: 3,
                w: 5,
                card_affinity: Affinity.leather_working,
                card_name: 'small bird',
                tokenId: 152
            }),
            CardStats({
                n: 6,
                e: 2,
                s: 6,
                w: 3,
                card_affinity: Affinity.arcana,
                card_name: 'unbreakable pocketwatch',
                tokenId: 162
            }),
            CardStats({
                n: 4,
                e: 4,
                s: 7,
                w: 2,
                card_affinity: Affinity.leather_working,
                card_name: 'cow',
                tokenId: 72
            }),
            CardStats({
                n: 5,
                e: 6,
                s: 5,
                w: 3,
                card_affinity: Affinity.arcana,
                card_name: 'divine mask',
                tokenId:75
            }),
            CardStats({
                n: 5,
                e: 6,
                s: 3,
                w: 5,
                card_affinity: Affinity.brewing,
                card_name: 'favor from the gods',
                tokenId: 82
            }),
            CardStats({
                n: 7,
                e: 1,
                s: 5,
                w: 2,
                card_affinity: Affinity.alchemy,
                card_name: 'score of ivory',
                tokenId: 99
            }),
            CardStats({
                n: 7,
                e: 5,
                s: 3,
                w: 1,
                card_affinity: Affinity.enchanting,
                card_name: 'framed butterfly',
                tokenId: 91
            }),
            CardStats({
                n: 4,
                e: 5,
                s: 5,
                w: 5,
                card_affinity: Affinity.smithing,
                card_name: 'pot of gold',
                tokenId: 116
            }),
            CardStats({
                n: 1,
                e: 2,
                s: 6,
                w: 6,
                card_affinity: Affinity.alchemy,
                card_name: 'common bead',
                tokenId: 68
            }),
            CardStats({
                n: 6,
                e: 6,
                s: 3,
                w: 2,
                card_affinity: Affinity.enchanting,
                card_name: 'jar of fairies',
                tokenId: 100
            }),
            // T4
            CardStats({
                n: 4,
                e: 4,
                s: 5,
                w: 2,
                card_affinity: Affinity.brewing,
                card_name: 'witches broom',
                tokenId: 164
            }),
            CardStats({
                n: 5,
                e: 2,
                s: 5,
                w: 3,
                card_affinity: Affinity.alchemy,
                card_name: 'green rupee',
                tokenId: 94
            }),
            CardStats({
                n: 5,
                e: 1,
                s: 3,
                w: 5,
                card_affinity: Affinity.smithing,
                card_name: 'lumber',
                tokenId: 103
            }),
            CardStats({
                n: 5,
                e: 5,
                s: 4,
                w: 3,
                card_affinity: Affinity.smithing,
                card_name:  'ox',
                tokenId: 114
            }),
            CardStats({
                n: 5,
                e: 5,
                s: 5,
                w: 5,
                card_affinity: Affinity.leather_working,
                card_name: 'donkey',
                tokenId:76
            }),
            CardStats({
                n: 6,
                e: 1,
                s: 4,
                w: 3,
                card_affinity: Affinity.enchanting,
                card_name: 'common feather',
                tokenId:69
            }),
            CardStats({
                n: 5,
                e: 3,
                s: 3,
                w: 4,
                card_affinity: Affinity.brewing,
                card_name: 'grain',
                tokenId:93
            }),
            CardStats({
                n: 6,
                e: 2,
                s: 2,
                w: 3,
                card_affinity: Affinity.arcana,
                card_name: 'common relic',
                tokenId:71
            }),
            CardStats({
                n: 6,
                e: 3,
                s: 1,
                w: 3,
                card_affinity: Affinity.enchanting,
                card_name: 'blue rupee',
                tokenId:49
            }),
            // T5
            CardStats({
                n: 4,
                e: 2,
                s: 4,
                w: 3,
                card_affinity: Affinity.leather_working,
                card_name: 'half penny',
                tokenId:96
            }),
            CardStats({
                n: 2,
                e: 1,
                s: 6,
                w: 1,
                card_affinity: Affinity.alchemy,
                card_name: 'diamond',
                tokenId:73
            }),
            CardStats({
                n: 3,
                e: 5,
                s: 2,
                w: 1,
                card_affinity: Affinity.brewing,
                card_name: 'dragon tail',
                tokenId:77
            }),
            CardStats({
                n: 1,
                e: 5,
                s: 4,
                w: 1,
                card_affinity: Affinity.smithing,
                card_name: 'gold coin',
                tokenId:92
            }),
            CardStats({
                n: 2,
                e: 1,
                s: 4,
                w: 4,
                card_affinity: Affinity.brewing,
                card_name: 'beetle wings',
                tokenId:48
            }),
            CardStats({
                n: 2,
                e: 3,
                s: 1,
                w: 5,
                card_affinity: Affinity.enchanting,
                card_name: 'silver coin',
                tokenId:151
            }),
            CardStats({
                n: 6,
                e: 1,
                s: 1,
                w: 2,
                card_affinity: Affinity.arcana,
                card_name: 'pearl',
                tokenId:115
            }),
            CardStats({
                n: 1,
                e: 3,
                s: 3,
                w: 5,
                card_affinity: Affinity.smithing,
                card_name: 'red rupee',
                tokenId:133
            }),
            CardStats({
                n: 5,
                e: 1,
                s: 1,
                w: 3,
                card_affinity: Affinity.alchemy,
                card_name: 'emerald',
                tokenId:79
            }),
            CardStats({
                n: 1,
                e: 4,
                s: 1,
                w: 5,
                card_affinity: Affinity.leather_working,
                card_name: 'quarter penny',
                tokenId: 117
            }),
            CardStats({
                n: 0,
                e: 0,
                s: 0,
                w: 0,
                card_affinity: Affinity.none,
                tokenId: 0,
                card_name: ""
            })
        ]);

    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'only owner');
        _;
    }

    function getBaseCardStatsByName(string calldata _card_name) public view returns (CardStats memory) {
        return cards[_card_name];
    }

    function getBaseCardStatsByTokenId(uint _tokenId) public view returns (CardStats memory) {
        return cardsByTokenId[_tokenId];
    }

    function _addInitialManyCards(CardStats[47] memory _arr) private {
        for (uint i; i < _arr.length; i++) {
            _addCard(_arr[i]);
        }
    }

    function _addCard(CardStats memory c) private returns (CardStats memory) {
        // convenience function for testing only;
        return addCard(c.card_name, c.n, c.e, c.s, c.w, c.card_affinity, c.tokenId);
    }

    function addCard(
        string memory _name,
        uint _n,
        uint _e,
        uint _s,
        uint _w,
        Affinity _aff,
        uint _tokenId
    ) public onlyOwner() returns (CardStats memory) {

        // allow overwrite of existing card entries
        // require(cards[_name].tokenId == 0, "_name clash");

        CardStats memory newCard = CardStats({
            n: _n,
            e: _e,
            s: _s,
            w: _w,
            card_affinity: _aff,
            tokenId: _tokenId,
            card_name: _name
        });

        cards[_name] = newCard;
        cardsByTokenId[_tokenId] = newCard;

        cardNames.push(_name);
        cardTokenIds.push(_tokenId);

        emit AddedNewCard(newCard);
        return newCard;
    }

    function removeCard(string calldata _name) public onlyOwner() {
        delete cards[_name];
    }

    function getCardNames() public view returns (string[] memory) {
        return cardNames;
    }

    function getCardTokenIds() public view returns (uint[] memory) {
        return cardTokenIds;
    }

    function getAffinities() public view returns (Affinity[] memory) {
        return legionAffinityKeys;
    }

    function getLegionAffinities(Player _legion_class) public view returns (Affinity[] memory) {
        return legionAffinities[_legion_class];
    }

    function setLegionAffinities(
        Player _legion_class,
        Affinity[] memory _affinities
    ) public onlyOwner() {
        // allow overwriting of entry
        legionAffinities[_legion_class] = _affinities;
        emit SetLegionAffinity(_legion_class, _affinities);
    }

    function _setInitialLegionAffinities() private {

        legionAffinityKeys = [
            Affinity.alchemy,
            Affinity.arcana,
            Affinity.brewing,
            Affinity.enchanting,
            Affinity.leather_working,
            Affinity.smithing
        ];

        legionAffinities[Player.all_class] = [
            Affinity.alchemy,
            Affinity.arcana,
            Affinity.brewing,
            Affinity.enchanting,
            Affinity.leather_working,
            Affinity.smithing
        ];

        legionAffinities[Player.range] = [
            Affinity.leather_working,
            Affinity.alchemy
        ];

        legionAffinities[Player.fighter] = [
            Affinity.smithing,
            Affinity.enchanting
        ];

        legionAffinities[Player.spellcaster] = [
            Affinity.arcana,
            Affinity.enchanting
        ];

        legionAffinities[Player.seige] = [
            Affinity.alchemy,
            Affinity.smithing
        ];

        legionAffinities[Player.assassin] = [
            Affinity.brewing,
            Affinity.leather_working
        ];

        legionAffinities[Player.numeraire] = [
            Affinity.arcana,
            Affinity.alchemy
        ];

        legionAffinities[Player.riverman] = [
            Affinity.brewing,
            Affinity.enchanting
        ];

        // setLegionAffinities(Player.common, Affinity[]);
    }

}



// legion_affinities = {
//     "all class": [
//         "alchemy",
//         "arcana",
//         "brewing",
//         "enchanting",
//         "leather working",
//         "smithing",
//     ],
//     "range": [
//         "leather working",
//         "alchemy",
//     ],
//     "fighter": [
//         "smithing",
//         "enchanting",
//     ],
//     "spellcaster": [
//         "arcana",
//         "enchanting",
//     ],
//     "seige": [
//         "alchemy",
//         "smithing",
//     ],
//     "assassin": [
//         "brewing",
//         "leather working",
//     ],
//     "numeraire": [
//         "arcana",
//     ],
//     "riverman": [
//         "brewing",
//     ],
//     "common": [
//     ],
// }


// CARDS = {
//     'gen0_1_1': { # tokenId ??
//         'n': 9,
//         'e': 7,
//         's': 9,
//         'w': 7,
//         'card_affinity': "legions",
//     },
//     'gen0_rare': { # tokenId ??
//         'n': 5,
//         'e': 8,
//         's': 5,
//         'w': 8,
//         'card_affinity': "legions",
//     },
//     'gen0_uncommon': { # tokenId ??
//         'n': 8,
//         'e': 8,
//         's': 2,
//         'w': 2,
//         'card_affinity': "legions",
//     },
//     'gen0_special': { # tokenId ??
//         'n': 7,
//         'e': 3,
//         's': 8,
//         'w': 5,
//         'card_affinity': "legions",
//     },
//     'gen0_common': { # tokenId ??
//         'n': 4,
//         'e': 3,
//         's': 8,
//         'w': 7,
//         'card_affinity': "legions",
//     },
//     # Aux Legions
//     'gen1_rare': { # tokenId ??
//         'n': 6,
//         'e': 7,
//         's': 2,
//         'w': 3,
//         'card_affinity': "legions",
//     },
//     'gen1_uncommon': { # tokenId ??
//         'n': 4,
//         'e': 2,
//         's': 5,
//         'w': 7,
//         'card_affinity': "legions",
//     },
//     'gen1_common': { # tokenId ??
//         'n': 5,
//         'e': 5,
//         's': 6,
//         'w': 6,
//         'card_affinity': "legions",
//     },

//     # T1
//     'honeycomb': { # tokenId 97
//         'n': 2,
//         'e': 8,
//         's': 8,
//         'w': 4,
//         'card_affinity': "leather working",
//     },
//     'grin': { # tokenId 95
//         'n': 8,
//         'e': 2,
//         's': 8,
//         'w': 2,
//         'card_affinity': "arcana",
//     },
//     'bottomless elixer': { # tokenId 51
//         'n': 4,
//         'e': 2,
//         's': 7,
//         'w': 7,
//         'card_affinity': "enchanting",
//     },
//     'cap of invisibility': { # tokenId 52
//         'n': 2,
//         'e': 8,
//         's': 5,
//         'w': 3,
//         'card_affinity': "smithing",
//     },
//     'ancient relic': { # tokenId 39
//         'n': 7,
//         'e': 7,
//         's': 5,
//         'w': 3,
//         'card_affinity': "brewing",
//     },
//     'castle': { # tokenId 54
//         'n': 3,
//         'e': 6,
//         's': 5,
//         'w': 7,
//         'card_affinity': "alchemy",
//     },
//     # T2
//     'thread of divine silk': { # tokenId 161
//         'n': 7,
//         'e': 5,
//         's': 3,
//         'w': 4,
//         'card_affinity': "arcana",
//     },
//     'immovable stone': { # tokenId 98
//         'n': 5,
//         'e': 6,
//         's': 5,
//         'w': 6,
//         'card_affinity': "enchanting",
//     },
//     'snow white feather': { # tokenId 153
//         'n': 6,
//         'e': 2,
//         's': 7,
//         'w': 3,
//         'card_affinity': "enchanting",
//     },
//     'ivory breast pin': { # tokenId 99
//         'n': 3,
//         'e': 7,
//         's': 3,
//         'w': 6,
//         'card_affinity': "alchemy",
//     },
//     'military stipend': { # tokenId 104
//         'n': 7,
//         'e': 4,
//         's': 4,
//         'w': 4,
//         'card_affinity': "smithing",
//     },
//     'bait for monsters': { # tokenId 47
//         'n': 7,
//         'e': 3,
//         's': 6,
//         'w': 1,
//         'card_affinity': "brewing",
//     },
//     'mollusk shell': { # tokenId 105
//         'n': 1,
//         'e': 6,
//         's': 4,
//         'w': 7,
//         'card_affinity': "leather working",
//     },
//     'red feather': { # tokenId 132
//         'n': 2,
//         'e': 7,
//         's': 6,
//         'w': 3,
//         'card_affinity': "brewing",
//     },
//     'divine hourglass': { # tokenId 74
//         'n': 4,
//         'e': 6,
//         's': 2,
//         'w': 7,
//         'card_affinity': "arcana",
//     },
//     'bag of mushrooms': { # tokenId 46
//         'n': 6,
//         'e': 5,
//         's': 6,
//         'w': 5,
//         'card_affinity': "leather working",
//     },
//     'carriage': { # tokenId 53
//         'n': 2,
//         'e': 3,
//         's': 6,
//         'w': 7,
//         'card_affinity': "smithing",
//     },
//     # T3
//     'small bird': { # tokenId 152
//         'n': 7,
//         'e': 2,
//         's': 3,
//         'w': 5,
//         'card_affinity': "leather working",
//     },
//     'unbreakable pocketwatch': { # tokenId 162
//         'n': 6,
//         'e': 2,
//         's': 6,
//         'w': 3,
//         'card_affinity': "arcana",
//     },
//     'cow': { # tokenId 72
//         'n': 4,
//         'e': 4,
//         's': 7,
//         'w': 2,
//         'card_affinity': "leather working",
//     },
//     'divine mask': { # tokenId 75
//         'n': 5,
//         'e': 6,
//         's': 5,
//         'w': 3,
//         'card_affinity': "arcana",
//     },
//     'favor from the gods': { # tokenId 82
//         'n': 5,
//         'e': 6,
//         's': 3,
//         'w': 5,
//         'card_affinity': "brewing",
//     },
//     'score of ivory': { # tokenId 99
//         'n': 7,
//         'e': 1,
//         's': 5,
//         'w': 2,
//         'card_affinity': "alchemy",
//     },
//     'framed butterfly': { # tokenId 91
//         'n': 7,
//         'e': 5,
//         's': 3,
//         'w': 1,
//         'card_affinity': "enchanting",
//     },
//     'pot of gold': { # tokenId 116
//         'n': 4,
//         'e': 5,
//         's': 5,
//         'w': 5,
//         'card_affinity': "smithing",
//     },
//     'common bead': { # tokenId 68
//         'n': 1,
//         'e': 2,
//         's': 6,
//         'w': 6,
//         'card_affinity': "alchemy",
//     },
//     'jar of fairies': { # tokenId 100
//         'n': 6,
//         'e': 6,
//         's': 3,
//         'w': 2,
//         'card_affinity': "enchanting",
//     },
//     # T4
//     'witches broom': { # tokenId 164
//         'n': 4,
//         'e': 4,
//         's': 5,
//         'w': 2,
//         'card_affinity': "brewing",
//     },
//     'green rupee': { # tokenId 94
//         'n': 5,
//         'e': 2,
//         's': 5,
//         'w': 3,
//         'card_affinity': "alchemy",
//     },
//     'lumber': { # tokenId 103
//         'n': 5,
//         'e': 1,
//         's': 3,
//         'w': 5,
//         'card_affinity': "smithing",
//     },
//     'ox': { # tokenId 114
//         'n': 5,
//         'e': 5,
//         's': 4,
//         'w': 3,
//         'card_affinity': "smithing",
//     },
//     'donkey': { # tokenId 76
//         'n': 5,
//         'e': 5,
//         's': 5,
//         'w': 5,
//         'card_affinity': "leather working",
//     },
//     'common feather': { # tokenId 69
//         'n': 6,
//         'e': 1,
//         's': 4,
//         'w': 3,
//         'card_affinity': "enchanting",
//     },
//     'grain': { # tokenId 93
//         'n': 5,
//         'e': 3,
//         's': 3,
//         'w': 4,
//         'card_affinity': "brewing",
//     },
//     'common relic': { # tokenId 71
//         'n': 6,
//         'e': 2,
//         's': 2,
//         'w': 3,
//         'card_affinity': "arcana",
//     },
//     'blue rupee': { # tokenId 49
//         'n': 6,
//         'e': 3,
//         's': 1,
//         'w': 3,
//         'card_affinity': "enchanting",
//     },
//     # T5
//     'half penny': { # tokenId 96
//         'n': 4,
//         'e': 2,
//         's': 4,
//         'w': 3,
//         'card_affinity': "leather working",
//     },
//     'diamond': { # tokenId 73
//         'n': 2,
//         'e': 1,
//         's': 6,
//         'w': 1,
//         'card_affinity': "alchemy",
//     },
//     'dragon tail': { # tokenId 77
//         'n': 3,
//         'e': 5,
//         's': 2,
//         'w': 1,
//         'card_affinity': "brewing",
//     },
//     'gold coin': { # tokenId 92
//         'n': 1,
//         'e': 5,
//         's': 4,
//         'w': 1,
//         'card_affinity': "smithing",
//     },
//     'beetle wings': { # tokenId 48
//         'n': 2,
//         'e': 1,
//         's': 4,
//         'w': 4,
//         'card_affinity': "brewing",
//     },
//     'silver coin': { # tokenId 151
//         'n': 2,
//         'e': 3,
//         's': 1,
//         'w': 5,
//         'card_affinity': "enchanting",
//     },
//     'pearl': { # tokenId 115
//         'n': 6,
//         'e': 1,
//         's': 1,
//         'w': 2,
//         'card_affinity': "arcana",
//     },
//     'red rupee': { # tokenId 133
//         'n': 1,
//         'e': 3,
//         's': 3,
//         'w': 5,
//         'card_affinity': "smithing",
//     },
//     'emerald': { # tokenId 79
//         'n': 5,
//         'e': 1,
//         's': 1,
//         'w': 3,
//         'card_affinity': "alchemy",
//     },
//     'quarter penny': { # tokenId 117
//         'n': 1,
//         'e': 4,
//         's': 1,
//         'w': 5,
//         'card_affinity': "leather working",
//     },
//     'none': {
//         'n': ' ',
//         'e': ' ',
//         's': ' ',
//         'w': ' ',
//         'card_affinity': "none",
//     },
// }