// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract TVLManageableUpgradeable is Initializable {
    uint256 internal _tvlCap;

    event TvlInitilized(uint256 tvlCap);
    event TvlCapUpdated(uint256 value);

    /* solhint-disable func-name-mixedcase */
    function __TVLManageable_init(uint256 tvlCap) internal onlyInitializing {
        _tvlCap = tvlCap;

        emit TvlInitilized(tvlCap);
    }

    function _updateTvlCap(uint256 tvlCap_) internal {
        _tvlCap = tvlCap_;
        emit TvlCapUpdated(_tvlCap);
    }

    function _removeTvlCap() internal {
        _updateTvlCap(type(uint256).max);
    }
}
