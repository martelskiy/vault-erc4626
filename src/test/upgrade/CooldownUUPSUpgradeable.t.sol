//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CooldownUUPSUpgradeableImpl} from "./CooldownUUPSUpgradeableImpl.sol";
import {Test} from "forge-std/Test.sol";

contract CooldownUUPSUpgradeableTest is Test {
    CooldownUUPSUpgradeableImpl private sut;
    uint256 internal constant MOCKED_BLOCK_TIMESTAMP = 1700000000;

    function setUp() public {
        sut = new CooldownUUPSUpgradeableImpl();
        vm.warp(MOCKED_BLOCK_TIMESTAMP);
    }

    function testGivenMockedTimestampWhenInitializeIsCalledThenLocksUpgrade()
        public
    {
        sut.initialize();

        assertEq(
            sut.upgradeUnlocksAt(),
            MOCKED_BLOCK_TIMESTAMP + 100 * 365 days
        );
    }

    function testGivenMockedTimestampWhenUnlockUpgradeThenUpgradeLockUpdated()
        public
    {
        sut.initialize();

        sut.unlockUpgrade();

        assertEq(sut.upgradeUnlocksAt(), MOCKED_BLOCK_TIMESTAMP + 48 hours);
    }

    function testGivenMockedTimestampWhenLockUpgradeThenUpgradeLockUpdated()
        public
    {
        sut.initialize();
        uint256 mockedTimeStamp = 1500000000;

        vm.warp(mockedTimeStamp);
        sut.lockUpgrade();

        assertEq(sut.upgradeUnlocksAt(), mockedTimeStamp + 100 * 365 days);
    }
}
