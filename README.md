# Seer Airdrop contracts

This repository contains smart contracts and scripts for distributing Seer credits to participants.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed

## Environment Setup

1. Clone this repository
2. Create a `.env` file in the root directory with the following variables:

```
PRIVATE_KEY=                     # Your wallet's private key for deploying contracts
GOVERNED_RECIPIENT_ADDRESS=      # Address of the deployed GovernedRecipient contract (needed for adding recipients)
GNOSISSCAN_API_KEY=             # API key from https://gnosisscan.io to verify contracts
```

## Deploy contracts

`forge script script/Deploy.s.sol:Deploy --rpc-url gnosis --broadcast --verify -vvvv --etherscan-api-key gnosis`

## Create recipients.json

Use the `recipients.json.dist` file as template.

## Add recipients

`forge script script/AddRecipients.s.sol:AddRecipients --rpc-url gnosis --broadcast -vvvv --via-ir`
