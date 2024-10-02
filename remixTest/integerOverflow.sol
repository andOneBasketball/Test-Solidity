// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract IntegerOverflow {
    uint8 public a;

    function set(int8 _a) public {
        a = uint8(_a);
    }
}
