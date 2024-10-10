// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract Fallback {
    uint public num;
    address public sender;

    event Log(bytes message);

    fallback() external payable {
        emit Log(msg.data);
    }

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}

contract B {
    uint public num;
    address public sender;

    // 通过call来调用C的setVars()函数，将改变合约C里的状态变量
    function callSetVars(address _addr, uint _num) external payable{
        // call setVars()
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
    // 通过delegatecall来调用C的setVars()函数，将改变合约B里的状态变量
    function delegatecallSetVars(address _addr, uint _num) external payable{
        // delegatecall setVars()
        (bool success, bytes memory data) = _addr.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }

    function callNotExistFun(address _addr, uint _num) external payable{
        // call setVars()
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("callNotExistFun(uint256)", _num)
        );
    }
}
