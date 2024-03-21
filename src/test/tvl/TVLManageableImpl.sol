//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TVLManageableUpgradeable} from "../../contracts/tvl/TVLManageableUpgradeable.sol";

contract TVLManageableImpl is TVLManageableUpgradeable {
    function initialize(uint256 tvlCap_) public initializer {
        __TVLManageable_init(tvlCap_);
    }

    function updateTvlCap(uint256 tvlCap_) external {
        _updateTvlCap(tvlCap_);
    }

    function removeTvlCap() external {
        _removeTvlCap();
    }

    function tvlCap() external view returns (uint256) {
        return _tvlCap;
    }
}
