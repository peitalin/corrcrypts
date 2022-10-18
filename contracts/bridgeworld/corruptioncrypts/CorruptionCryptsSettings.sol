//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./CorruptionCryptsContracts.sol";

abstract contract CorruptionCryptsSettings is Initializable, CorruptionCryptsContracts {

    function __CorruptionCryptsSettings_init() internal initializer {
        CorruptionCryptsContracts.__CorruptionCryptsContracts_init();
    }

}