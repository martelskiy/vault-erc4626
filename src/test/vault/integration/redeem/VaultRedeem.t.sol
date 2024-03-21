//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VaultBaseTest} from "../VaultBase.t.sol";

contract VaultRedeemTest is VaultBaseTest {
    /*//////////////////////////////////////////////////////////////////////////
                REDEEM(UINT256 SHARES, ADDRESS RECEIVER, ADDRESS OWNER)
    //////////////////////////////////////////////////////////////////////////*/
    function testGivenRedeemerWhenRedeemThenVaultSharesRedeemed() public {
        vm.startPrank(testUsers.alice);
        uint256 depositAmount = token.balanceOf(testUsers.alice);
        token.approve(address(vault), depositAmount);
        uint256 userShares = vault.deposit(depositAmount, testUsers.alice);

        uint256 assets = vault.redeem(
            userShares,
            testUsers.alice,
            testUsers.alice
        );

        uint256 approximateFee = 1e15;
        assertApproxEqRel(depositAmount, assets, approximateFee);
        assertEq(vault.balanceOf(testUsers.alice), 0);
        assertEq(assets, token.balanceOf(testUsers.alice));
    }

    function testGivenRedeemerWhenRedeemShareAmountIsZeroThenRevertsWithError()
        public
    {
        vm.startPrank(testUsers.alice);

        bytes4 errorSelector = bytes4(
            keccak256("RedeemShareAmountIsZero(address,address)")
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                testUsers.bob
            )
        );

        vault.redeem(0, testUsers.alice, testUsers.bob);
    }

    function testGivenRedeemerWhenMaxRedeemExceededThenRevertsWithError()
        public
    {
        vm.startPrank(testUsers.alice);
        uint256 maxRedeemOverflowAmount = 100;
        bytes4 errorSelector = bytes4(
            keccak256("ERC4626ExceededMaxRedeem(address,uint256,uint256)")
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                errorSelector,
                testUsers.alice,
                maxRedeemOverflowAmount,
                vault.maxRedeem(testUsers.alice)
            )
        );

        vault.redeem(maxRedeemOverflowAmount, testUsers.alice, testUsers.alice);
    }

    function testGivenRedeemerWhenSuccessfullyRedeemThenEventEmitted() public {
        vm.startPrank(testUsers.alice);
        uint256 depositAmount = token.balanceOf(testUsers.alice);
        token.approve(address(vault), depositAmount);
        uint256 userShares = vault.deposit(depositAmount, testUsers.alice);

        vm.expectEmit(address(vault));
        emit VaultBaseTest.Withdraw(
            testUsers.alice,
            testUsers.alice,
            testUsers.alice,
            depositAmount,
            userShares
        );

        vault.redeem(userShares, testUsers.alice, testUsers.alice);
    }
}
