// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/*
0. message
1. hash(message)
2. sign(hash(message), private key) | offchain
3. ecrecover(hash(message), signature) == signer

ethereum.enable()
account = "0x5639Bc2D96c7bA37EECA625599B183241A2bBE6c"
hash = "0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8"   //(getMessageHash传入 hello 的返回值)
ethereum.request({method: "personal_sign", params: [account, hash]})

编写一个智能合约，实现以下功能：

1. `verify`函数，用于验证签名。
2. `getMessageHash`函数，用于生成消息哈希。
3. `getEthSignedMessageHash`函数，用于生成Ethereum签名消息哈希。
4. `recover`函数，用于恢复签名者地址。
5. `splitSignature`函数，用于拆分签名。
*/

contract VerifySig {
    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns(bool){
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address){
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v){
        require(_sig.length == 65, "invalid signature length");
        // 字节数组在内存中的布局是前32字节用来存储字节数组的长度，后面跟着的字节数组内容。当作为函数的返回值时，EVM会自动略过前32字节的长度信息，直接返回后面的字节数组内容。
        // 所以，这里的_sig[0:32]实际上是长度信息，可以直接忽略。
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}