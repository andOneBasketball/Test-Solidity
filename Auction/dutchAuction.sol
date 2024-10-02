// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;
}

contract DutchAuction {
    address immutable public nftAddress;
    address payable public seller;
    uint256 immutable public tokenId;
    bool public isSold;
    uint256 immutable public startingPrice;
    uint256 immutable public discountRate;
    uint256 immutable public startTime;
    uint256 constant public DURATION = 7 days;
    uint256 public endTime;

    error AuctionEnded(string message);
    event Refund(bool success, uint256 amount);

    modifier auctionEnded() {
        if (block.timestamp >= endTime || isSold) {
            revert AuctionEnded("Auction ended");
        }
        _;
    }

    constructor(address _nftAddress, address payable _seller, uint256 _tokenId, uint256 _startingPrice, uint256 _discountRate) {
        nftAddress = _nftAddress;
        seller = _seller;
        tokenId = _tokenId;
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startTime = block.timestamp;
        endTime = block.timestamp + DURATION;
        require(startingPrice > discountRate * DURATION, "Starting price should be greater than 0");
    }

    function getPrice() public view auctionEnded returns (uint256) {
        return startingPrice - (block.timestamp - startTime) * discountRate;
    }

    function buy() public auctionEnded payable {
        uint256 price = getPrice();
        require(msg.value >= price, "Not enough ether");
        IERC721(nftAddress).transferFrom{value: price}(seller, msg.sender, tokenId);
        uint256 refund = msg.value - price;
        endTime = block.timestamp;
        isSold = true;
        if (refund > 0) {
            (bool success, ) = payable(msg.sender).call{value: refund}("");
            emit Refund(success, refund);
        }
    }

    function getBalance() public view returns (uint256) {
        return address(msg.sender).balance;
    }
}
