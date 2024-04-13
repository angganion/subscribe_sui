# Subscription With SUI Blockchain

This is a Sui smart contract that manages subscriptions for a platform. The contract allows users to subscribe to a service by depositing the required amount of SUI tokens. The contract also provides functionality to handle monthly subscription renewals and subscription management.

## Features

- **New Subscription:** Users can create a new subscription by providing their user ID, subscription period, and price.
- **Transfer Subscription:** Users can transfer a portion of their subscription deposit to the contract.
- **Get Subscription:** Users can subscribe to the service by depositing the required amount of SUI tokens.
- **Monthly Subscription Renewal:** Existing subscribers can renew their subscription by depositing the required amount of SUI tokens.
- **Destroy Subscription:** Subscription owners can destroy their subscription.
- **Subscription Information:** The contract provides functions to retrieve information about subscriptions, such as the end time and active subscriptions for a user.

## Usage

To use this smart contract, you'll need to deploy it to the Sui network. Once deployed, you can interact with the contract using the provided functions.

## Error Codes

The contract defines the following error codes:

- **ERROR_INVALID_CAP:** Indicates an invalid subscription capability.
- **ERROR_INSUFFICIENT_FUNDS:** Indicates insufficient funds to complete the operation.
- **ERROR_NOT_OWNER:** Indicates the user is not the owner of the subscription.
- **ERROR_ALREADY_SUB:** Indicates the user is already subscribed.
- **ERROR_NOT_SUB:** Indicates the user is not subscribed.
- **ERROR_SUB_COMPLETED:** Indicates the subscription has already ended.

## Dependencies

The contract relies on the following Sui modules:

- `sui::sui::SUI`
- `sui::tx_context`
- `sui::coin`
- `sui::balance`
- `sui::transfer`
- `sui::clock`
- `sui::object`
- `sui::table`
