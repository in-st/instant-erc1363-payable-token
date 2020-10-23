const Web3 = require('web3');
const Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {

  const web3 = new Web3(new Web3.providers.HttpProvider('http://' + process.env.GETH_HOST + ':' + process.env.GETH_PORT));
  console.log('>> Unlocking account ' + config.from);
  web3.eth.personal.unlockAccount(config.from, process.env.ACCOUNT_PASSWORD, 36000);

  deployer.deploy(Migrations);
};
