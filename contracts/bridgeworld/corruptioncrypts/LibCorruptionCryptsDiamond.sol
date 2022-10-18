// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../shared/randomizer/IRandomizer.sol";
import "../legion/ILegion.sol";
import "../legionmetadatastore/ILegionMetadataStore.sol";
import "../treasuremetadatastore/ITreasureMetadataStore.sol";
import "../treasurefragment/ITreasureFragment.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

library LibCorruptionCryptsDiamond {
    struct AppStorage {
        IRandomizer randomizer;
        ILegion legion;
        ILegionMetadataStore legionMetadataStore;
        ITreasureFragment treasureFragment;
    }
}