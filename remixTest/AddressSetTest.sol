// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract AddressSetExample {
    using EnumerableSet for EnumerableSet.AddressSet;

    // 声明一个 AddressSet 类型的集合变量
    EnumerableSet.AddressSet private addresses;

    // 添加一个地址到集合中
    function addAddress(address _address) public returns (bool) {
        // 尝试添加地址，返回 true 表示添加成功，false 表示地址已存在
        return addresses.add(_address);
    }

    // 从集合中移除一个地址
    function removeAddress(address _address) public returns (bool) {
        // 尝试移除地址，返回 true 表示移除成功，false 表示地址不存在
        return addresses.remove(_address);
    }

    // 检查地址是否在集合中
    function containsAddress(address _address) public view returns (bool) {
        return addresses.contains(_address);
    }

    // 获取集合中的地址数量
    function getAddressCount() public view returns (uint256) {
        return addresses.length();
    }

    // 根据索引获取集合中的地址
    function getAddressAtIndex(uint256 index) public view returns (address) {
        require(index < addresses.length(), "Index out of bounds");
        return addresses.at(index);
    }

    // 获取集合中的所有地址（返回一个地址数组）
    function getAllAddresses() public view returns (address[] memory) {
        address[] memory allAddresses = new address[](addresses.length());
        for (uint256 i = 0; i < addresses.length(); i++) {
            allAddresses[i] = addresses.at(i);
        }
        return allAddresses;
    }
}
