const inst = artifacts.require("./token/inst.sol")

module.exports = function (deployer) {
  /**
   * add the desired token to the next line
   * @example
   * deployer.deploy(inst)
   */

  deployer.deploy(inst)
}
