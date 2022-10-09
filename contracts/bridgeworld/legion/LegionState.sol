//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../../shared/AdminableUpgradeable.sol";
import "./ILegion.sol";
import "../legionmetadatastore/ILegionMetadataStore.sol";

abstract contract LegionState is Initializable, ILegion, AdminableUpgradeable, ERC721URIStorageUpgradeable {

    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter internal tokenIdCounter;

    ILegionMetadataStore public legionMetadataStore;

    function __LegionState_init() internal initializer {
        AdminableUpgradeable.__Adminable_init();
        ERC721URIStorageUpgradeable.__ERC721URIStorage_init();
        ERC721Upgradeable.__ERC721_init("LEGION", "LGN");

        // Start at 1.
        tokenIdCounter.increment();
    }
}