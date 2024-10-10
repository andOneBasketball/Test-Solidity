// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract RevertCase {
    uint public count = 0;

    error MyError(string message);

    function revertTest() public {
        count += 1;
        revert MyError("This is a revert test");
    }

    function transferTest(address payable _to, uint _amount) public {
        count += 1;
        _to.transfer(_amount);
    }
}
