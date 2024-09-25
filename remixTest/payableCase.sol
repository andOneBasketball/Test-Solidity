// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/*
作业内容：编写一个包含Fallback和Receive函数的Solidity合约，并测试其行为。

要求：
1. 定义一个可以接收Ether的合约，包含Fallback和Receive函数。
2. Fallback函数应记录调用者地址、发送的金额和数据。
3. Receive函数应记录调用者地址和发送的金额。
4. 部署合约并测试：
发送带数据的Ether，验证Fallback函数被调用。
发送不带数据的Ether，验证Receive函数被调用。
删除Receive函数，再次发送不带数据的Ether，验证Fallback函数被调用。
*/

contract payableCase {
    address payable recipient;

    event receiveCall(address _send, uint _value);

    constructor() {
        recipient = payable(msg.sender);
    }

    function queryBalance() external view returns(uint) {
        return(address(this).balance);
    }

    function receiveEther() external payable {}

    /* 触发fallback() 还是 receive()?
           接收ETH
              |
         msg.data是空？
            /  \
          是    否
          /      \
receive()存在?   fallback()
        / \
       是  否
      /     \
receive()  fallback   
    */
    // 接收以太币失败时的回退函数
    fallback() external payable {
        revert("Function not payable");
    }

    receive() external payable {
        emit receiveCall(msg.sender, msg.value);
    }
}
