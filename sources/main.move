module subscription::main {
    use sui::sui::SUI;
    use sui::tx_context::{TxContext, Self, sender};
    use sui::coin::{Coin, Self};
    use sui::balance::{Self, Balance};
    use sui::transfer::Self;
    use sui::clock::{Self, Clock, timestamp_ms};
    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};

    // Define error constants
    const ERROR_INVALID_CAP: u64 = 0;
    const ERROR_INSUFFICIENT_FUNDS: u64 = 1;
    const ERROR_NOT_OWNER: u64 = 2;
    const ERROR_ALREADY_SUB: u64 = 3;
    const ERROR_NOT_SUB: u64 = 4;
    const ERROR_SUB_COMPLETED: u64 = 5;

    // Define structs for subscriptions
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

    struct SubscriptionCap has key {
        id: UID,
        subscription_id: ID
    }

    struct SubRecipient has key {
        id: UID,
        platfrom: ID,
        month_count: u64,
        owner: address
    }

    // Function to create a new subscription
    public fun new_subscribe(user_id: u64, period: u64, price_: u64, c: &Clock, ctx: &mut TxContext) {
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
            subscription_id: inner
        };
        transfer::transfer(cap, sender(ctx));
    }

    // Function to transfer subscription amount
    public fun transfer_subscribe(cap: &SubscriptionCap, self: &mut Subscription, amount: u64, ctx: &mut TxContext) : Coin<SUI> {
        assert!(cap.subscription_id == object::id(self), ERROR_INVALID_CAP);
        assert!(amount > 0, ERROR_INSUFFICIENT_FUNDS);

        let coin_ = coin::take(&mut self.deposit, amount, ctx);
        coin_
    }

    // Function to subscribe for the first time
    public fun get_subscribe(self: &mut Subscription, coin: Coin<SUI>, c: &Clock, ctx: &mut TxContext) : SubRecipient {
        assert!(timestamp_ms(c) < self.end_time, ERROR_SUB_COMPLETED);
        assert!(coin::value(&coin) == self.price, ERROR_INSUFFICIENT_FUNDS);
        assert!(!table::contains(&self.users, sender(ctx)), ERROR_ALREADY_SUB);

        let balance_ = coin::into_balance(coin);
        balance::join(&mut self.deposit, balance_);

        table::add(&mut self.users, sender(ctx), true);
        let sub = SubRecipient {
            id: object::new(ctx),
            platfrom: object::id(self),
            month_count: 1,
            owner: sender(ctx)
        };
        sub
    }

    // Function to subscribe monthly
    public fun get_monthly_subscribe(self: &mut Subscription, sub: &mut SubRecipient, coin: Coin<SUI>, c: &Clock, ctx: &mut TxContext) {
        assert!(sub.platfrom == object::id(self), ERROR_INVALID_CAP);
        assert!(timestamp_ms(c) < self.end_time, ERROR_SUB_COMPLETED);
        assert!(coin::value(&coin) == self.price, ERROR_INSUFFICIENT_FUNDS);
        assert!(table::contains(&self.users, sender(ctx)), ERROR_NOT_SUB);

        let balance_ = coin::into_balance(coin);
        balance::join(&mut self.deposit, balance_);

        sub.month_count = sub.month_count + 1;
    }

    // Function to destroy a subscription
    public fun destroy_subscription(self: SubRecipient, ctx: &mut TxContext) {
        assert!(sender(ctx) == self.owner, ERROR_NOT_OWNER);
        object::delete(self.id);
    }

    // Function to retrieve recipient information
    public fun get_recipient(self: &SubRecipient) : (ID, address) {
        (self.platfrom, self.owner)
    }

    // Function to check if a subscription has ended
    public fun get_ended_subscriptions(self: &Subscription) : bool {
        !self.active
    }

    // Function to check if a user is an active subscriber
    public fun get_active_subscriptions(self: &Subscription, user: address) : bool {
        assert!(table::contains(&self.users, user), ERROR_NOT_SUB);
        true
    }
}
