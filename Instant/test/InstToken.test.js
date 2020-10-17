const Token = artifacts.require('InstToken')

var chai = require('chai')
const BN = web3.utils.BN
const chaiBN = require('chai-bn')(BN)
chai.use(chaiBN)

var chaiAsPromised = require('chai-as-promised')
const { assert } = require('chai')
chai.use(chaiAsPromised)

const expect = chai.expect

contract('InstToken Test', async function (accounts) {
  const [deployerAccount, account1, account2] = accounts

  let instance

  before(async function () {
    instance = await Token.deployed()
  })

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
    beforeEach(async function () {
      await clearWhitelistdenylist()
    })

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

    before(async function () {
      await makeUnfreeze()
      await clearWhitelistdenylist()
    })

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

  describe('transfer when freezed', function () {
    /*
      - Before all: make the token freezed
      - [x] should NOT be able to transfer (from: denylisted) even if its allow_transfer is true
      - [x] should NOT be able to transfer (to: denylisted) even if its allow_deposit is true
      - [x] should NOT be able to transfer (from: allow_transfer [no], to: allow_deposit [yes])
      - [x] should NOT be able to transfer (from: allow_transfer [yes], to: allow_deposit [no])
      - [x] should transfer (from: allow_transfer [yes], to: allow_deposit [yes])
      - [x] should transfer (from: allow_unconditional_transfer [yes], to: allow_deposit [no])
      - [x] should transfer (from: allow_transfer [no], to: allow_unconditional_deposit [yes])
    */
    before(async function () {
      await makeFreeze()
      await instance.transfer(account1, 1000)
      await instance.transfer(account2, 1000)
    })

    beforeEach(async function () {
      await clearWhitelistdenylist()
    })

    it('should NOT be able to transfer (from: denylisted) even if its allow_transfer is true', async function () {
      // account1 -> account2
      await expect(instance.addTodenylist([account1])).to.eventually.be.fulfilled
      await expect(instance.whitelist([account1], false, true, false, false)).to.eventually.be.fulfilled
      await expect(instance.whitelist([account2], true, false, false, false)).to.eventually.be.fulfilled
      await expect(instance.transfer(account2, 100, { from: account1 })).to.eventually.be.rejectedWith('inst: sender is denylisted')
    })
    it('should NOT be able to transfer (to: denylisted) even if its allow_deposit is true', async function () {
      // account1 -> account2
      await expect(instance.addTodenylist([account2])).to.eventually.be.fulfilled
      await expect(instance.whitelist([account2], false, true, false, false)).to.eventually.be.fulfilled
      await expect(instance.whitelist([account1], true, false, false, false)).to.eventually.be.fulfilled
      await expect(instance.transfer(account2, 100, { from: account1 })).to.eventually.be.rejectedWith('inst: receiver is denylisted')
    })
    it('should NOT be able to transfer (from: allow_transfer [no], to: allow_deposit [yes])', async function () {
      // account1 -> account2
      await expect(instance.whitelist([account1], true, false, false, false)).to.eventually.be.fulfilled
      await expect(instance.whitelist([account2], true, false, false, false)).to.eventually.be.fulfilled
      await expect(instance.transfer(account2, 100, { from: account1 })).to.eventually.be.rejectedWith('inst: token transfer while freezed and not whitelisted.')
    })
    it('should NOT be able to transfer (from: allow_transfer [yes], to: allow_deposit [no])', async function () {
      // account1 -> account2
      await expect(instance.whitelist([account1], false, true, false, false)).to.eventually.be.fulfilled
      await expect(instance.whitelist([account2], false, true, false, false)).to.eventually.be.fulfilled
      await expect(instance.transfer(account2, 100, { from: account1 })).to.eventually.be.rejectedWith('inst: token transfer while freezed and not whitelisted.')
    })
    it('should transfer (from: allow_transfer [yes], to: allow_deposit [yes])', async function () {
      // account1 -> account2
      await expect(instance.whitelist([account1], false, true, false, false)).to.eventually.be.fulfilled
      await expect(instance.whitelist([account2], true, true, false, false)).to.eventually.be.fulfilled
      await expect(instance.transfer(account2, 100, { from: account1 })).to.eventually.be.fulfilled
    })
    it('should transfer (from: allow_unconditional_transfer [yes], to: allow_deposit [no])', async function () {
      // account1 -> account2
      await expect(instance.whitelist([account1], false, false, false, true)).to.eventually.be.fulfilled
      await expect(instance.whitelist([account2], false, false, false, false)).to.eventually.be.fulfilled
      await expect(instance.transfer(account2, 100, { from: account1 })).to.eventually.be.fulfilled
    })
    it('should transfer (from: allow_transfer [no], to: allow_unconditional_deposit [yes])', async function () {
      // account1 -> account2
      await expect(instance.whitelist([account1], false, false, false, false)).to.eventually.be.fulfilled
      await expect(instance.whitelist([account2], false, false, true, false)).to.eventually.be.fulfilled

      const sendTokens = 100
      const oldFromBalance = await instance.balanceOf(account1)
      const oldToBalance = await instance.balanceOf(account2)
      await expect(instance.transfer(account2, sendTokens, { from: account1 })).to.eventually.be.fulfilled
      await expect(instance.balanceOf(account1)).to.eventually.be.a.bignumber.equal(oldFromBalance.sub(new BN(sendTokens)))
      await expect(instance.balanceOf(account2)).to.eventually.be.a.bignumber.equal(oldToBalance.add(new BN(sendTokens)))
    })
  })

  describe('multi transfer', function () {
    /*
      - Before all: make the token unfreezed
      - [x] should be able to transfer to multiple accounts
    */

    before(async function () {
      await makeUnfreeze()
    })

    it('should be able to transfer to multiple accounts', async function () {
      // deployer -> account1, account2

      const sendTokens = 100
      const oldFromBalance = await instance.balanceOf(deployerAccount)
      const oldToBalance1 = await instance.balanceOf(account1)
      const oldToBalance2 = await instance.balanceOf(account2)
      await expect(instance.multiTransfer([account1, account2], sendTokens)).to.eventually.be.fulfilled

      await expect(instance.balanceOf(deployerAccount)).to.eventually.be.a.bignumber.equal(oldFromBalance.sub(new BN(sendTokens * 2)))
      await expect(instance.balanceOf(account1)).to.eventually.be.a.bignumber.equal(oldToBalance1.add(new BN(sendTokens)))
      await expect(instance.balanceOf(account2)).to.eventually.be.a.bignumber.equal(oldToBalance2.add(new BN(sendTokens)))
    })
  })
})
