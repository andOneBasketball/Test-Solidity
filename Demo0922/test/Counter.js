const { ethers } = require("hardhat");
const { assert,expect } = require("chai");

let counter;

function traverseObjectKeys(obj, prefix = '') {  
    for (const key in obj) {  
      if (obj.hasOwnProperty(key)) {  
        const fullPath = prefix ? `${prefix}.${key}` : key;  
        //console.log(fullPath); // 输出键的路径
    
        if (typeof obj[key] === 'object' && obj[key] !== null) {  
            // 如果值是对象且不是null，则递归遍历
            console.log(`object property: ${fullPath}`);
            traverseObjectKeys(obj[key], fullPath);  
        } else if (typeof obj[key] === 'function') {
            console.log(`function property: ${fullPath}`)
        } else {
            console.log(`property: ${fullPath} value: ${obj[key]}`);
        }
      }
    }
  }

describe("Counter", function () {
  async function init() {
    const [owner, otherAccount] = await ethers.getSigners();
    //traverseObjectKeys(owner);
    counter = await ethers.deployContract("Counter");
    ownerBalance = await ethers.provider.getBalance(owner.address);
    console.log(`${ownerBalance}`);
    assert.strictEqual(ownerBalance, ethers.parseEther("10000"));
    console.log("counter:" + counter.target + " owner:" + owner.address + " otherAccount:" + otherAccount.address);
  }

  before(async function () {
    await init();
  });

  // 
  it("init equal 0", async function () {
    expect(await counter.get()).to.equal(0);
  });

  it("add 1 equal 1", async function () {
    let tx = await counter.count();
    await tx.wait();
    expect(await counter.get()).to.equal(1);
  });

});

