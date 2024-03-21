//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {HierarchicalAccessControlUpgradeable} from "../../contracts/access/HierarchicalAccessControlUpgradeable.sol";
import {ADMIN_ROLE, GUARDIAN_ROLE, STRATEGIST_ROLE} from "../../contracts/access/Roles.sol";

contract HierarchicalAccessControlTestImpl is
    HierarchicalAccessControlUpgradeable
{
    bytes32[] private initRoles = [
        DEFAULT_ADMIN_ROLE,
        ADMIN_ROLE,
        GUARDIAN_ROLE,
        STRATEGIST_ROLE
    ];

    function initialize() public initializer {
        __HierarchicalAccessControl_init(initRoles);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setInitRoles(bytes32[] memory initRoles_) external {
        initRoles = initRoles_;
    }

    function guardianFunction()
        external
        view
        _atLeastRole(GUARDIAN_ROLE)
        returns (string memory)
    {
        return "";
    }

    function strategistFunction()
        external
        view
        _atLeastRole(STRATEGIST_ROLE)
        returns (string memory)
    {
        return "";
    }

    function nonExistentRoleFunction()
        external
        view
        _atLeastRole(keccak256("NON_EXISTENT_ROLE"))
        returns (string memory)
    {
        return "";
    }
}
