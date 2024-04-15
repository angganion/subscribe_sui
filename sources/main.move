module subscription::main {

    // Use various modules from the Sui ecosystem

    use sui::sui::SUI;
    use sui::tx_context::{TxContext, Self, sender};
    use sui::coin::{Coin, Self};
    use sui::balance::{Self, Balance};
    use sui::transfer::Self;
    use sui::clock::{Self, Clock, timestamp_ms};
    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};

    // Define error codes
    const ERROR_INVALID_CAP: u64 = 0;
    const ERROR_INSUFFICIENT_FUNDS: u64 = 1;
    const ERROR_NOT_OWNER: u64 = 2;
    const ERROR_ALREADY_SUB: u64 = 3;
    const ERROR_NOT_SUB: u64 = 4;
    const ERROR_SUB_COMPLETED: u64 = 5;

    // Define the Subscription struct
    struct Subscription has key, store {
        id: UID,
        user_id: u64,
        deposit: Balance<SUI>,
        users: Table<address, bool>,
        price: u64,
        start_time: u64,
        end_time: u64,
        active: bool,
    }

    // Define the SubscriptionCap struct
    struct SubscriptionCap has key {
        id: UID,
        subscription_id: ID,
    }

    // Define the SubRecipient struct
    struct SubRecipient has key {
        id: UID,
        platform: ID,
        month_count: u64,
        owner: address,
    }

    // Create a new subscription
    public fun new_subscribe(user_id: u64, period: u64, price_: u64, c: &Clock, ctx: &mut TxContext) {
        assert!(period > 0, ERROR_INVALID_CAP);

        let id_ = object::new(ctx);
        let inner = object::uid_to_inner(&id_);
        let subscription = Subscription {
            id: id_,
            user_id: user_id,
            deposit: balance::zero(),
            users: table::new(ctx),
            price: price_,
            start_time: timestamp_ms(c),
            end_time: timestamp_ms(c) + period,
            active: true,
        };
        transfer::share_object(subscription);

        let cap = SubscriptionCap {
            id: object::new(ctx),
            subscription_id: inner,
        };
        transfer::transfer(cap, sender(ctx));
    }

    // Transfer a subscription
    public fun transfer_subscribe(cap: &SubscriptionCap, self: &mut Subscription, amount: u64, ctx: &mut TxContext) -> Coin<SUI> {
        assert!(cap.subscription_id == object::id(self), ERROR_INVALID_CAP);
        assert!(amount <= coin::value(&self.deposit), ERROR_INSUFFICIENT_FUNDS);

        let coin_ = coin::take(&mut self.deposit, amount, ctx);
        coin_
    }

    // For the first time they have to call this function
    public fun get_subscribe(self: &mut Subscription, coin: Coin<SUI>, c: &Clock, ctx: &mut TxContext) -> SubRecipient {
        assert!(timestamp_ms(c) < self.end_time, ERROR_SUB_COMPLETED);
        assert!(coin::value(&coin) == self.price, ERROR_INSUFFICIENT_FUNDS);
        assert!(!table::contains(&self.users, sender(ctx)), ERROR_ALREADY_SUB);

        let balance_ = coin::into_balance(coin);
        balance::join(&mut self.deposit, balance_);

        table::add(&mut self.users, sender(ctx), true);
        let sub = SubRecipient {
            id: object::new(ctx),
            platform: object::id(self),
            month_count: 1,
            owner: sender(ctx),
        };
        sub
    }

    // Monthly subscription renewal
    public fun get_monthly_subscribe(self: &mut Subscription, sub: &mut SubRecipient, coin: Coin<SUI>, c: &Clock, ctx: &mut TxContext) {
        assert!(sub.platform == object::id(self), ERROR_INVALID_CAP);
        assert!(timestamp_ms(c) < self.end_time, ERROR_SUB_COMPLETED);
        assert!(coin::value(&coin) == self.price, ERROR_INSUFFICIENT_FUNDS);
        assert!(table::contains(&self.users, sender(ctx)), ERROR_NOT_SUB);

        let balance_ = coin::into_balance(coin);
        balance::join(&mut self.deposit, balance_);

        sub.month_count += 1;
    }

    // Destroy a subscription
    public fun destroy_subscription(self: SubRecipient, ctx: &mut TxContext) {
        assert!(sender(ctx) == self.owner, ERROR_NOT_OWNER);
        object::delete(self.id);
    }

    // Get the recipient's platform and owner address
    public fun get_recipient(self: &SubRecipient) -> (ID, address) {
        (self.platform, self.owner)
    }

    // Get the end time of a subscription
    public fun get_ended_subscriptions(self: &Subscription) -> u64 {
        self.end_time
    }

    // Check if a user is actively subscribed
    public fun get_active_subscriptions(self: &Subscription, user: address) -> bool {
        table::contains(&self.users, user)
    }
}
