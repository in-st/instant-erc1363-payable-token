const inGold = artifacts.require("./inGold.sol")

module.exports = function (deployer) {
  /**
   * add the desired token to the next line
   * @example
   * deployer.deploy(InstToken)
   */

  deployer.deploy(inGold)
}
