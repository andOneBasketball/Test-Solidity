// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";

/*
实现一个简单的ERC20代币合约，包含以下功能：

1. 定义代币的名称、符号和小数位数。
2. 实现转移功能。
3. 实现授权功能及其查询。
4. 实现代币的增发和销毁功能。
 */

contract ERC20 is IERC20 {
    uint public totalSupplys;
    string public name;
    string public symbol;
    uint8 public decimals = 18; // 小数位数

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;

    constructor(uint _initialSupply, string memory _name, string memory _symbol) {
        totalSupplys = _initialSupply;
        balances[msg.sender] = _initialSupply;
        name = _name;
        symbol = _symbol;
    }

    error insufficientBalance(address account, uint balance, uint amount);

    // 查询代币总量
    function totalSupply() external view override returns (uint256) {
        return totalSupplys;
    }

    // 查询余额
    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    // 户主直接转账
    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(this) && to != address(0), "ERC20: transfer to the contract address or zero address is not allowed");
        if (allowances[msg.sender][to] < amount) {
            revert insufficientBalance(to, allowances[msg.sender][to], amount);
        }

        if (amount > balances[msg.sender]) {
            revert insufficientBalance(msg.sender, balances[msg.sender], amount);
        }
        balances[to] += amount;
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 查询授权
    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    // 授权
    function approve(address spender, uint256 amount) external override returns (bool) {
        if (balances[msg.sender] < amount) {
            revert insufficientBalance(msg.sender, balances[msg.sender], amount);
        }
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 转账
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(to != address(this) && to != address(0), "ERC20: transfer to the contract address or zero address is not allowed");
        if (allowances[from][to] < amount) {
            revert insufficientBalance(from, allowances[from][to], amount);
        }
        allowances[from][to] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // 铸币
    function mint(uint amount) external {
        totalSupplys += amount;
        balances[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // 销币
    function burn(uint amount) external {
        if (balances[msg.sender] < amount) {
            revert insufficientBalance(msg.sender, balances[msg.sender], amount);
        }
        balances[msg.sender] -= amount;
        totalSupplys -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
