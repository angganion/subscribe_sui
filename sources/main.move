module subscription::main {
    use sui::sui::SUI;
    use sui::tx_context::{TxContext, Self, sender};
    use sui::coin::{Coin, Self};
    use sui::balance::{Self, Balance};
    use sui::transfer::Self;
    use sui::clock::{Self, Clock, timestamp_ms};
    use sui::object::{Self, UID, ID};

    struct Subscription has key, store {
        id: UID,
        user_id: u64,
        deposit: Balance<SUI>,
        start_time: u64,
        end_time: u64,
        active: bool,
    }

    struct SubscriptionCap has key {
        id: UID,
        subscription_id:ID
    }

    struct User has key {
        id: UID,
        isSubscribed: bool,
    }

    public fun new_subscribe(user_id: u64, period: u64, c: &Clock, ctx:&mut TxContext) {
        let id_ = object::new(ctx);
        let inner = object::uid_to_inner(&id_);
        let subscription = Subscription{
            id: id_,
            user_id: user_id,
            deposit: balance::zero(),
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

    // public fun transfer_subscribe(object: &Subscription, to: address, amount: Coin) {
    //     let balance = object.deposit;
    //     if balance < amount {
    //         panic("Not enough balance");
    //     }
    //     let to_balance = balance::load(to);
    //     to_balance += amount;
    //     balance -= amount;
    //     balance::save(to, to_balance);
    //     object.deposit = balance;
    // }

    // public fun create_user(ctx: &TxContext, user_id: u64) {
    //     let user = user{
    //         id: user_id,
    //         isSubscribed: false,
    //         poin: 0,
    //     };
    //     user.save();
    // }



    // public fun unsubscribe(ctx: &TxContext, user_id: u64) {
    //     let user = user.load();
    //     user.isSubscribed = false;
    //     user.save();
    // }

    // public fun getSubscription(ctx: &TxContext, user_id: u64) -> Subscription {
    //     let user = user.load();
    //     if !user.isSubscribed {
    //         panic("User is not subscribed");
    //     }
    //     let subscription = Subscription.load();
    //     return subscription;
    // }

    // public fun deleteSubscription(ctx: &TxContext, user_id: u64) {
    //     let user = user.load();
    //     if !user.isSubscribed {
    //         panic("User is not subscribed");
    //     }
    //     let subscription = Subscription.load();
    //     subscription.active = false;
    //     subscription.save();
    // }

    // public fun pay(ctx: &TxContext, user_id: u64, amount: Coin) {
    //     let user = user.load();
    //     if !user.isSubscribed {
    //         panic("User is not subscribed");
    //     }
    //     let subscription = Subscription.load();
    //     if subscription.active {
    //         subscription.deposit += amount;
    //         subscription.last_payment_time = Clock::now();
    //         subscription.save(); 
    //     }
    // }

    // public fun tranfer_balance(ctx: &TxContext, to: address, amount: Coin) {
    //    transfer::transfer(ctx, to, amount){
    //         let subscription = Subscription.load();
    //         trasfer_subscribe(&subscription, to, amount);
    //    } tx_context::Self::new(ctx);
    // }

    // public fun see_subscription(ctx: &TxContext) -> Subscription {
    //     let subscription = Subscription.load();
    //     return subscription;
    // }

    // public fun see_user(ctx: &TxContext) -> user {
    //     let user = user.load();
    //     return user;
    // }

    // public fun see_ended_subscriptions(ctx: &TxContext) -> Subscription {
    //     let subscription = Subscription.load();
    //     if subscription.end_time < Clock::now() {
    //         return subscription;
    //     }
    // }

    // public fun see_active_subscriptions(ctx: &TxContext) -> Subscription {
    //     let subscription = Subscription.load();
    //     if subscription.end_time > Clock::now() {
    //         return subscription;
    //     }
    // }

    // public fun see_duration(ctx: &TxContext) -> u64 {
    //     let subscription = Subscription.load();
    //     return subscription.end_time - subscription.start_time;
    // }

    // public fun claim(ctx: &TxContext) {
    //     let subscription = Subscription.load();
    //     if subscription.end_time < Clock::now() {
    //         let balance = balance::load(subscription.user_id);
    //         balance += subscription.deposit;
    //         balance::save(subscription.user_id, balance);
    //         subscription.active = false;
    //         subscription.save();
    //     }
    // }
}
