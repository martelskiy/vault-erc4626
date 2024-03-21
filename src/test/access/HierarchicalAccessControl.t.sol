//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {HierarchicalAccessControlTestImpl} from "./HierarchicalAccessControlTestImpl.sol";
import {ADMIN_ROLE, GUARDIAN_ROLE, STRATEGIST_ROLE} from "../../contracts/access/Roles.sol";
import {Test} from "forge-std/Test.sol";

contract HierarchicalAccessControlTest is Test {
    HierarchicalAccessControlTestImpl private sut;
    address private deployer = makeAddr("Deployer");

    function setUp() public {
        vm.startPrank(deployer);
        sut = new HierarchicalAccessControlTestImpl();
        sut.initialize();
    }

    function testGivenDuplicatesInTheRoleArrayWhenInstantiateAccessControlContractThenRevertsWithError()
        public
    {
        bytes32[] memory rolesWithDuplicates = new bytes32[](2);
        rolesWithDuplicates[0] = STRATEGIST_ROLE;
        rolesWithDuplicates[1] = STRATEGIST_ROLE;

        bytes4 errorSelector = bytes4(
            keccak256("HierarchicalAccessControlDuplicateRole(bytes32)")
        );

        sut = new HierarchicalAccessControlTestImpl();
        sut.setInitRoles(rolesWithDuplicates);

        vm.expectRevert(abi.encodeWithSelector(errorSelector, STRATEGIST_ROLE));
        sut.initialize();
    }

    function testGivenAccessManagerWhenInstantitateNewManagerThenRolesAreCorrectlySet()
        public
    {
        bytes32[] memory roles = sut.getRoles();

        assertEq(roles.length, 4);
        assertEq(roles[0], sut.DEFAULT_ADMIN_ROLE());
        assertEq(roles[1], ADMIN_ROLE);
        assertEq(roles[2], GUARDIAN_ROLE);
        assertEq(roles[3], STRATEGIST_ROLE);

        uint8 priority = sut.getRolePriority(sut.DEFAULT_ADMIN_ROLE());
        assertEq(1, priority);
        priority = sut.getRolePriority(ADMIN_ROLE);
        assertEq(2, priority);
        priority = sut.getRolePriority(GUARDIAN_ROLE);
        assertEq(3, priority);
        priority = sut.getRolePriority(STRATEGIST_ROLE);
        assertEq(4, priority);

        priority = sut.getRolePriority(keccak256("NON_EXISTENT_ROLE"));
        assertEq(0, priority);
    }

    function testGivenEqualPriorityRoleWhenCallPermissionedFunctionThenUserIsAuthorized()
        public
    {
        address user = makeAddr("Alice");
        sut.grantRole(GUARDIAN_ROLE, user);
        assertTrue(sut.hasRole(GUARDIAN_ROLE, user));

        vm.startPrank(user);
        sut.guardianFunction();
    }

    function testGivenHigherPriorityRoleWhenCallPermissionedFunctionThenUserIsAuthorized()
        public
    {
        address user = makeAddr("Alice");
        sut.grantRole(ADMIN_ROLE, user);
        assertTrue(sut.hasRole(ADMIN_ROLE, user));

        vm.startPrank(user);
        sut.guardianFunction();
        sut.strategistFunction();
    }

    function testGivenUserWithoutAnyRoleWhenCallPermissionedFunctionThenUserIsNotAuthorized()
        public
    {
        vm.stopPrank();
        address user = makeAddr("Alice");
        bytes4 errorSelector = bytes4(
            keccak256(
                "HierarchicalAccessControlUnauthorizedAccount(address,bytes32)"
            )
        );

        vm.expectRevert(
            abi.encodeWithSelector(errorSelector, user, GUARDIAN_ROLE)
        );

        vm.startPrank(user);
        sut.guardianFunction();
    }

    function testGivenLowerPriorityRoleWhenCallPermissionedFunctionThenUserIsNotAuthorized()
        public
    {
        address user = makeAddr("Alice");
        sut.grantRole(STRATEGIST_ROLE, user);
        assertTrue(sut.hasRole(STRATEGIST_ROLE, user));

        vm.startPrank(user);
        bytes4 errorSelector = bytes4(
            keccak256(
                "HierarchicalAccessControlUnauthorizedAccount(address,bytes32)"
            )
        );
        vm.expectRevert(
            abi.encodeWithSelector(errorSelector, user, GUARDIAN_ROLE)
        );
        sut.guardianFunction();
    }

    function testGivenNoneExistingRoleWhenGrantRoleThenRevertsWithError()
        public
    {
        address user = makeAddr("Alice");
        bytes32 invalidRole = keccak256("boom");
        bytes4 errorSelector = bytes4(
            keccak256("HierarchicalAccessControlInvalidRole(bytes32)")
        );
        vm.expectRevert(abi.encodeWithSelector(errorSelector, invalidRole));
        sut.grantRole(invalidRole, user);

        assertFalse(sut.hasRole(invalidRole, user));
    }

    function testGivenNoneExistingRoleOnFunctionDeclarationWhenCallPermissionedFunctionThenRoleNotFoundErrorReturned()
        public
    {
        bytes4 errorSelector = bytes4(
            keccak256("HierarchicalAccessControlRoleNotFound()")
        );
        vm.expectRevert(abi.encodeWithSelector(errorSelector));

        sut.nonExistentRoleFunction();
    }
}
