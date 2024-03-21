# Hierarchical Access Control (Upgradeable) Contract

The Hierarchical Access Control (Upgradeable) contract extends OpenZeppelin's `AccessControlEnumerableUpgradeable` contract to provide hierarchical role-based access control. It introduces the concept of role priorities, allowing roles to have different levels of authority. This contract is designed to be upgradeable using the OpenZeppelin Upgrades plugins.

## Features

- **Upgradeable**: The contract is designed to be upgradeable, allowing for future improvements and changes.

- **Role Priorities**: Each role is assigned a priority, and an account with a role can perform actions associated with that role and any roles with higher priorities.

- **Duplicate Role Check**: During contract initialization, duplicate roles in the provided array are checked to ensure uniqueness.

- **Custom Error Handling**: Custom error messages and error types are used to provide meaningful feedback in case of errors.

## Usage

### Contract Deployment and Initialization

1. Deploy and initialize the `HierarchicalAccessControlUpgradeable` contract, providing an array of roles:

   ```solidity
   // Deploy and initialize the contract
   HierarchicalAccessControlUpgradeable hierarchicalAccessControl = new HierarchicalAccessControlUpgradeable();
   hierarchicalAccessControl.__HierarchicalAccessControl_init([
       keccak256("DEFAULT_ADMIN_ROLE"),
       keccak256("GUARDIAN_ROLE"),
       // Add more roles as needed
   ]);
   ```
2. Access the roles and their priorities

    ```solidity
    bytes32[] memory allRoles = hierarchicalAccessControl.getRoles();
    uint8 rolePriority = hierarchicalAccessControl.getRolePriority(keccak256("GUARDIAN_ROLE"));
    ```
3. Role-Based Access. Use the `_atLeastRole` modifier to enforce access control based on roles and priorities:
    ```solidity
    function exampleFunction() external _atLeastRole(keccak256("GUARDIAN_ROLE")) {
        // Function logic for Manager or higher
    }
    ```
4. Granting Roles. Override the _grantRole function to restrict role granting to predefined roles:
    ```solidity
    function grantRole(bytes32 role, address account) external onlyRole(keccak256("DEFAULT_ADMIN_ROLE")) {
        // Check for role existence and priority
        require(hierarchicalAccessControl.getRolePriority(role) != 0, "InvalidRole");
        // Grant the role using the overridden _grantRole function
        hierarchicalAccessControl._grantRole(role, account);
    }
    ```
### Upgradeability. 
Ensure proper upgradeability using tools such as OpenZeppelin Upgrades. Follow best practices for smart contract upgrades.

### Important Notes
`DEFAULT_ADMIN_ROLE` is the default OpenZeppelin (OZ) role defined in the `AccessControlEnumerableUpgradeable` contract. It serves as an admin role for all other roles, indicating that only an account with this role can grant or revoke other roles. The role list should include `DEFAULT_ADMIN_ROLE`` and assign it the highest priority.

Role priorities are determined by the order of roles in the roles array. Lower index indicates higher priority.

Ensure that roles are granted to accounts appropriately, considering the hierarchical nature of roles.

Review and customize error messages, modifiers, and access control logic based on your specific requirements.