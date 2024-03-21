//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VaultBaseTest} from "../VaultBase.t.sol";

contract VaultDepositTest is VaultBaseTest {
    /*//////////////////////////////////////////////////////////////////////////
                         DEPOSIT(UINT256 ASSETS, ADDRESS RECEIVER)
    //////////////////////////////////////////////////////////////////////////*/
    function testGivenDepositorWhenDepositThenVaultSharesMinted() public {
        vm.startPrank(testUsers.alice);
        uint256 usdcDepositAmount = TOKEN_USER_HOLDINGS / 10;
        token.approve(address(vault), usdcDepositAmount);
        uint256 vaultBalanceBefore = vault.balanceOf(testUsers.alice);

        uint256 shares = vault.deposit(usdcDepositAmount, testUsers.alice);

        uint256 vaultBalanceAfter = vault.balanceOf(testUsers.alice);
        assertEq(vaultBalanceBefore, 0);
        assertEq(vaultBalanceAfter, usdcDepositAmount);
        assertEq(vaultBalanceAfter, shares);
    }

    function testGivenDepositorWhenDepositThenUSDCWithdrawnFromDepositor()
        public
    {
        vm.startPrank(testUsers.alice);
        uint256 userUSDCBalanceBefore = token.balanceOf(testUsers.alice);
        uint256 usdcDepositAmount = userUSDCBalanceBefore / 10;
        token.approve(address(vault), usdcDepositAmount);

        vault.deposit(usdcDepositAmount, testUsers.alice);

        uint256 userUSDCBalanceAfter = token.balanceOf(testUsers.alice);
        assertEq(
            userUSDCBalanceBefore - usdcDepositAmount,
            userUSDCBalanceAfter
        );
    }

    function testGivenDepositorWhenMaxDepositAmountIsZeroThenRevertsWithError()
        public
    {
        vm.startPrank(testUsers.alice);
        bytes4 errorSelector = bytes4(
            keccak256("DepositAssetAmountIsZero(address)")
        );
        vm.expectRevert(abi.encodeWithSelector(errorSelector, testUsers.alice));

        vault.deposit(0, testUsers.alice);
    }

    function testGivenDepositorWhenMaxDepositExceededThenRevertsWithError()
        public
    {
        vm.startPrank(testUsers.alice);
        uint256 maxDepositOverflowAmount = vault.maxDeposit(address(0)) + 1;
        deal({
            token: address(token),
            to: testUsers.alice,
            give: maxDepositOverflowAmount
        });
        token.approve(address(vault), token.balanceOf(testUsers.alice));

        bytes4 errorSelector = bytes4(
            keccak256("ERC4626ExceededMaxDeposit(address,uint256,uint256)")
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                maxDepositOverflowAmount,
                vault.maxDeposit(testUsers.alice)
            )
        );

        vault.deposit(maxDepositOverflowAmount, testUsers.alice);
    }

    function testGivenDepositorWhenSuccessfullyDepositThenEventEmitted()
        public
    {
        uint256 usdcDepositAmount = token.balanceOf(testUsers.alice);
        vm.startPrank(testUsers.alice);
        token.approve(address(vault), usdcDepositAmount);

        vm.expectEmit(address(vault));
        emit VaultBaseTest.Deposit(
            testUsers.alice,
            testUsers.alice,
            usdcDepositAmount,
            vault.previewDeposit(usdcDepositAmount)
        );

        vault.deposit(usdcDepositAmount, testUsers.alice);
    }

    function testGivenDepositorWhenVaultIsPausedThenReverts() public {
        vm.startPrank(deployer);
        vault.pause();

        uint256 usdcDepositAmount = token.balanceOf(testUsers.alice);
        vm.startPrank(testUsers.alice);
        token.approve(address(vault), usdcDepositAmount);

        bytes4 errorSelector = bytes4(keccak256("EnforcedPause()"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector));

        vault.deposit(usdcDepositAmount, testUsers.alice);
    }
}
