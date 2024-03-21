//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library String {
    function uintToString(uint256 i) external pure returns (string memory str) {
        if (i == 0) {
            return "0";
        }
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + (j % 10)));
            j /= 10;
        }
        str = string(bstr);
    }

    function equal(
        string memory a,
        string memory b
    ) external pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
