// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "./ERC721.sol";

contract RocketNFT is ERC721, IERC721Metadata {
    string private _name = "SuperRockert";
    string private _symbol = ":rocket:";
    uint MAX_ROCKET_NFTS = 1000;

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_ownerOfToken[tokenId] != address(0), "NFT token not exist");
        return string(abi.encodePacked("https://rocket.nft.com/emoji-cheat-sheet/(:rocket:)", tokenId));
    }

    function mint(address to, uint256 tokenId) external {
        require(tokenId < MAX_ROCKET_NFTS && tokenId >= 0, "Token ID out of range 1000");
        _mint(to, tokenId);
    }

    function burn(address owner, uint256 tokenId) external {
        require(tokenId < MAX_ROCKET_NFTS && tokenId >= 0, "Token ID out of range 1000");
        _burn(owner, tokenId);
    }
}