// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

//Yul 在某些场景下可能更具优势，但开发者需要根据具体情况进行权衡。在需要更高效的内存和存储管理时，Yul 可能会提供更低的 gas 消耗，而在常规用途中，Solidity 的编译器优化可能已经足够高效。

contract AssemblyCase {
    uint public num;

    // 直接使用 sstore 指令将值存入 storage，改变num的值，但该场景下的gas消耗高于setNum2，缺少solidity优化
    function setNum1(uint _num) public {
        assembly {
            sstore(0, _num)
        }
    }

    function setNum2(uint _num) public {
        num = _num;
    }

    // gas 对比 add2 消耗更低
    function add1(uint a, uint b) public pure returns (uint) {
        uint c;
        assembly {
            c := add(a, b)
        }
        return c;
    }

    function add2(uint a, uint b) public pure returns (uint) {
        return a + b;
    }
}
