//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VaultBaseTest} from "../VaultBase.t.sol";

contract VaultWithdrawTest is VaultBaseTest {
    /*//////////////////////////////////////////////////////////////////////////
                WITHDRAW(UINT256 SHARES, ADDRESS RECEIVER, ADDRESS OWNER)
    //////////////////////////////////////////////////////////////////////////*/
    function testGivenWithdrawerWhenWithdrawThenUSDCWithdrawnSharesBurned()
        public
    {
        vm.startPrank(testUsers.alice);
        uint256 depositAmount = token.balanceOf(testUsers.alice);
        token.approve(address(vault), depositAmount);
        uint256 sharesMinted = vault.deposit(depositAmount, testUsers.alice);

        uint256 sharesBurned = vault.withdraw(
            vault.maxWithdraw(testUsers.alice),
            testUsers.alice,
            testUsers.alice
        );

        assertEq(vault.balanceOf(testUsers.alice), 0);
        assertEq(sharesBurned, sharesMinted);

        assertEq(depositAmount, token.balanceOf(testUsers.alice));
    }

    function testGivenWithdrawerWhenWithdrawAssetAmountIsZeroThenRevertsWithError()
        public
    {
        vm.startPrank(testUsers.alice);

        bytes4 errorSelector = bytes4(
            keccak256("WithdrawAssetAmountIsZero(address,address)")
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                testUsers.bob
            )
        );

        vault.withdraw(0, testUsers.alice, testUsers.bob);
    }

    function testGivenWithdrawerWhenMaxWithdrawExceededThenRevertsWithError()
        public
    {
        vm.startPrank(testUsers.alice);
        uint256 maxWithdrawOverflowAmount = 100;
        bytes4 errorSelector = bytes4(
            keccak256("ERC4626ExceededMaxWithdraw(address,uint256,uint256)")
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                maxWithdrawOverflowAmount,
                vault.maxWithdraw(testUsers.alice)
            )
        );

        vault.withdraw(
            maxWithdrawOverflowAmount,
            testUsers.alice,
            testUsers.alice
        );
    }

    function testGivenWithdrawerWhenSuccessfullyWithdrawsThenEventEmitted()
        public
    {
        vm.startPrank(testUsers.alice);
        uint256 depositAmount = token.balanceOf(testUsers.alice);
        token.approve(address(vault), depositAmount);
        uint256 sharesMinted = vault.deposit(depositAmount, testUsers.alice);

        vm.expectEmit(address(vault));
        emit VaultBaseTest.Withdraw(
            testUsers.alice,
            testUsers.alice,
            testUsers.alice,
            depositAmount,
            sharesMinted
        );

        vault.withdraw(
            vault.maxWithdraw(testUsers.alice),
            testUsers.alice,
            testUsers.alice
        );
    }
}
