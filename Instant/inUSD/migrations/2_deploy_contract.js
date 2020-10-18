const inUSD = artifacts.require("./inUSD.sol")

module.exports = function (deployer) {
  /**
   * add the desired token to the next line
   * @example
   * deployer.deploy(InstToken)
   */

  deployer.deploy(inUSD)
}
