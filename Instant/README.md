<div align="center">
  <h1>Instant Guide</h1>
  <br/>
</div>

Before start, make sure you are inside the Instant directory on the terminal

# 1. Dependency Setup

Check Common Guide's [Dependency Setup Section](../setup.md#1.-Dependency-Setup)

## Install the dependencies

```
LIP_ID="Instant"
cd $HOME/coin/
git checkout $LIP_ID
cd $LIP_ID
npm install
```

# 2. Environment Variables (Accounts & Keys Setup)

Check Common Guide's [Setup Environment Variables Section](<../README.md#2.-Environment-Variables-(Accounts-&-Keys-Setup)>)

# 3. Testnet used and faucet references

Check Common Guide's [Testnet used and faucet references Section](../README.md#3.-Testnet-used-and-faucet-references)

# 4. Compile and Unit Testing

## Compile the smart contract with the provided command

```
 $ npm run build

 > inst@1.0.0 prebuild /in-st/coin/Instant
 > rimraf ./build/contracts/*


 > inst@1.0.0 build /in-st/coin/Instant
 > truffle compile

 Using env var PRIVATE_KEY conn...
 Using env var INFURA_APIKEY 7591...
 Using env var process.env.ETHERSCAN_APIKEY 0987...

 Compiling your contracts...
 ===========================
 > Compiling ./contracts/InstToken.sol
 > Compiling ./contracts/Migrations.sol
 > Compiling openzeppelin-solidity/contracts/GSN/Context.sol
 > Compiling openzeppelin-solidity/contracts/access/Ownable.sol
 > Compiling openzeppelin-solidity/contracts/math/SafeMath.sol
 > Compiling openzeppelin-solidity/contracts/token/ERC20/ERC20.sol
 > Compiling openzeppelin-solidity/contracts/token/ERC20/IERC20.sol
 > Compiling openzeppelin-solidity/contracts/utils/Address.sol
 > Artifacts written to /Users/mac/Documents/Work/in-st/coin/Instant/build/contracts
 > Compiled successfully using:
    - solc: 0.6.2+commit.bacdbe57.Emscripten.clang
```

## Test the smart contract with the provided command. All testing should be passed

```
 create a keypair with metamask and fund it.
 paste private key into a file:
 $ geth account import new.key
^ it will ask for a password, it can be blank
 $ geth --rpc --rpcapi db,eth,net,web3,personal --unlock="0x8ba35d564b35345bca5471f63aa1f98a544b70aa" --testnet --allow-insecure-unlock --keystore ~/.ethereum/keystore/
^ will ask for the same password to unlock the keystore.
 $ npm run test

 > inst@1.0.0 test /in-st/coin/Instant
 > truffle test

 Using env var PRIVATE_KEY conn...
 Using env var INFURA_APIKEY 7591...
 Using env var process.env.ETHERSCAN_APIKEY 0987...
 Using network 'test'.

 Compiling your contracts...
 ===========================
 > Everything is up to date, there is nothing to compile.

 Contract: InstToken Test
    totalSupply
      ✓ all tokens should be in the deployer account
    blacklist
      ✓ should NOT be able to add 0x0 to the blacklist
      ✓ should NOT be able to remove 0x0 from the blacklist
      ✓ should NOT be able to add/remove blacklist without owner permission (99ms)
      ✓ should add to blacklist (68ms)
      ✓ should remove from blacklist (61ms)

```

# 5. Example Deployment and expected output

## Deploy to Local Testnet

```
npm run build & npm run deploy:development
```

## Deploy to Kovan testnet

Make sure the private key has enough test ether on the Kovan test network to fund the deployment transactions.

```
$ npm run build & npm run deploy:kovan
Using env var PRIVATE_KEY prai...
Using env var INFURA_APIKEY 7591...
Using env var process.env.ETHERSCAN_APIKEY 0987...

Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.



Starting migrations...
======================
> Network name:    'kovan'
> Network id:      42
> Block gas limit: 12500000 (0xbebc20)


1_initial_migration.js
======================

   Deploying 'Migrations'
   ----------------------
   > transaction hash:    0x9e15c6376ea7d4c2aa36006fd751fec9e88096967b341bd6fe442bde9dab6b3c
   > Blocks: 5            Seconds: 21
   > contract address:    0x25B942b96a25eaAb5e9E5640444F17AD8e10c59c
   > block number:        20974338
   > block timestamp:     1600344328
   > account:             0x25bfE1d866e7288E2Ed7bb97De42cb8F3A07Dd90
   > balance:             0.99662996
   > gas used:            168502 (0x29236)
   > gas price:           20 gwei
   > value sent:          0 ETH
   > total cost:          0.00337004 ETH


   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:          0.00337004 ETH


2_deploy_contract.js
====================

   Deploying 'InstToken'
   ---------------------
   > transaction hash:    0xfd0dbea4735b36e4a59c2f2c48febd2d905e9b5a8405c5c6a7a69a5c6d8f5d1b
   > Blocks: 1            Seconds: 6
   > contract address:    0x982D5EC2f486b7cd7C31BD1d2299e94cAfE036cf
   > block number:        20974347
   > block timestamp:     1600344364
   > account:             0x25bfE1d866e7288E2Ed7bb97De42cb8F3A07Dd90
   > balance:             0.97041096
   > gas used:            1268671 (0x135bbf)
   > gas price:           20 gwei
   > value sent:          0 ETH
   > total cost:          0.02537342 ETH


   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:          0.02537342 ETH


Summary
=======
> Total deployments:   2
> Final cost:          0.02874346 ETH
```

