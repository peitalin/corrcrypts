//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../shared/AdminableUpgradeable.sol";
import "./LibCorruptionCryptsDiamond.sol";


abstract contract CorruptionCryptsState is Initializable, AdminableUpgradeable {

    LibCorruptionCryptsDiamond.AppStorage internal appStorage;

    uint8 NUM_MAPTILES = 32;
    uint8 MAX_TILES_ON_BOARD = 5;

    uint8 MAX_LEGIONS_ON_TEMPLES_BEFORE_RESET = 2;
    // should be like 4000 in practice

    function __CorruptionCryptsState_init() internal initializer {
        AdminableUpgradeable.__Adminable_init();
    }

}
