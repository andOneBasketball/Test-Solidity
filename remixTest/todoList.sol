// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/*
任务：编写一个 Solidity 程序，实现一个简单的待办事项列表。
要求：
1. 定义一个 `ToDo` 结构体，包含 `text`（任务描述）和 `completed`（是否完成）。
2. 创建一个 `ToDo[]` 数组来存储多个任务。
3. 实现 `create`, `updateText`, 和 `toggleCompleted(切换状态)` 函数。
4. 部署合约到测试网络，并通过界面或命令行测试各个函数的功能
 */

contract TodoList {
    struct toDo {
        string des;
        bool complete;
    }

    toDo[] public toDos;

    function create(string calldata _des) public {
        toDos.push(toDo({des: _des, complete: false}));
    }

    error myError(uint _i, string _des);

    function updateText(string calldata _des, uint _i) public {
        require(_i < toDos.length, "index error");
        toDos[_i].des = _des;
    }

    function toggleCompleted(uint _i) public {
        if (_i > toDos.length) {
            revert myError(_i, "index error");
        }
        toDos[_i].complete = !toDos[_i].complete;
    }
}
