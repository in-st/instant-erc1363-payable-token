const inst = artifacts.require("./inst.sol")

module.exports = function (deployer) {
  /**
   * add the desired token to the next line
   * @example
   * deployer.deploy(InstToken)
   */

  deployer.deploy(inst)
}
