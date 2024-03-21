//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vault} from "../../../contracts/Vault.sol";
import {ADMIN_ROLE} from "../../../contracts/access/Roles.sol";
import {Test} from "forge-std/Test.sol";

contract VaultTVLTest is Test {
    uint256 private constant TVL_CAP = 1_000 * 1e6;
    Vault private sut;

    function setUp() public {
        sut = new Vault();
        sut.initialize("Vault", "V", address(0), TVL_CAP);
    }

    function testGivenCtorValueWhenCtorIsCalledThenTVLIsSet() public {
        assertEq(TVL_CAP, sut.tvlCap());
    }

    function testGivenNonAdminRoleWhenUpdateTVLCalledThenRevertsWithError()
        public
    {
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
        sut.updateTvlCap(100);
    }

    function testGivenAdminRoleWhenUpdateTVLCalledThenDoesNotRevert() public {
        address user = makeAddr("user");
        sut.grantRole(ADMIN_ROLE, user);

        vm.startPrank(user);
        sut.updateTvlCap(100);

        assertEq(100, sut.tvlCap());
    }

    function testGivenNonAdminRoleWhenRemoveTVLCalledThenRevertsWithError()
        public
    {
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
        sut.removeTvlCap();
    }

    function testGivenAdminRoleWhenRemoveTVLCalledThenDoesNotRevert() public {
        address user = makeAddr("user");
        sut.grantRole(ADMIN_ROLE, user);

        vm.startPrank(user);
        sut.removeTvlCap();

        assertEq(type(uint256).max, sut.tvlCap());
    }
}
