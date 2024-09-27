// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract MsgSendCase {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setOwner(address _owner) public {
        owner = _owner;
    }
}
