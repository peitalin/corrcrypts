//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./CorruptionCryptsGlobalState.sol";

abstract contract CorruptionCryptsContracts is Initializable, CorruptionCryptsGlobalState {

    function __CorruptionCryptsContracts_init() internal initializer {
        CorruptionCryptsGlobalState.__CorruptionCryptsGlobalState_init();
    }

    function setContracts(
        // address _legionAddress,
        // address _legionMetadataStoreAddress,
        address _randomizerAddress
    ) external onlyOwner {
        // appStorage.legion = ILegion(_legionAddress);
        // appStorage.legionMetadataStore = ILegionMetadataStore(_legionMetadataStoreAddress);
        appStorage.randomizer = IRandomizer(_randomizerAddress);
    }

    modifier contractsAreSet() {
        require(areContractsSet(), "CorruptionCrypts: Contracts aren't set");
        _;
    }

    function areContractsSet() public view returns(bool) {
        // return address(appStorage.legion) != address(0)
        //     && address(appStorage.legionMetadataStore) != address(0)
        //     && address(appStorage.randomizer) != address(0);
        return address(appStorage.randomizer) != address(0);
    }
}