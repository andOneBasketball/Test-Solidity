// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";

/*
实现一个简单的ERC721 NFT合约，包含以下功能：

1. 唯一性标识符的代币
2. 所有权管理
3. 交易和流通
4. 符合ERC721标准的接口。balanceOf、ownerOf、safeTransferFrom、transferFrom、approve、setApprovalForAll和isApprovedForAll
5. 代币的可选接口。ERC721Metadata和ERC721Enumerable
6. 实现NFT的增发和销毁功能。
 */

contract ERC721 is IERC721 {
    // NFT tokenId of the user
    mapping(uint256 => address) internal _ownerOfToken;
    // NFT tokenId numbers of the user
    mapping(address => uint256) internal _balanceOf;
    // NFT owner approved to the other user
    mapping(uint256 => address) internal _tokenApprovals;
    // NFT owner approved to the other user all tokenIds
    mapping(address => mapping(address => bool)) _tokenApprovalForAll;

    error ERC721InvaildReceiver(address to);

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) external override view returns (uint256 balance) {
        require(owner != address(0), "zero address not allowed");
        return _balanceOf[owner];
    }

    function ownerOf(uint256 tokenId) public override view returns (address owner) {
        require(_ownerOfToken[tokenId] != address(0), "NFT token not exist");
        return _ownerOfToken[tokenId];
    }

    // 检查接收者是否是合约，如果是，则调用onERC721Received方法
    function _checkERC721Received(address to, address from, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvaildReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvaildReceiver(to);
                } else {
                    assembly {
                        revert(add(reason, 32), mload(reason))
                    }
                }
            }
        }
    }

    function _transfer(address from, address to, uint256 tokenId) private {
        // 允许被授权的用户将NFT转移给其他用户,但NFT的所有者不变。当NFT的所有者是from时，才允许变更NFT的所有者
        require(_ownerOfToken[tokenId] == from ||
            _tokenApprovals[tokenId] == from ||
            _tokenApprovalForAll[_ownerOfToken[tokenId]][from] == true, "NFT not owned by from user or not approved");
        require(to != address(0), "to address is zero");
        
        if (ownerOf(tokenId) == from) {
            _ownerOfToken[tokenId] = to;
        }
        _balanceOf[from]--;
        _balanceOf[to]++;
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable override {
        _checkERC721Received(to, from, tokenId, data);
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function transferFrom(address from, address to, uint256 tokenId) external payable override {
        _transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external payable override {
        require(_ownerOfToken[tokenId] == msg.sender, "NFT not owned by sender");
        _tokenApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function setApprovalForAll(address operator, bool _approved) external override {
        _tokenApprovalForAll[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function getApproved(uint256 tokenId) external view override returns (address operator) {
        require(_ownerOfToken[tokenId] != address(0), "NFT token not exist");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _tokenApprovalForAll[owner][operator];
    }

    function _mint(address to, uint256 tokenId) internal {
        require(_ownerOfToken[tokenId] == address(0), "rocket NFT already exist");
        _ownerOfToken[tokenId] = to;
        _balanceOf[to]++;
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {
        require(_ownerOfToken[tokenId] == owner, "NFT not owned by owner");
        _ownerOfToken[tokenId] = address(0);
        _balanceOf[owner]--;
        emit Transfer(owner, address(0), tokenId);
    }
}
