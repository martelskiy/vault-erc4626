//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VaultBaseTest} from "../VaultBase.t.sol";

contract VaultMintTest is VaultBaseTest {
    /*//////////////////////////////////////////////////////////////////////////
                         MINT(UINT256 SHARES, ADDRESS RECEIVER)
    //////////////////////////////////////////////////////////////////////////*/
    function testGivenMinterWhenMintThenVaultSharesMinted() public {
        vm.startPrank(testUsers.alice);
        uint256 mintAmount = token.balanceOf(testUsers.alice);
        token.approve(address(vault), mintAmount);
        uint256 vaultBalanceBefore = vault.balanceOf(testUsers.alice);

        uint256 shares = vault.mint(mintAmount, testUsers.alice);

        uint256 vaultBalanceAfter = vault.balanceOf(testUsers.alice);
        assertEq(vaultBalanceBefore, 0);
        assertEq(vaultBalanceAfter, mintAmount);
        assertEq(vaultBalanceAfter, shares);
    }

    function testGivenMinterWhenMintThenUSDCWithdrawnFromMinter() public {
        vm.startPrank(testUsers.alice);
        uint256 userUSDCBalanceBefore = token.balanceOf(testUsers.alice);
        uint256 userMintAmount = userUSDCBalanceBefore / 10;
        token.approve(address(vault), userMintAmount);

        vault.mint(userMintAmount, testUsers.alice);

        uint256 userUSDCBalanceAfter = token.balanceOf(testUsers.alice);
        assertEq(userUSDCBalanceBefore - userMintAmount, userUSDCBalanceAfter);
    }

    function testGivenMinterWhenMintShareAmountIsZeroThenRevertsWithError()
        public
    {
        vm.startPrank(testUsers.alice);

        bytes4 errorSelector = bytes4(
            keccak256("MintShareAmountIsZero(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(errorSelector, testUsers.alice));

        vault.mint(0, testUsers.alice);
    }

    function testGivenMinterWhenMaxMintExceededThenRevertsWithError() public {
        vm.startPrank(testUsers.alice);
        uint256 maxMintOverflowAmount = vault.maxMint(address(0)) + 1;
        deal({
            token: address(token),
            to: testUsers.alice,
            give: maxMintOverflowAmount
        });
        token.approve(address(vault), token.balanceOf(testUsers.alice));

        bytes4 errorSelector = bytes4(
            keccak256("ERC4626ExceededMaxMint(address,uint256,uint256)")
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                maxMintOverflowAmount,
                vault.maxDeposit(testUsers.alice)
            )
        );

        vault.mint(maxMintOverflowAmount, testUsers.alice);
    }

    function testGivenMinterWhenSuccessfullyMintThenEventEmitted() public {
        vm.startPrank(testUsers.alice);
        uint256 userUSDCBalanceBefore = token.balanceOf(testUsers.alice);
        uint256 userMintAmount = userUSDCBalanceBefore / 10;
        token.approve(address(vault), userMintAmount);

        vm.expectEmit(address(vault));
        emit VaultBaseTest.Deposit(
            testUsers.alice,
            testUsers.alice,
            userMintAmount,
            vault.previewDeposit(userMintAmount)
        );

        vault.mint(userMintAmount, testUsers.alice);
    }

    function testGivenMinterWhenVaultIsPausedThenReverts() public {
        vm.startPrank(deployer);
        vault.pause();

        uint256 userMintAmount = token.balanceOf(testUsers.alice);
        token.approve(address(vault), userMintAmount);

        bytes4 errorSelector = bytes4(keccak256("EnforcedPause()"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector));

        vault.mint(userMintAmount, testUsers.alice);
    }
}
