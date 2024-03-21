//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

abstract contract CooldownUUPSUpgradeable is UUPSUpgradeable {
    uint256 public upgradeUnlocksAt;
    uint256 public constant UPGRADE_TIMELOCK = 48 hours;

    uint256 public constant ONE_YEAR = 365 days;

    error UpgradeIsLocked(uint256 until);

    /* solhint-disable func-name-mixedcase */
    function __CooldownUUPSUpgradeable_init() internal onlyInitializing {
        __UUPSUpgradeable_init();
        _lockUpgrade();
    }

    /**
     * @dev This function must be called prior to upgrading the implementation.
     *      It's required to wait {upgradeUnlocksAt} seconds before executing the upgrade.
     */
    function _unlockUpgrade() internal {
        upgradeUnlocksAt = _now() + UPGRADE_TIMELOCK;
    }

    /**
     * @dev This function is called:
     *      - during initialization
     *      - as part of a successful upgrade
     *      - manually to lock the upgrade.
     */
    function _lockUpgrade() internal {
        upgradeUnlocksAt = _now() + (ONE_YEAR * 100);
    }

    /**
     * @dev This function must be overriden simply for access control purposes.
     *      Only authorized role can upgrade the implementation once the timelock
     *      has passed.
     */
    function _authorizeUpgrade(address) internal override {
        _authorizeUpgrade();
        if (!_timePassed(upgradeUnlocksAt)) {
            revert UpgradeIsLocked(upgradeUnlocksAt);
        }
        _lockUpgrade();
    }

    function _timePassed(uint256 time) private view returns (bool) {
        return time < _now();
    }

    function _now() private view returns (uint256) {
        return block.timestamp;
    }

    function _authorizeUpgrade() internal virtual;
}
