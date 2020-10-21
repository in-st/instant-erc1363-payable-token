require('chai/register-should');
require('dotenv').config()

const HDWalletProvider = require('truffle-hdwallet-provider')
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

//const HDWalletProvider = require('truffle-hdwallet-provider')
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

module.exports = {
  migrations_directory: "./allMyStuff/someStuff/theMigrationsFolder",
  /*networks: {
    development: {
      host: 'localhost',
      port: 8545,
      gas: 6700000,
      network_id: '*', // eslint-disable-line camelcase
    },
    coverage: {
      host: 'localhost',
      network_id: '*', // eslint-disable-line camelcase
      port: 8545,
      gas: 6700000,
      gasPrice: 0x01,
    },
  },*/
  compilers: {
    solc: useSolcNightly ? solcNightly : solcStable,
  },
  plugins: ['solidity-coverage','truffle-plugin-verify'],
  api_keys: {
    etherscan: process.env.ETHERSCAN_APIKEY,
  },
  networks: {
    private: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, process.env.PRIVATE_NETWORK_URL),
      gas: 0, // example settings for "ethereum-free" networks.
      gasPrice: 0,
      network_id: process.env.PRIVATE_NETWORK_ID,
    },

    // Useful for deploying to a public network.
    ropsten: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, `https://ropsten.infura.io/v3/${process.env.INFURA_APIKEY}`),
      network_id: 3, // Ropsten's id
      gas: 6700000,        // Ropsten has a lower block limit than mainnet
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },

    kovan: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, `https://kovan.infura.io/v3/${process.env.INFURA_APIKEY}`),
      network_id: 42, // Kovan's id
      // gas: 5500000,
      // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },

    mainnet: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, `https://mainnet.infura.io/v3/${process.env.INFURA_APIKEY}`),
      network_id: 1,
      gas: 6500000, // Default gas to send per transaction
      gasPrice: 10000000000, // 10 gwei
      confirmations: 0,
    },
  },
    mocha: {
      useColors: true
    }
};
