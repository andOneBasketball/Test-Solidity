// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract MutiSignWallet {
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    uint public balance;                                           //多签钱包余额
    address[] private owners;                                      //多签钱包持有者列表
    mapping(address => bool) private isOwner;                      //是否是多签钱包的持有者
    mapping(address => mapping(uint => bool)) private isApproved;  //是否已批准
    uint private threshold;                                        //多签交易的门槛
    uint private txid = 0;                                         //生成的交易ID,自增id
    uint[] public txidList;                                        //待执行的交易ID列表
    mapping(uint => Transaction) private transactions;             //交易ID与交易数据的映射
    uint public maxOwners;                                         //最大持有者数量

    event Deposit(address indexed owner, uint256 value);                                      //存款事件
    event Submit(address indexed owner, uint256 value);                                       //提交交易事件
    event Approve(address indexed owner, uint256 value);                                      //批准交易事件
    event Execute(address indexed owner, address indexed to, uint256 value, bytes data);      //执行交易事件
    event Revoke(address indexed owner, uint256 value);                                       //撤销批准
    event OwnerAdded(address indexed owner);                                                  //添加持有者事件
    event OwnerRemoved(address indexed owner);                                                //移除持有者事件

    error NotAllowExecute(string message);
    error ExecuteFailed(string message);

    // 仅允许多签钱包持有者
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    // 交易id存在
    modifier txExists(uint _txid) {
        require(transactions[_txid].to != address(0), "txid not exists");
        _;
    }

    // 交易未执行且未被批准
    modifier notApproved(uint _txid) {
        require(isApproved[msg.sender][_txid] == true, "not approved");
        require(transactions[_txid].executed == false, "tx not executed");
        _;
    }

    receive() external payable {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    constructor(address[] memory _owners, uint _maxOwners) {
        require(_owners.length > 0, "owners is empty");
        require(_owners.length <= _maxOwners, "owners is too many");
        for (uint i; i < _owners.length; i++) {
            require(!isOwner[_owners[i]], "owner already exists");
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
        _getthreshold();
        maxOwners = _maxOwners;
    }

    function _getthreshold() private {
        if (owners.length <= 2) {
            threshold = owners.length;
        } else {
            threshold = owners.length / 2 + 1;
        }
    }

    // 提交交易信息，交易入队
    function submit(address _to, uint256 _value, bytes memory _data) external payable onlyOwner returns(uint) {
        require(balance + msg.value >= _value, "not enough balance");
        require(_to != address(0), "to address is zero");
        require(_value > 0, "value is zero");
        transactions[txid] = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        });
        txidList.push(txid);
        // 提交交易信息的拥有者默认允许交易
        isApproved[msg.sender][txid] = true;
        emit Submit(msg.sender, _value);
        txid++;
        return(txid - 1);
    }

    // 授权交易
    function approve(uint _txid) external onlyOwner txExists(_txid) {
        isApproved[msg.sender][_txid] = true;
        emit Approve(msg.sender, transactions[_txid].value);
    }

    // 一键授权所有交易
    function approveAll() external onlyOwner {
        for (uint i; i < txidList.length; i++) {
            isApproved[msg.sender][txidList[i]] = true;
            emit Approve(msg.sender, transactions[txidList[i]].value);
        }
    }

    function _removeTxid(uint _txid) private txExists(_txid) {
        for (uint i; i < txidList.length; i++) {
            if (txidList[i] == _txid) {
                txidList[i] = txidList[txidList.length - 1];
                txidList.pop();
                break;
            }
        }
    }

    //执行交易
    function execute(uint _txid) public onlyOwner txExists(_txid) {
        require(isApproved[msg.sender][_txid] == true, "not approved");
        require(transactions[_txid].executed == false, "tx already executed");
        // 遍历该交易的批准数量
        uint count = 0;
        for (uint i; i < owners.length; i++) {
            if (isApproved[owners[i]][_txid] == true) {
                count++;
            }
            if (count >= threshold) {
                break;
            }
        }
        if (count < threshold) {
            revert NotAllowExecute("not enough approved");
        }
        (bool success, bytes memory reData) = payable(transactions[_txid].to).call{value: transactions[_txid].value}(transactions[_txid].data);
        if (success) {
            // 暂不考虑交易ID重入的冲突问题，因此暂不考虑将 isApproved 中已交易的数据清除
            balance -= transactions[_txid].value;
            transactions[_txid].executed = true;
            _removeTxid(_txid);
            emit Execute(msg.sender, transactions[_txid].to, transactions[_txid].value, transactions[_txid].data);
        } else {
            revert ExecuteFailed(string(reData));
        }
    }

    // 撤销批准
    function revoke(uint _txid) external onlyOwner txExists(_txid) {
        require(isApproved[msg.sender][_txid] == true, "not approved");
        isApproved[msg.sender][_txid] = false;
        emit Revoke(msg.sender, transactions[_txid].value);
    }

    // 增加多签钱包持有者
    function addOwner(address _owner) external onlyOwner {
        require(isOwner[_owner] == false, "owner already exists");
        require(owners.length < maxOwners, "owners is too many");
        owners.push(_owner);
        isOwner[_owner] = true;
        _getthreshold();
        emit OwnerAdded(_owner);
    }

    // 移除多签钱包持有者
    function removeOwner(address _owner) external onlyOwner {
        require(isOwner[_owner] == true, "owner not exists");
        for (uint i; i < owners.length; i++) {
            if (owners[i] == _owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
        for (uint i; i < txidList.length; i++) {
            if (isApproved[_owner][txidList[i]] == true) {
                delete isApproved[_owner][txidList[i]];
            }
        }
        _getthreshold();
        emit OwnerRemoved(_owner);
    }
}
