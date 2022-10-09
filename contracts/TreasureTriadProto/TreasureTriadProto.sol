
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

import "./TreasureTriadCardStats.sol";
import "./ShittyRandom.sol";
import "./LegionDecks.sol";
import { TreasureTriadCardStats, CardStats, Affinity } from "./TreasureTriadCardStats.sol";


struct TreasureCard {
    string card_name;
    string tokenId;
    Player player;
}
struct GridCell {
    string card_name;
    string tokenId;
    Player player;
    Affinity cell_affinity;
}

// if reordering, update enum in tests as well. Typechain doesnt generate
enum Player {
    none,
    nature,
    all_class,
    range,
    fighter,
    spellcaster,
    seige,
    assassin,
    riverman,
    numeraire,
    common
}



contract TreasureTriadProto is Initializable {

    TreasureTriadCardStats public ttCardStats = new TreasureTriadCardStats();
    ShittyRandom public shittyRandom = new ShittyRandom();
    // LegionDecks public legionDecks = new LegionDecks();


    mapping(address => mapping(uint => CorruptionRecipe)) buildingsToRecipes;

    struct CorruptionRecipe {
        address building;
        uint recipeId;
        RecipeItem[] recipeItems;
    }

    struct RecipeItem {
        address nftAddress;
        uint tokenId;
        uint amount;
    }

    function addCorruptionRemovalRecipe(
        address buildingAddress,
        address recipeContract,
        bool dropDarkPrisms
    ) public {
    }

    function removeCorruption(
        address buildingAddress,
        uint recipeId,
        RecipeItem[] memory recipeItems
    ) public {
    }



    mapping(uint => mapping(uint => GridCell)) public grid;

    event NaturesInitialCells(uint8[2][]);
    event NaturesInitialAffinityCells(uint8[2][]);

    event CardStaked(uint, uint, string, Player);
    event GameEndingStats(int, int);
    event CardStatsAtCell(uint, uint, uint, uint, Affinity, uint, string);
    // struct CardStats {
    //     uint n;
    //     uint e;
    //     uint s;
    //     uint w;
    //     Affinity cell_affinity;
    //     uint tokenId;
    //     string card_name;
    // }

    address owner;
    GridCell public emptyCell;

    uint public gridRows;
    uint public gridCols;

    int public convertedCards;
    // convertedCards boost your base drop rate
    // e.g. [0 => 0%, 1 => +x%, 2 => +y%, 3 => z%]

    int public corruptedCellCount;
    // if corruption == 1, put legion in stasis for x hours
    // if corruption == 2, put legion in stasis for y hours


    function initialize(uint _gridSize) public initializer {

        require(2 < _gridSize && _gridSize < 5, "grid size must be 3x3 or 4x4");

        owner = msg.sender;
        gridRows = _gridSize;
        gridCols = _gridSize;
        emptyCell = GridCell({
            card_name: "",
            tokenId: "",
            player: Player.none,
            cell_affinity: Affinity.none
        });

        // initiate grid with empty cards
        for (uint i = 0; i < gridCols; i++) {
            for (uint j = 0; j < gridRows; j++) {
                grid[i][j] = emptyCell;
            }
        }
        // start by letting Nature place N cards randomly on the grid
        // naturePlacesInitialCards(3);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'only owner');
        _;
    }

    modifier withinGrid(uint _row, uint _col) {
        // gridRows and gridCols are lengths, not indexes
        // e.g. 3x3 grid => gridRows and gridCols is 3
        require(_row >= 0, "row must be >= 0");
        require(_row < gridRows, "row must be < gridRows");
        require(_col >= 0, "col must be >= 0");
        require(_col < gridCols, "col must be < gridCols");
        _;
    }

    modifier isEmptyCell(uint _row, uint _col) {
        require(_isEmptyCell(_row, _col), "Cell Occupied");
        _;
    }

    function _isEmptyCell(uint _row, uint _col) private view returns (bool) {
        GridCell memory cell = grid[_row][_col];
        return _cardExists(cell) ? false : true;
    }

    function _cellHasNoAffinity(uint _row, uint _col) private view returns (bool) {
        GridCell memory cell = grid[_row][_col];
        return cell.cell_affinity == Affinity.none ? true : false;
    }

    // GridCell => TreasureCard => CardStats
    function _cardExists(GridCell memory _c) private pure returns (bool) {
        return bytes(_c.card_name).length != 0;
    }

    function _cardStatsExists(CardStats memory _c) private pure returns (bool) {
        return bytes(_c.card_name).length != 0;
    }

    function getCardStatsAtCell(
        uint _row,
        uint _col
    ) withinGrid(_row, _col) public returns (CardStats memory) {

        GridCell memory current_cell = getGridCell(_row, _col);
        CardStats memory current_card = ttCardStats.getBaseCardStatsByName(current_cell.card_name);
        // augment with cell_affinity boosts
        uint affinity_boost = _getAffinityBoost(
            current_cell.cell_affinity,
            current_card.card_affinity,
            current_cell.player
        );

        CardStats memory c = CardStats({
            n: current_card.n + affinity_boost,
            e: current_card.e + affinity_boost,
            s: current_card.s + affinity_boost,
            w: current_card.w + affinity_boost,
            card_affinity: current_card.card_affinity,
            card_name: current_card.card_name,
            tokenId: current_card.tokenId
        });
        emit CardStatsAtCell(c.n, c.e, c.s, c.w, c.card_affinity, c.tokenId, c.card_name);
        return c;
    }

    function getGridCell(uint _row, uint _col) public view returns (GridCell memory) {
        return grid[_row][_col];
    }

    function _incrementConvertedCards(int _num_flips) private returns (int) {
        convertedCards += _num_flips;
        return convertedCards;
    }

    function getConvertedCards() public view returns (int) {
        return convertedCards;
    }

    function getCorruptedCard() public view returns (int) {
        return corruptedCellCount;
    }

    function _getAffinityBoost(
        Affinity current_cell_affinity,
        Affinity current_card_affinity,
        Player legion_class
    ) private view returns (uint) {

        uint affinity_boost = 0;
        Affinity[] memory l_affinities = ttCardStats.getLegionAffinities(legion_class);

        if (current_cell_affinity == current_card_affinity) {
            affinity_boost += 1;
        }

        if (l_affinities.length > 0) {
            for (uint i; i < l_affinities.length; i++) {
                if (current_cell_affinity == l_affinities[i]) {
                    affinity_boost += 1;
                }
            }
        }

        return affinity_boost;
    }


    ////////////////////////////////////
    // Initializing Nature's Card Picks
    ///////////////////////////////////

    function _naturePlacesCard(uint _row, uint _col) private returns (bool) {
        if (!_isEmptyCell(_row, _col)) {
            return false;
        } else {
            // Ideally randomizer has difficulty parameters so that when difficulty is low
            // more low-tier cards are selected, and vice versa when difficulty is high
            string[] memory randCards = ttCardStats.getCardNames();
            uint randInt = shittyRandom.requestRandomNumber(_row + _col) % randCards.length;
            string memory randCard = randCards[randInt];

            // update gridCell attributes
            grid[_row][_col].card_name = randCard;
            grid[_row][_col].player = Player.nature;
            return true;
        }
    }

    function naturePlacesInitialCards(uint _number) public onlyOwner() {
        uint i;
        uint totalCardsPlaced = 0;
        uint8[2][] memory sampledGridCells = shittyRandom.sampleRandomGridCellCoords(_number);

        while (totalCardsPlaced < _number) {

            uint randRow = sampledGridCells[i][0];
            uint randCol = sampledGridCells[i][1];

            if (_naturePlacesCard(randRow, randCol)) {
                totalCardsPlaced++;
                i++;
            }
            if (totalCardsPlaced == _number) {
                break;
            }
        }
        emit NaturesInitialCells(sampledGridCells);
    }

    function _naturePlacesAffinity(uint _row, uint _col) private returns (bool) {
        if (!_cellHasNoAffinity(_row, _col)) {
            return false;
        } else {
            Affinity[] memory affinities = ttCardStats.getAffinities();
            uint randInt = shittyRandom.requestRandomNumber(_row + _col) % affinities.length;
            Affinity randAffinity = affinities[randInt];
            grid[_row][_col].cell_affinity = randAffinity;
            return true;
        }
    }

    function naturePlacesInitialAffinities(uint _number) public onlyOwner() {

        uint i;
        uint totalAffinitiesPlaced = 0;
        uint8[2][] memory sampledGridCells = shittyRandom.sampleRandomGridCellCoords(_number);

        while (totalAffinitiesPlaced < _number) {

            uint randRow = sampledGridCells[i][0];
            uint randCol = sampledGridCells[i][1];

            if (_naturePlacesAffinity(randRow, randCol)) {
                totalAffinitiesPlaced++;
                i++;
            }
            if (totalAffinitiesPlaced == _number) {
                break;
            }
        }
        emit NaturesInitialAffinityCells(sampledGridCells);
    }

    //////////////////////////////
    // Treasure Triad Logic
    //////////////////////////////

    function stakeMultipleCardsAndFinishGame(
        uint[2][] memory _coords,
        string[] calldata _card_names,
        Player _player
    ) public returns (int, int) {

        require(_coords.length == _card_names.length, "coords.length must match card_names.length");
        require(_card_names.length < 4, "max cards to place is 3");

        for (uint i; i < _coords.length; i++) {

            string calldata _card_name = _card_names[i];
            uint _row = _coords[i][0];
            uint _col = _coords[i][1];

            stakeTreasureCard(_row, _col, _card_name, _player);
        }

        recalcCorruptedCells();
        /////// Complete the Quest ///////
        // finish quest segment 3

        // calculate drop rate boost
        // uint dropRateBoost = calculateDropRateBoost();
        // drop_treasure_fragments() with dropRateBoost% boost
        // release legion from contract

        // remove legionDeck
        // legionDecks.removeDeck(_legionId);

        emit GameEndingStats(convertedCards, corruptedCellCount);
        return (convertedCards, corruptedCellCount);
    }

    function calculateDropRateBoost() private view returns (uint) {
        // genesis legion boost
        // convertCards boost
        if (convertedCards == 0) {
            return 0;
        }
        if (convertedCards == 1) {
            return 1;
        }
        if (convertedCards == 2) {
            return 2;
        }
        if (convertedCards == 3) {
            return 3;
        } else {
            return 0;
        }
    }

    function stakeTreasureCard(
        uint _row,
        uint _col,
        string calldata _card_name,
        // uint calldata _tokenId
        Player _player
    ) withinGrid(_row, _col) isEmptyCell(_row, _col) public {

        // require(tokenId to be in user's "deck", "card was no it users deck")
        // A user stakes ~5 treausres for his deck when entering quests
        // he must own those treasures

        grid[_row][_col].card_name = _card_name;
        grid[_row][_col].player = _player; // player's legion
        _tryFlipCardOnTop(_row, _col, _player);
        _tryFlipCardOnBottom(_row, _col, _player);
        _tryFlipCardOnLeft(_row, _col, _player);
        _tryFlipCardOnRight(_row, _col, _player);
        recalcCorruptedCells();
        emit CardStaked(_row, _col, _card_name, _player);
    }

    // test purposes only, remove
    function stakeTreasureCardAsNature(
        uint _row,
        uint _col,
        string calldata _card_name
        // uint calldata _tokenId
    ) withinGrid(_row, _col) isEmptyCell(_row, _col) public {
        require(address(msg.sender) == owner, "owner only");
        grid[_row][_col].card_name = _card_name;
        grid[_row][_col].player = Player.nature;
        _tryFlipCardOnTop(_row, _col, Player.nature);
        _tryFlipCardOnBottom(_row, _col, Player.nature);
        _tryFlipCardOnLeft(_row, _col, Player.nature);
        _tryFlipCardOnRight(_row, _col, Player.nature);
        recalcCorruptedCells();
        emit CardStaked(_row, _col, _card_name, Player.nature);
    }

    function recalcCorruptedCells() public returns (int) {
        int corrupt_cell_count = 0;

        for (uint i; i < gridRows; i++) {
            for (uint j; j < gridCols; j++) {
                GridCell memory cell = getGridCell(i, j);
                if (cell.cell_affinity == Affinity.corruption) {
                    if (cell.player == Player.nature || cell.player == Player.none) {
                        corrupt_cell_count += 1;
                    }
                }
            }
        }

        corruptedCellCount = corrupt_cell_count;
        return corrupt_cell_count;
    }

    function getCorruptedCellCount() public view returns (int) {
        return corruptedCellCount;
    }

    // for testing purposes, make private
    function setCellWithAffinity(
        uint _row,
        uint _col,
        Affinity _affinity
    ) withinGrid(_row, _col) public {
        require(address(msg.sender) == owner, "owner only");
        grid[_row][_col].cell_affinity = _affinity;
    }

    function _tryFlipCardOnTop(
        uint _row,
        uint _col,
        Player _player
    ) private {
        // Try flip Card to the TOP
        if (_row >= 1) {
            // check for underflow issues (_row-1 = -1) with negative offsets
            CardStats memory current_card_stats = getCardStatsAtCell(_row, _col);
            CardStats memory card_top_stats = getCardStatsAtCell(_row-1, _col);

            if (_cardStatsExists(card_top_stats)) {
                // compare north of current card to south of card above
                if (current_card_stats.n > card_top_stats.s) {
                    // if score on staked card is bigger, flip the card to new player
                    grid[_row-1][_col].player = _player;

                    int card_flips = (_player == Player.nature) ? int(-1) : int(1);
                    _incrementConvertedCards(card_flips);
                }
            }
        }
    }

    function _tryFlipCardOnBottom(
        uint _row,
        uint _col,
        Player _player
    ) private {
        // check row with +1 offset is less than gridRows (within grid)
        if (_row+1 < gridRows) {

            CardStats memory current_card_stats = getCardStatsAtCell(_row, _col);
            CardStats memory card_bottom_stats = getCardStatsAtCell(_row+1, _col);

            if (_cardStatsExists(card_bottom_stats)) {
                // compare south of current card to north of card below
                if (current_card_stats.s > card_bottom_stats.n) {
                    grid[_row+1][_col].player = _player;

                    int card_flips = (_player == Player.nature) ? int(-1) : int(1);
                    _incrementConvertedCards(card_flips);
                }
            }
        }
    }

    function _tryFlipCardOnRight(
        uint _row,
        uint _col,
        Player _player
    ) private {
        // check col with +1 offset is less than gridCols (withinGrid)
        if (_col+1 < gridCols) {

            CardStats memory current_card_stats = getCardStatsAtCell(_row, _col);
            CardStats memory card_right_stats = getCardStatsAtCell(_row, _col+1);

            if (_cardStatsExists(card_right_stats)) {
                // compare east-side of current card to west-side of card on the right
                if (current_card_stats.e > card_right_stats.w) {
                    // if score on staked card is bigger, flip the card to new player
                    grid[_row][_col+1].player = _player;

                    int card_flips = (_player == Player.nature) ? int(-1) : int(1);
                    _incrementConvertedCards(card_flips);
                }
            }
        }
    }

    function _tryFlipCardOnLeft(
        uint _row,
        uint _col,
        Player _player
    ) private {
        // check for underflow issues (_col-1 = -1) with negative offsets
        if (_col >= 1) {

            CardStats memory current_card_stats = getCardStatsAtCell(_row, _col);
            CardStats memory card_left_stats = getCardStatsAtCell(_row, _col-1);

            if (_cardStatsExists(card_left_stats)) {
                // compare west-side of current card to east-side of card on the left
                if (current_card_stats.w > card_left_stats.e) {
                    grid[_row][_col-1].player = _player;

                    int card_flips = (_player == Player.nature) ? int(-1) : int(1);
                    _incrementConvertedCards(card_flips);
                }
            }
        }
    }

}


