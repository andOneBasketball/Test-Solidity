const { ethers } = require("hardhat");
const { assert, expect } = require("chai");
const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

const NFTtokenId = 3;
const startingPrice = 1000000; // 100w wei
const discountRate = 1;

const auctionEndPattern = /[\w:\s]*'AuctionEnded\("Auction ended"\)'$/

describe("dutchAuction", function () {
    async function deployDutchAuctionFixture() {
        const [sellerAddress, buyerAddress] = await ethers.getSigners();

        const rocketToken = await ethers.deployContract("RocketNFT");
        await rocketToken.mint(sellerAddress.address, NFTtokenId);
        const dutchAuction = await ethers.deployContract("DutchAuction", [rocketToken.target, sellerAddress.address, NFTtokenId, startingPrice, discountRate]);
        let sellerBalance = await ethers.provider.getBalance(sellerAddress.address);
        let buyerBalance = await ethers.provider.getBalance(buyerAddress.address);
        console.log(`Deploy dutchAuction contract at ${dutchAuction.target}, NFT token id is ${NFTtokenId}, seller address is ${sellerAddress.address} ${sellerBalance}, buyer address is ${buyerAddress.address} ${buyerBalance}, starting price is ${startingPrice}, discount rate is ${discountRate}`);

        // Fixtures can return anything you consider useful for your tests
        return {rocketToken, dutchAuction, sellerAddress, buyerAddress};
    }

    it(`get price of NFT less than starting price ${startingPrice}`, async function () {
        const {_, dutchAuction} = await loadFixture(deployDutchAuctionFixture);

        await time.increaseTo((await time.latest()) + 60*60);
        const currentPrice = await dutchAuction.getPrice();
        console.log(`Current price is ${currentPrice}`);

        expect(currentPrice).to.be.lt(startingPrice);
    });

    it("auction end test", async function () {
        const {_, dutchAuction} = await loadFixture(deployDutchAuctionFixture);
        await time.increaseTo((await time.latest()) + 7*24*60*60);
        try {
            await dutchAuction.getPrice();
        } catch (error) {
            console.log(`getPrice failed, error is ${error.message}`);
            expect(auctionEndPattern.test(error.message)).to.be.equal(true);
        }
    });

    it("get balance test", async function () {
        const {rocketToken, dutchAuction, sellerAddress, buyerAddress} = await loadFixture(deployDutchAuctionFixture);

        const balance = await dutchAuction.connect(buyerAddress).getBalance();
        console.log(`${buyerAddress.address} balance is ${balance}`);
        
        expect(balance).to.be.equal(ethers.parseEther("10000"));
    });

    it(`buy NFT`, async function () {
        const {rocketToken, dutchAuction, _, buyerAddress} = await loadFixture(deployDutchAuctionFixture);
        let valueToBuy = 100000;
        await time.increaseTo((await time.latest()) + 60*60);
        const currentPrice = await dutchAuction.getPrice();
        console.log(`Current price is ${currentPrice}`);
        try {
            await dutchAuction.connect(buyerAddress).buy({value: valueToBuy});
        } catch (error) {
            console.log(`failed to buy NFT with value ${valueToBuy}, error is ${error.message}`);
        }
        valueToBuy = ethers.parseUnits("1", "gwei");
        try {
            await dutchAuction.connect(buyerAddress).buy({value: valueToBuy});
        } catch (error) {
            console.log(`failed to buy NFT with value ${valueToBuy}, error is ${error.message}`);
        }
        const ownerAddress = await rocketToken.ownerOf(NFTtokenId);
        expect(ownerAddress).to.be.equal(buyerAddress.address);
        let buyerBalance = await ethers.provider.getBalance(buyerAddress.address);
        console.log(`current NFT owner address is ${buyerAddress.address}, balance is ${buyerBalance}`);

        try {
            await dutchAuction.connect(buyerAddress).buy({value: valueToBuy});
        } catch (error) {
            console.log(`buy failed, error is ${error.message}`);
            expect(auctionEndPattern.test(error.message)).to.be.equal(true);
        }
    });
});
