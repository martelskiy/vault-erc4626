//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vault} from "../../../../contracts/Vault.sol";

contract VaultV2 is Vault {
    function version() external pure returns (string memory) {
        return "v2";
    }
}
