/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like truffle-hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura API
 * keys are available for free at: infura.io/register
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */
require('chai/register-should');
require('dotenv').config()

const solcStable = {
  version: '0.7.1',
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};

const solcNightly = {
  version: 'nightly',
  docker: true,
};

const useSolcNightly = process.env.SOLC_NIGHTLY === 'true';

const abbrv = (str) => `${str.substr(0, 4)}...`

if (!process.env.PRIVATE_KEY) {
  throw new Error('define PRIVATE_KEY in .env first!')
} else {
  console.log('Using env var PRIVATE_KEY', abbrv(process.env.PRIVATE_KEY))
}
if (process.env.INFURA_APIKEY) {
  console.log('Using env var INFURA_APIKEY', abbrv(process.env.INFURA_APIKEY))
}
if (process.env.PRIVATE_NETWORK_URL) {
  console.log('Using env var PRIVATE_NETWORK', process.env.PRIVATE_NETWORK_URL)
}
if (process.env.PRIVATE_NETWORK_ID) {
  console.log('Using env var PRIVATE_NETWORK_ID', process.env.PRIVATE_NETWORK_ID)
}
if (process.env.ETHERSCAN_APIKEY) {
  console.log('Using env var process.env.ETHERSCAN_APIKEY', abbrv(process.env.ETHERSCAN_APIKEY))
}
//const HDWalletProvider = require('truffle-hdwallet-provider')

module.exports = {
  //migrations_directory: "../migrations",
  plugins: ['solidity-coverage','truffle-plugin-verify'],
  api_keys: {
    etherscan: process.env.ETHERSCAN_APIKEY,
  },
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */
  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    development: {
      host: process.env.GETH_HOST ,
      port: process.env.GETH_PORT,
      gas: 7500000,
      network_id: '*',
    },

    // Useful for private networks
    // private: {
    // port: 8777,             // Custom port
    // network_id: 1342,       // Custom network
    // gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
    // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
    // from: <address>,        // Account to send txs from (default: accounts[0])
    // websockets: true        // Enable EventEmitter interface for web3 (default: false)
    // production: true    // Treats this network as if it was a public net. (default: false)
    // },
    private: {
      host: process.env.GETH_HOST,
      port: process.env.GETH_PORT,
      gas: 0, // example settings for "ethereum-free" networks.
      gasPrice: 0,
      network_id: process.env.PRIVATE_NETWORK_ID,
    },

    // Useful for deploying to a public network.
    ropsten: {
      host: process.env.GETH_HOST,
      port: process.env.GETH_PORT,
      //provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, `https://ropsten.infura.io/v3/${process.env.INFURA_APIKEY}`),
      network_id: 3, // Ropsten's id
      gas: 0,        // Ropsten has a lower block limit than mainnet
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },

    kovan: {
      host: process.env.GETH_HOST,
      port: process.env.GETH_PORT,
      //provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, `https://kovan.infura.io/v3/${process.env.INFURA_APIKEY}`),
      network_id: 42, // Kovan's id
      // gas: 5500000,
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },

    mainnet: {
      host: process.env.GETH_HOST,
      port: process.env.GETH_PORT,
      //provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, `https://mainnet.infura.io/v3/${process.env.INFURA_APIKEY}`),
      network_id: 1,
      gas: 7500000, // Default gas to send per transaction
      gasPrice: 10000000000, // 10 gwei
      confirmations: 0,
    },
  },
  // Set default mocha options here, use special reporters etc.
  mocha: {},
  compilers: {
    solc: useSolcNightly ? solcNightly : solcStable,
  },
}
