//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vault} from "../../../contracts/Vault.sol";
import {ADMIN_ROLE, GUARDIAN_ROLE} from "../../../contracts/access/Roles.sol";
import {Test} from "forge-std/Test.sol";

contract VaultPausableTest is Test {
    Vault private sut;

    function setUp() public {
        sut = new Vault();
        sut.initialize("Vault", "V", address(0), 1_000 * 1e6);
    }

    function testGivenNonGuardianRoleWhenPauseThenRevertsWithError() public {
        address user = makeAddr("user");
        bytes4 errorSelector = bytes4(
            keccak256(
                "HierarchicalAccessControlUnauthorizedAccount(address,bytes32)"
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(errorSelector, user, GUARDIAN_ROLE)
        );

        vm.startPrank(user);
        sut.pause();
    }

    function testGivenAtLeastGuardianRoleWhenPauseThenPauses() public {
        address user = makeAddr("user");
        bytes32[] memory inputs = new bytes32[](3);
        inputs[0] = sut.DEFAULT_ADMIN_ROLE();
        inputs[1] = GUARDIAN_ROLE;
        inputs[2] = ADMIN_ROLE;

        for (uint8 i = 0; i < inputs.length; i++) {
            sut.grantRole(inputs[i], user);

            vm.startPrank(user);
            sut.pause();

            assertTrue(sut.paused());

            sut.grantRole(ADMIN_ROLE, user);
            sut.unpause();
        }
    }

    function testGivenNonAdminRoleWhenUnpauseThenRevertsWithError() public {
        address user = makeAddr("user");
        bytes4 errorSelector = bytes4(
            keccak256(
                "HierarchicalAccessControlUnauthorizedAccount(address,bytes32)"
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(errorSelector, user, ADMIN_ROLE)
        );

        vm.startPrank(user);
        sut.unpause();
    }

    function testGivenAtLeastAdminRoleWhenUnpauseThenUnpauses() public {
        address user = makeAddr("user");
        bytes32[] memory inputs = new bytes32[](3);
        inputs[0] = sut.DEFAULT_ADMIN_ROLE();
        inputs[2] = ADMIN_ROLE;

        for (uint8 i = 0; i < inputs.length; i++) {
            sut.grantRole(ADMIN_ROLE, user);
            sut.pause();

            sut.grantRole(inputs[i], user);

            vm.startPrank(user);
            sut.unpause();

            assertFalse(sut.paused());
        }
    }
}
