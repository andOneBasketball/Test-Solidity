// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/*
编写一个简单的以太坊智能合约 EtherWallet，要求如下：

1. 合约可以接收以太币。
2. 只有合约所有者可以提取以太币。
3. 合约中有一个函数可以返回当前存储的以太币余额。
*/

contract etherWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
