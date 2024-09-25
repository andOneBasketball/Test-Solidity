// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/*
作业描述

编写一个Solidity合约，使用Library实现以下功能：

1. 创建一个名为`MathLib`的Library，包含一个`min`函数，用于返回两个`uint`类型整数中的较小值。
2. 创建一个名为`ArrayUtils`的Library，包含一个`sum`函数，用于计算并返回`uint`类型数组中所有元素的和。
3. 在测试合约中使用这两个Library，验证其功能。

#### 作业要求

1. 创建`MathLib`并实现`min`函数。
2. 创建`ArrayUtils`并实现`sum`函数。
3. 创建测试合约`TestLibraries`，在合约中使用`MathLib.min`函数和`ArrayUtils.sum`函数。
4. 部署并测试合约，确保函数正确执行。
 */

library MathLib {
    function min(uint a, uint b) internal pure returns (uint) {
        return(a < b ? a : b);
    }
}

library ArrayUtils {
    function sum(uint[] memory arr) internal pure returns (uint) {
        uint _sum = 0;
        for (uint i = 0; i < arr.length; i++) {
            _sum += arr[i];
        }
        return(_sum);
    }
}

contract TestLibraries {
    using ArrayUtils for uint[];
    function minTest(uint a, uint b) public pure returns(uint) {
        return MathLib.min(a, b);
    }

    function arrTest(uint[] memory arr) public pure returns(uint) {
        return(arr.sum());
    }
}
