pragma solidity ^0.8.0;

import "foundry/lib/TestUtils.sol";
import "foundry/lib/Mock.sol";

// import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "contracts/bridgeworld/treasuretriad/TreasureTriad.sol";
import "contracts/bridgeworld/treasuremetadatastore/TreasureMetadataStore.sol";
import "contracts/shared/Adminable.sol";



contract TreasureTriadTest is TestUtils {

    struct TestCase {
        uint256 tokenId;
        uint256 amount;
        uint256 expectedBoost;
    }

    // enum TreasureCategory {
    //     ALCHEMY,
    //     ARCANA,
    //     BREWING,
    //     ENCHANTER,
    //     LEATHERWORKING,
    //     SMITHING
    // }

    // struct TreasureMetadata {
    //     TreasureCategory category;
    //     uint8 tier;
    //     // Out of 100,000
    //     uint32 craftingBreakOdds;
    //     bool isMintable;
    //     uint256 consumableIdDropWhenBreak;
    // }

    // workaround for "UnimplementedFeatureError: Copying of type struct memory to storage not yet supported."
    uint256 public constant testCasesLength = 1;

    TreasureTriad public treasureTriad;
    TreasureMetadataStore public treasureMetadataStore;
    Adminable public adminable;

    // address public admin;
    // address public nftHandler;
    uint256 public maxCards;

    address public adminP = address(1111);
    // mapping(address => uint256) public mockAmountStaked;

    event MaxCards(uint256 maxCards);

    function setUp() public {

        maxCards = 3;

        treasureTriad = TreasureTriad(address(new TreasureTriad()));
        treasureMetadataStore = TreasureMetadataStore(address(new TreasureMetadataStore()));
        adminable = Adminable(address(new Adminable()));

        adminable.addAdmin(adminP);

        uint256[] memory treasureIds = new uint256[](3);
        treasureIds[0] = 54;
        treasureIds[1] = 99;
        treasureIds[2] = 141;

        TreasureMetadata[] memory treasureMdata = new TreasureMetadata[](3);
        treasureMdata[0] = TreasureMetadata({
            tier: 1,
            category: TreasureCategory.ALCHEMY,
            craftingBreakOdds: 3274,
            isMintable: true,
            consumableIdDropWhenBreak: 0
        });
        treasureMdata[1] = TreasureMetadata({
            tier: 2,
            category: TreasureCategory.ALCHEMY,
            craftingBreakOdds: 6440,
            isMintable: true,
            consumableIdDropWhenBreak: 0
        });
        treasureMdata[2] = TreasureMetadata({
            tier: 3,
            category: TreasureCategory.ALCHEMY,
            craftingBreakOdds: 8203,
            isMintable: true,
            consumableIdDropWhenBreak: 0
        });

        vm.prank(adminP);
        treasureMetadataStore.setMetadataForIds(
            treasureIds,
            treasureMdata
        );

        // treasureTriad.initialize();
    }

    function getTestCase(uint256 _i) public pure returns (TestCase memory) {
        TestCase[testCasesLength] memory testCases = [
            TestCase(39, 1, 7.5e16)
        ];

        return testCases[_i];
    }

    function test_generateGameBoard() public {

        // GridCell[3][3] memory gridCell;
        // gridCell = treasureTriad.generateBoard(112901820398102938);

        uint a = 1;
        uint b = 1;
        assertEq(a, b);

        assertEq(adminable.isAdmin(adminP), true);

        // for (uint256 i = 0; i < testCasesLength; i++) {
        //     TestCase memory testCase = getTestCase(i);
            // assertEq(
            //     treasureRules.getUserBoost(address(0), address(0), testCase.tokenId, testCase.amount),
            //     testCase.expectedBoost
            // );
        // }
    }

    // function test_getTreasureBoost() public {
    //     for (uint256 i = 0; i < testCasesLength; i++) {
    //         TestCase memory testCase = getTestCase(i);

    //         assertEq(
    //             treasureRules.getTreasureBoost(testCase.tokenId, testCase.amount),
    //             testCase.expectedBoost
    //         );
    //     }
    // }


}
