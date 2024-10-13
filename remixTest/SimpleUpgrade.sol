// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// 该范例只是简单模拟可升级合约，实际中的可升级合约需要考虑权限问题（透明代理，管理员用户仅允许调用 upgradeContract，具体参考 Openzeppelin 的 TransparentUpgradeableProxy 合约）、选择器冲突问题（参考 OpenZeppelin 的 UUPSUpgradeable 合约）

// 实现一个简单的可升级合约
// 合约的变量存储必须保持一致
contract SimpleUpgrade {
    address public contractAddress;
    uint public value;

    event Log(bytes data, bool success);

    constructor(address _contractAddress) {
        contractAddress = _contractAddress;
    }

    // 可调用升级合约的任意函数
    fallback() external {
        (bool success, ) = contractAddress.delegatecall(msg.data);
        emit Log(msg.data, success);
    }

    function upgradeContract(address _newContractAddress) external {
        contractAddress = _newContractAddress;
    }
}

contract Logic {
    address public contractAddress;
    uint public value;

    function setValue(uint _value) external {
        value = _value;
    }

    function getMsgdata(uint _value) external pure returns (bytes memory) {
        return abi.encodeWithSignature("setValue(uint256)", _value);
    }
}

contract LogicV2 {
    address public contractAddress;
    uint public value;

    function setValue(uint _value) external {
        value = _value * 2;
    }

    function getMsgdata(uint _value) external pure returns (bytes memory) {
        return abi.encodeWithSignature("setValue(uint256)", _value);
    }
}

