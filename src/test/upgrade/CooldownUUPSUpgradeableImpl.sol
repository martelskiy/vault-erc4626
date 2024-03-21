//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CooldownUUPSUpgradeable} from "../../contracts/upgrade/CooldownUUPSUpgradeable.sol";

contract CooldownUUPSUpgradeableImpl is CooldownUUPSUpgradeable {
    /* solhint-disable no-empty-blocks */
    function initialize() public initializer {
        __CooldownUUPSUpgradeable_init();
    }

    function _authorizeUpgrade() internal override {}

    function unlockUpgrade() external {
        _unlockUpgrade();
    }

    function lockUpgrade() external {
        _lockUpgrade();
    }
}
