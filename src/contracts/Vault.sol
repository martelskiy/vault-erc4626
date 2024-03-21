//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC4626Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {TVLManageableUpgradeable} from "./tvl/TVLManageableUpgradeable.sol";
import {CooldownUUPSUpgradeable} from "./upgrade/CooldownUUPSUpgradeable.sol";
import {HierarchicalAccessControlUpgradeable} from "./access/HierarchicalAccessControlUpgradeable.sol";
import {ADMIN_ROLE, GUARDIAN_ROLE, STRATEGIST_ROLE} from "./access/Roles.sol";

/**
    @title ERC4626 yield-bearing vault
*/
contract Vault is
    ERC4626Upgradeable,
    PausableUpgradeable,
    CooldownUUPSUpgradeable,
    TVLManageableUpgradeable,
    HierarchicalAccessControlUpgradeable
{
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    error DepositAssetAmountIsZero(address receiver);
    error MintShareAmountIsZero(address receiver);
    error RedeemShareAmountIsZero(address receiver, address owner);
    error WithdrawAssetAmountIsZero(address receiver, address owner);

    bytes32[] private initRoles;

    function initialize(
        string memory name,
        string memory symbol,
        address underlying,
        uint256 tvlCap_
    ) public initializer {
        __ERC4626_init(IERC20(underlying));
        __Pausable_init();
        __ERC20_init(name, symbol);
        __TVLManageable_init(tvlCap_);
        __CooldownUUPSUpgradeable_init();

        initRoles = [
            DEFAULT_ADMIN_ROLE,
            ADMIN_ROLE,
            GUARDIAN_ROLE,
            STRATEGIST_ROLE
        ];

        __HierarchicalAccessControl_init(initRoles);

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /** 
        @dev See {IERC4626-deposit}. 
    */
    function deposit(
        uint256 assets,
        address receiver
    ) public override whenNotPaused returns (uint256) {
        if (assets == 0) {
            revert DepositAssetAmountIsZero(receiver);
        }
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets)
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /** 
        @dev See {IERC4626-withdraw}. 
    */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override returns (uint256) {
        if (assets == 0) {
            revert WithdrawAssetAmountIsZero(receiver, owner);
        }
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /**  
        @dev See {IERC4626-mint}.
        As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
        In this case, the shares will be minted without requiring any assets to be deposited.
     */
    function mint(
        uint256 shares,
        address receiver
    ) public override whenNotPaused returns (uint256) {
        if (shares == 0) {
            revert MintShareAmountIsZero(receiver);
        }
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /** 
        @dev See {IERC4626-redeem}. 
    */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override returns (uint256) {
        if (shares == 0) {
            revert RedeemShareAmountIsZero(receiver, owner);
        }
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /** 
        @dev See {IERC4626-maxDeposit}. 
    */
    function maxDeposit(address) public view override returns (uint256) {
        return _maxDeposit();
    }

    /** 
        @dev See {IERC4626-maxMint}. 
    */
    function maxMint(address) public view override returns (uint256) {
        return convertToShares(_maxDeposit());
    }

    function _maxDeposit() internal view returns (uint256) {
        if (_tvlCap > totalAssets()) {
            return _tvlCap - totalAssets();
        }
        return 0;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                TVL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/
    /**
        @dev Function to update Vault's TVL cap
     */
    function updateTvlCap(uint256 tvlCap_) external _atLeastRole(ADMIN_ROLE) {
        _updateTvlCap(tvlCap_);
    }

    /**
        @dev Function to remove Vault's TVL cap
     */
    function removeTvlCap() external _atLeastRole(ADMIN_ROLE) {
        _removeTvlCap();
    }

    /**
        @dev Function to get Vault's TVL cap
     */
    function tvlCap() external view returns (uint256) {
        return _tvlCap;
    }

    /*//////////////////////////////////////////////////////////////////////////
                               UPGRADEABLE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/
    /**
        @dev Function sets the access control for contract upgrade functionality 
     */
    /* solhint-disable no-empty-blocks */
    function _authorizeUpgrade()
        internal
        override
        _atLeastRole(DEFAULT_ADMIN_ROLE)
    {}

    /**
        @dev Function unlocks the contract upgrade
     */
    function unlockUpgrade() external _atLeastRole(STRATEGIST_ROLE) {
        _unlockUpgrade();
    }

    /**
        @dev Function locks the contract upgrade
     */
    function lockUpgrade() external _atLeastRole(GUARDIAN_ROLE) {
        _lockUpgrade();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PAUSABLE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
        @dev Function for pausing (until unpaused) certain features.
            Prerequisite: Contract must be unpaused   
     */
    function pause() external _atLeastRole(GUARDIAN_ROLE) {
        _pause();
    }

    /**
        @dev Function for unpausing certain features.
            Prerequisite: Contract must be paused
     */
    function unpause() external _atLeastRole(ADMIN_ROLE) {
        _unpause();
    }
}
