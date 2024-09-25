// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/*
实现一个简化版本的访问控制合约，包含以下功能：

1. 定义两个角色：`admin`和`user`
2. 实现分配和撤销角色的函数
3. 为合约部署者分配`admin`角色
 */

contract AccessControl {
    event GrantRole(address indexed account, bytes32 indexed role);
    event RevokeRole(address indexed account, bytes32 indexed role);

    mapping(bytes32 => mapping(address => bool)) public roles;

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _;
    }

    bytes32 public constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 public constant USER = keccak256(abi.encodePacked("USER"));

    constructor() {
        roles[ADMIN][msg.sender] = true;
    }

    function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        roles[_role][_account] = true;
        emit GrantRole(_account, _role);
    }
    
    function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        roles[_role][_account] = false;
        emit RevokeRole(_account, _role);
    }
}

