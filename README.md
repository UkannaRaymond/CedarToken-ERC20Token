# CedarToken (CT)

CedarToken is a simple, fixed-supply ERC-20 token built with Solidity and
[OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts).
The repository uses [Foundry](https://book.getfoundry.sh/) for building,
testing, and deployment.

## Token details

| Property | Value |
| --- | --- |
| Name | CedarToken |
| Symbol | CT |
| Decimals | 18 |
| Deployment supply | 1,000 CT |
| Mint recipient | The deploying address |

The `CedarToken` constructor accepts the initial supply in the smallest unit
(wei-style token units) and mints it to `msg.sender`. The deployment script
passes `1000 ether`, which is `1,000 × 10^18` base units, or 1,000 CT with 18
decimals.

There is no public mint or burn function, owner role, or additional supply
mechanism. The contract inherits the standard ERC-20 transfer and allowance
behavior from OpenZeppelin.

## Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`,
  `cast`, and `anvil`)
- Git

## Build and test

Install the repository's pinned dependencies if they are not already present,
then build and run the test suite:

```shell
forge install
forge build
forge test
```

Format Solidity files with:

```shell
forge fmt
```

## Deploy locally

Start a local Anvil node in one terminal:

```shell
anvil
```

In another terminal, deploy CedarToken to the local node:

```shell
forge script script/DeployCedarToken.s.sol:DeployCedarToken \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <ANVIL_PRIVATE_KEY> \
  --broadcast
```

The repository's Makefile also provides `make deploy`, which uses Anvil's
publicly known default development key. Use that target only with a local Anvil
node; never use the default key on a public network.

## Deploy to Sepolia

The Makefile's `deploy-sepolia` target expects these values in a local `.env`
file:

```dotenv
SEPOLIA_RPC_URL=https://your-sepolia-rpc
ACCOUNT=your-foundry-keystore-account
SENDER=your-deployer-address
ETHERSCAN_API_KEY=your-etherscan-api-key
```

Then run:

```shell
make deploy-sepolia
```

The command uses Foundry's encrypted keystore account, broadcasts the
deployment, and requests Etherscan verification. Ensure the account is
configured in Foundry and funded with Sepolia ETH. Keep `.env` and all private
keys out of version control; do not put a real private key in shell history or
the README.

## Project layout

```text
src/CedarToken.sol                  CedarToken ERC-20 implementation
src/ManualToken.sol                 Separate manual ERC-20 learning example
script/DeployCedarToken.s.sol       Deployment script (1,000 CT initial supply)
test/CedarToken.t.sol               CedarToken tests
```

`ManualToken.sol` is an independent example and is not used by the CedarToken
deployment script.

## License

The CedarToken source is provided under the MIT license. OpenZeppelin Contracts
is included as a dependency and is subject to its own license terms.
