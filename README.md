Subscription Module
This is a Sui smart contract module that implements a subscription system. It allows users to subscribe to a service and make payments, while also providing functionality for administrators to manage the subscriptions.

Features
User Management: The module allows the creation of user accounts and tracks whether a user is subscribed or not.
Subscription Management: Users can subscribe to a service by providing a deposit and a subscription period. The module keeps track of the subscription details, including the start and end time, the last payment time, and whether the subscription is active or not.
Payment: Users can make payments to their subscription, which will update the deposit balance.
Subscription Transfer: Users can transfer their subscription to another address, as long as the new address has enough balance.
Subscription Deletion: Users can unsubscribe from the service, which will mark their subscription as inactive.
Subscription Viewing: The module provides functions to view the details of a user's subscription, as well as the list of active and ended subscriptions.
Subscription Duration: The module can calculate the duration of a subscription.
Subscription Claim: When a subscription ends, the user can claim the remaining deposit balance.
