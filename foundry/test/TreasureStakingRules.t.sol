pragma solidity ^0.8.0;

import "foundry/lib/TestUtils.sol";
import "foundry/lib/Mock.sol";

// import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "contracts/harvester/rules/TreasureStakingRules.sol";

contract TreasureStakingRulesTest is TestUtils {

    struct TestCase {
        uint256 tokenId;
        uint256 amount;
        uint256 expectedBoost;
    }

    // workaround for "UnimplementedFeatureError: Copying of type struct memory to storage not yet supported."
    uint256 public constant testCasesLength = 15;

    TreasureStakingRules public treasureRules;

    address public admin;
    address public nftHandler;
    uint256 public maxStakeablePerUser;
    mapping(address => uint256) public mockAmountStaked;

    event MaxStakeablePerUser(uint256 maxStakeablePerUser);

    function setUp() public {

        maxStakeablePerUser = 20;

        treasureRules = TreasureStakingRules(address(new TreasureStakingRules()));
        treasureRules.init(
            maxStakeablePerUser
        );
    }

    function getTestCase(uint256 _i) public pure returns (TestCase memory) {
        TestCase[testCasesLength] memory testCases = [
            // TODO: add more test cases
            TestCase(39, 1, 7.5e16),
            TestCase(39, 1, 75e15),
            TestCase(39, 5, 3.75e17),
            TestCase(48, 0, 0),
            TestCase(48, 1, 8e15),
            TestCase(48, 20, 1.6e17),
            TestCase(54, 0, 0),
            TestCase(54, 1, 7.1e16),
            TestCase(54, 20, 1.42e18),
            TestCase(97, 0, 0),
            TestCase(97, 1, 15.8e16),
            TestCase(97, 20, 3.16e18),
            TestCase(95, 0, 0),
            TestCase(95, 1, 15.7e16),
            TestCase(95, 20, 3.14e18)
        ];

        // if (_tokenId == 39) { // Ancient Relic 7.5%
        //     boost = 75e15;
        // } else if (_tokenId == 48) { // Beetle-wing 0.8%
        //     boost = 8e15;
        // } else if (_tokenId == 54) { // Castle 7.1%
        //     boost = 71e15;
        // } else if (_tokenId == 97) { // Honeycomb 15.8%
        //     boost = 158e15;
        // } else if (_tokenId == 95) { // Grin 15.7%
        //     boost = 157e15;
        // }

        return testCases[_i];
    }

    function test_getUserBoost() public {
        for (uint256 i = 0; i < testCasesLength; i++) {
            TestCase memory testCase = getTestCase(i);

            assertEq(
                treasureRules.getUserBoost(address(0), address(0), testCase.tokenId, testCase.amount),
                testCase.expectedBoost
            );
        }
    }

    function test_getTreasureBoost() public {
        for (uint256 i = 0; i < testCasesLength; i++) {
            TestCase memory testCase = getTestCase(i);

            assertEq(
                treasureRules.getTreasureBoost(testCase.tokenId, testCase.amount),
                testCase.expectedBoost
            );
        }
    }


}
