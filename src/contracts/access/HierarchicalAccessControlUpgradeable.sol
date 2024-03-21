// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

abstract contract HierarchicalAccessControlUpgradeable is
    AccessControlEnumerableUpgradeable
{
    bytes32[] public roles;
    mapping(bytes32 => uint8) private rolePriorities;

    error HierarchicalAccessControlTooManyRoles(
        uint256 roleAmount,
        uint8 roleCap
    );
    error HierarchicalAccessControlUnauthorizedAccount(
        address account,
        bytes32 neededRole
    );
    error HierarchicalAccessControlRoleNotFound();
    error HierarchicalAccessControlInvalidRole(bytes32 role);
    error HierarchicalAccessControlDuplicateRole(bytes32 role);

    /* solhint-disable func-name-mixedcase */
    function __HierarchicalAccessControl_init(
        bytes32[] memory _roles
    ) internal onlyInitializing {
        __AccessControlEnumerable_init();

        if (_roles.length > type(uint8).max) {
            revert HierarchicalAccessControlTooManyRoles(
                _roles.length,
                type(uint8).max
            );
        }

        _checkForDuplicates(_roles);

        _initializeRolePriorities(_roles);

        roles = _roles;
    }

    modifier _atLeastRole(bytes32 role) {
        if (
            !hasRole(role, _msgSender()) &&
            !_hasHigherPriorityRole(role, _msgSender())
        ) {
            revert HierarchicalAccessControlUnauthorizedAccount(
                _msgSender(),
                role
            );
        }
        _;
    }

    function _grantRole(
        bytes32 role,
        address account
    ) internal override returns (bool) {
        if (rolePriorities[role] == 0) {
            revert HierarchicalAccessControlInvalidRole(role);
        }
        return super._grantRole(role, account);
    }

    // Getter function to retrieve the roles array
    function getRoles() external view returns (bytes32[] memory) {
        return roles;
    }

    // Getter function to retrieve the priority of a role
    function getRolePriority(bytes32 role) external view returns (uint8) {
        return rolePriorities[role];
    }

    function _hasHigherPriorityRole(
        bytes32 role,
        address account
    ) internal view returns (bool) {
        uint8 expectedRolePriority = rolePriorities[role];
        if (expectedRolePriority == 0) {
            revert HierarchicalAccessControlRoleNotFound();
        }
        bytes32[] memory cachedRoles = roles;
        for (uint8 i = expectedRolePriority; i > 0; i--) {
            if (hasRole(cachedRoles[i - 1], account)) {
                return true;
            }
        }

        return false;
    }

    function _initializeRolePriorities(bytes32[] memory _roles) internal {
        uint256 roleLength = _roles.length;
        for (uint8 i = 0; i < roleLength; i++) {
            rolePriorities[_roles[i]] = i + 1;
        }
    }

    function _checkForDuplicates(bytes32[] memory _roles) private pure {
        uint256 roleLength = _roles.length;
        for (uint8 i = 0; i < roleLength; i++) {
            for (uint8 j = 0; j < i; j++) {
                if (_roles[j] == _roles[i]) {
                    revert HierarchicalAccessControlDuplicateRole(_roles[i]);
                }
            }
        }
    }
}