In this example the smart contract was deployed to the address `0x982D5EC2f486b7cd7C31BD1d2299e94cAfE036cf` on the Kovan Test network. The address `0x25bfE1d866e7288E2Ed7bb97De42cb8F3A07Dd90` gained ownership to the smart contract and received 300000000 tokens.

## Verification

In order to verify your smart contract on etherscan.io execute the verification script immediately after the contract is successfully deployed and pass the contract name as the argument.

```
$ npm run verify:kovan -- InstToken
> inst@1.0.0 verify:kovan /home/mac/Desktop/coin/Instant
> truffle run verify InstToken --network kovan

Using env var PRIVATE_KEY prai...
Using env var INFURA_APIKEY 7591...
Using env var process.env.ETHERSCAN_APIKEY SFP4...
Verifying InstToken
Pass - Verified: https://kovan.etherscan.io/address/0x982D5EC2f486b7cd7C31BD1d2299e94cAfE036cf#contracts
Successfully verified 1 contract(s).
```

## Screenshot on Etherscan

![Contract](doc/contract.png)

# 6. Instructions for interacting with the contract

## Check if all tokens (300,000,000 inst) is in the deployed account

Add inst token as a custom token in your MetaMask wallet

1.  Click `Add Token` Button on your MetaMask
2.  On the `Add Token` page, click on `Add custom token` to expand the search window.
3.  Enter token address `0x982D5EC2f486b7cd7C31BD1d2299e94cAfE036cf` in the space under `Token Address`.
4.  Click next to proceed

![MetaMask](doc/metamask_initial.png)

## The token should be freezed at first and the transfer should be rejected

1.  Try to send any amount of tokens from the deployed account to other address
    ![MetaMask_Try_Send_Freeze](doc/metamask_try_send_freeze.png)
2.  The transaction should be failed because the token is freezed and the recipient address is not whitelisted. (The deployer address is whitelisted as default)
    ![MetaMask_Fail_Transaction_1](doc/metamask_fail_transaction_1.png)

Lets generate ABI so that we can interact with the contract:

```
apt-get install xclip
npm install -g truffle-export-abi
truffle-export-abi
cat ./build/ABI.json | xclip -selection c
```

Output should be a long peace of JSON formatted text, that can be copied also from [here](./ABI.json)

ABI we can now input into any wallet like MEW to interact with the contract

## Once unfreeze the token, it should be able to transfer freely

1.  Only token owner can unfreeze the token.
    ![Contract_Unfreeze](doc/contract_unfreeze.png)
2.  Try to send any amount of tokens between any accounts
    ![Contract_Transfer_Success](doc/contract_transfer_success.png)

## Freeze the token transfer and configure list of addresses to whitelist

1.  Only token owner can freeze the token
    ![Contract_Freeze](doc/contract_freeze.png)
2.  Configure whitelist. (Only owner can configure whitelist)
    ![Contract_Whitelist](doc/contract_whitelist.png)
3.  Should be able to transfer between whitelisted addresses even if the token transfer is freezed
    ![Contract_Transfer_Success_Whitelisted](doc/contract_transfer_success_whitelisted.png)
    ![Contract_Transfer_Success_Whitelisted_2](doc/contract_transfer_success_whitelisted_2.png)

## Compatibility with uniswap v2

    Make sure the token transfer is not freezed

1. Add Liquidity to Uniswap (https://app.uniswap.org/#/pool)
   ![Uniswap](doc/uniswap_initial.png)
2. Select token pairs (ETH & inst). Select inst token by searching with inst contract address
   ![Uniswap_Select_Token](doc/uniswap_select_token.png)
3. Our pool

   ![Uniswap_Pool](doc/uniswap_pool.png)

# TODO

- [x] TODO: Update readme as whitelist method changed
- [x] TODO: Add more unit testing
