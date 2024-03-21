//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Test} from "forge-std/Test.sol";
import {Vault} from "../../../contracts/Vault.sol";
import {Token} from "../helpers/Token.sol";
import {Users} from "../helpers/Users.sol";
import {ZKEVM_NETWORK, Network} from "../../constants/Network.sol";

abstract contract VaultBaseTest is Test, Token, Network {
    event Deposit(
        address indexed sender,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/
    Vault internal vault;

    /*//////////////////////////////////////////////////////////////////////////
                                   HELPERS CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/
    Users internal testUsers;
    /*//////////////////////////////////////////////////////////////////////////
                                   VARIABLES
    //////////////////////////////////////////////////////////////////////////*/
    uint256 internal constant TOKEN_USER_HOLDINGS = 1_000_000e18;

    address internal deployer = makeAddr("Deployer");

    constructor() Token(ZKEVM_NETWORK) {}

    function setUp() public {
        _initFork();
        vm.startPrank(deployer);

        testUsers = Users({
            alice: _createUser("Alice", address(token), TOKEN_USER_HOLDINGS),
            bob: _createUser("Bob", address(token), TOKEN_USER_HOLDINGS)
        });

        vault = new Vault();
        ERC1967Proxy proxy = new ERC1967Proxy(address(vault), "");
        vault = Vault(address(proxy));

        vault.initialize("Vault", "V", address(token), 1_000_000_000e18);
    }

    function _createUser(
        string memory name,
        address token,
        uint256 amount
    ) internal returns (address) {
        address user = makeAddr(name);
        deal({token: token, to: user, give: amount});
        return user;
    }

    function _initFork() private {
        uint256 fork = vm.createSelectFork(
            vm.rpcUrl(ZKEVM_NETWORK),
            networkConfiguration[ZKEVM_NETWORK].blockHeight
        );
        assertEq(vm.activeFork(), fork);
    }
}
