//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {MAINNET_NETWORK, ZKEVM_NETWORK, UnsupportedNetwork} from "../../constants/Network.sol";
import {String} from "../../libraries/String.sol";

abstract contract Token {
    IERC20Metadata internal token;

    constructor(string memory network) {
        address USDC;
        if (String.equal(network, MAINNET_NETWORK)) {
            USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
            token = IERC20Metadata(USDC);
        } else if (String.equal(network, ZKEVM_NETWORK)) {
            USDC = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
            token = IERC20Metadata(USDC);
        } else {
            revert UnsupportedNetwork(network);
        }
    }
}
