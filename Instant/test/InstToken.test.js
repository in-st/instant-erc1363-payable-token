const Token = artifacts.require('inUSD')
//var Adoption = artifacts.require(process.env.COIN_TYPE);
//var Adoption = artifacts.require("../inUSD/inUSD");


var chai = require('chai')
const BN = web3.utils.BN
const chaiBN = require('chai-bn')(BN)
chai.use(chaiBN)

var chaiAsPromised = require('chai-as-promised')
const { assert } = require('chai')
chai.use(chaiAsPromised)

const expect = chai.expect

contract('inst - test', async function (accounts) {
  const [deployerAccount, account1, account2] = accounts

  let instance

  before(async function () {
    instance = await Token.deployed()
  })

/*
  async function makeFreeze() {
    const freezed = await instance.freezed()
    if (!freezed) {
      await instance.freeze()
    }
  }

  async function makeUnfreeze() {
    const freezed = await instance.freezed()
    if (freezed) {
      await instance.unfreeze()
    }
  }

  async function clearWhitelistdenylist() {
    await instance.whitelist([account1, account2], true, true, true, true)
    await instance.removeFromdenylist([account1, account2])
  }
*/
  describe('totalSupply', function () {
    /*
      - [x] all tokens should be in the deployer account
    */
    it('all tokens should be in the deployer account', async function () {
      let totalSupply = await instance.totalSupply()
      await expect(instance.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(totalSupply)
    })
  })

  describe('denylist', async function (done) {
    /*
      - [x] should NOT be able to add 0x0 to the denylist
      - [x] should NOT be able to remove 0x0 from the denylist
      - [x] should NOT be able to add/remove denylist without owner permission
      - [x] should add to denylist
      - [x] should remove from denylist
    */
/*    beforeEach(async function () {
      await clearWhitelistdenylist()
    })
*/
    it('should NOT be able to add 0x0 to the denylist', async function () {
      await expect(instance.addTodenylist([account1, 0])).to.eventually.be.rejected
    })
    it('should NOT be able to remove 0x0 from the denylist', async function () {
      await expect(instance.removeFromdenylist([account1, 0])).to.eventually.be.rejected
    })
    it('should NOT be able to add/remove denylist without owner permission', async function () {
      await expect(instance.addTodenylist([account1], { from: account1 })).to.eventually.be.rejected
      await expect(instance.removeFromdenylist([account1], { from: account1 })).to.eventually.be.rejected
    })
    it('should add to denylist', async function () {
      await expect(instance.addTodenylist([account1, account2])).to.eventually.be.fulfilled
      await expect(instance.denylisted(account1)).to.eventually.equal(true)
      await expect(instance.denylisted(account2)).to.eventually.equal(true)
    })
    it('should remove from denylist', async function () {
      await expect(instance.removeFromdenylist([account1, account2])).to.eventually.be.fulfilled
      await expect(instance.denylisted(account1)).to.eventually.equal(false)
      await expect(instance.denylisted(account2)).to.eventually.equal(false)
    })
  })

  describe('transfer when unfreezed', function () {
    /*
      - Before all: make token unfreezed
      - [x] should NOT be able to transfer (from: denylisted)
      - [x] should NOT be able to transfer (to: denylisted)
      - [x] should transfer (from: denylisted [no], to: denylisted [no])
    */
/*
    before(async function () {
      await makeUnfreeze()
      await clearWhitelistdenylist()
    })
*/
    it('should NOT be able to transfer (from: denylisted)', async function () {
      // send some funds to account1
      await expect(instance.transfer(account1, 1000)).to.eventually.be.fulfilled

      // make account1 as denylisted
      await expect(instance.addTodenylist([account1])).to.eventually.be.fulfilled
      await expect(instance.transfer(deployerAccount, 100, { from: account1 })).to.eventually.be.rejectedWith('inst: sender is denylisted')
    })

    it('should NOT be able to transfer (to: denylisted)', async function () {
      // make account1 as denylisted
      await expect(instance.addTodenylist([account1])).to.eventually.be.fulfilled
      await expect(instance.transfer(account1, 100)).to.eventually.be.rejectedWith('inst: receiver is denylisted')
    })

    it('should transfer (from: denylisted [no], to: denylisted [no])', async function () {
      await expect(instance.removeFromdenylist([account1])).to.eventually.be.fulfilled
      await expect(instance.transfer(account2, 100, { from: account1 })).to.eventually.be.fulfilled
    })
  })

})
