//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VaultBaseTest} from "../VaultBase.t.sol";
import {VaultV2} from "./VaultV2.sol";
import {GUARDIAN_ROLE, STRATEGIST_ROLE} from "../../../../contracts/access/Roles.sol";

contract VaultProxyTest is VaultBaseTest {
    function testGivenNonAuthorizedRoleWhenUpgradeThenRevertsWithError()
        public
    {
        VaultV2 vaultV2 = new VaultV2();
        bytes4 errorSelector = bytes4(
            keccak256(
                "HierarchicalAccessControlUnauthorizedAccount(address,bytes32)"
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                vault.DEFAULT_ADMIN_ROLE()
            )
        );

        vm.startPrank(testUsers.alice);
        vault.upgradeToAndCall(address(vaultV2), "");
    }

    function testGivenNonAuthorizedRoleWhenUnlockUpgradeThenRevertsWithError()
        public
    {
        bytes4 errorSelector = bytes4(
            keccak256(
                "HierarchicalAccessControlUnauthorizedAccount(address,bytes32)"
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                STRATEGIST_ROLE
            )
        );

        vm.startPrank(testUsers.alice);
        vault.unlockUpgrade();
    }

    function testGivenNonAuthorizedRoleWhenLockUpgradeThenRevertsWithError()
        public
    {
        bytes4 errorSelector = bytes4(
            keccak256(
                "HierarchicalAccessControlUnauthorizedAccount(address,bytes32)"
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                GUARDIAN_ROLE
            )
        );

        vm.startPrank(testUsers.alice);
        vault.lockUpgrade();
    }

    function testGivenCooldownLockWhenUpgradeThenRevertsWithError() public {
        VaultV2 vaultV2 = new VaultV2();

        bytes4 errorSelector = bytes4(keccak256("UpgradeIsLocked(uint256)"));

        vm.expectRevert(
            abi.encodeWithSelector(errorSelector, vault.upgradeUnlocksAt())
        );

        vm.startPrank(deployer);
        vault.upgradeToAndCall(address(vaultV2), "");
    }

    function testGivenDefaultAdminRoleWhenUpgradeThenDoesNotRevert() public {
        VaultV2 vaultV2 = new VaultV2();

        vm.startPrank(deployer);
        vault.unlockUpgrade();
        skip(vault.upgradeUnlocksAt() + 10);

        vault.upgradeToAndCall(address(vaultV2), "");
    }

    function testGivenDefaultAdminRoleWhenUpgradeThenUpgrades() public {
        VaultV2 vaultV2 = new VaultV2();

        vm.startPrank(deployer);
        vault.unlockUpgrade();
        skip(vault.upgradeUnlocksAt() + 10);
        vault.upgradeToAndCall(address(vaultV2), "");

        string memory version = vaultV2.version();

        assertEq("v2", version);
    }
}
