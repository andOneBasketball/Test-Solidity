// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract UintSetExample {
    using EnumerableSet for EnumerableSet.UintSet;

    // 声明一个 UintSet 类型的集合变量
    EnumerableSet.UintSet private numbers;

    // 添加一个数到集合中
    function addNumber(uint256 _number) public returns (bool) {
        // 尝试添加数字，返回 true 表示添加成功，false 表示数字已存在
        return numbers.add(_number);
    }

    // 从集合中移除一个数
    function removeNumber(uint256 _number) public returns (bool) {
        // 尝试移除数字，返回 true 表示移除成功，false 表示数字不存在
        return numbers.remove(_number);
    }

    // 检查数字是否在集合中
    function containsNumber(uint256 _number) public view returns (bool) {
        return numbers.contains(_number);
    }

    // 获取集合中的数字数量
    function getNumberCount() public view returns (uint256) {
        return numbers.length();
    }

    // 根据索引获取集合中的数字
    function getNumberAtIndex(uint256 index) public view returns (uint256) {
        require(index < numbers.length(), "Index out of bounds");
        return numbers.at(index);
    }

    // 获取集合中的所有数字（返回一个 uint 数组）
    function getAllNumbers() public view returns (uint256[] memory) {
        uint256[] memory allNumbers = new uint256[](numbers.length());
        for (uint256 i = 0; i < numbers.length(); i++) {
            allNumbers[i] = numbers.at(i);
        }
        return allNumbers;
    }
}
