//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TVLManageableImpl} from "./TVLManageableImpl.sol";
import {Test} from "forge-std/Test.sol";

contract TVLManageableTest is Test {
    TVLManageableImpl private sut;
    uint256 private constant TVL_CAP = 1_000;

    event TvlInitilized(uint256 tvlCap);
    event TvlCapUpdated(uint256 value);

    function setUp() public {
        sut = new TVLManageableImpl();
        sut.initialize(TVL_CAP);
    }

    function testGivenTVLCapWhenCallConstructorThenTVLSet() public {
        assertEq(TVL_CAP, sut.tvlCap());
    }

    function testGivenTVLCapWhenCallConstructorThenEventEmitted() public {
        vm.expectEmit();
        emit TVLManageableTest.TvlInitilized(TVL_CAP);

        sut = new TVLManageableImpl();
        sut.initialize(TVL_CAP);
    }

    function testGivenTVLWhenUpdateTVLCapThenTVLUpdated() public {
        uint256 capBefore = sut.tvlCap();
        uint256 updatedCap = 1_000_000;

        sut.updateTvlCap(updatedCap);

        uint256 capAfter = sut.tvlCap();

        assertNotEq(capBefore, capAfter);
        assertEq(capAfter, updatedCap);
    }

    function testGivenTVLWhenUpdateTVLCapThenEventEmitted() public {
        uint256 updatedCap = 1_000_000;

        vm.expectEmit();
        emit TVLManageableTest.TvlCapUpdated(updatedCap);

        sut.updateTvlCap(updatedCap);
    }

    function testGivenTVLWhenRemoveTVLCapThenCapIsSetToMax() public {
        sut.removeTvlCap();

        assertEq(type(uint256).max, sut.tvlCap());
    }
}
