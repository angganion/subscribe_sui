module subscription::subscription {
    use sui::sui::SUI;
    use sui::tx_context::{TxContext, Self};
    use sui::coin::{Coin, Self};
    use sui::balance::{Self};
    use sui::transfer::Self;
    use sui::clock::Clock;

    struct Subscription has key, store {
        owner_address: address,
        id: u64,
        admin_id: u64,
        user_id: u64,
        deposit: Coin,
        start_time: u64,
        end_time: u64,
        period: u64,
        last_payment_time: u64,
        active: bool,
    }

    struct admin has key {
        id: u64,
    }

    struct user has key {
        id: u64,
        isSubscribed: bool,
    }

    public fun init(ctx: &TxContext, admin_id: u64) {
        let admin = admin{
            id: admin_id,
        };
        admin.save();
    }

    public fun transfer_subscribe(object: &Subscription, to: address, amount: Coin) {
        let balance = object.deposit;
        if balance < amount {
            panic("Not enough balance");
        }
        let to_balance = balance::load(to);
        to_balance += amount;
        balance -= amount;
        balance::save(to, to_balance);
        object.deposit = balance;
    }

    public fun create_user(ctx: &TxContext, user_id: u64) {
        let user = user{
            id: user_id,
            isSubscribed: false,
            poin: 0,
        };
        user.save();
    }

    public fun subscribe(ctx: &TxContext, user_id: u64, deposit: Coin, period: u64) {
        let admin = admin.load();
        let user = user{
            id: user_id,
            isSubscribed: true,
            poin += 10,
        };
        user.save();
        let subscription = Subscription{
            id: ctx.getCounter(),
            admin_id: admin.id,
            user_id: user_id,
            deposit: deposit,
            start_time: Clock::now(),
            end_time: Clock::now() + period,
            period: period,
            last_payment_time: Clock::now(),
            active: true,
        };
        subscription.save();
    }

    public fun unsubscribe(ctx: &TxContext, user_id: u64) {
        let user = user.load();
        user.isSubscribed = false;
        user.save();
    }

    public fun getSubscription(ctx: &TxContext, user_id: u64) -> Subscription {
        let user = user.load();
        if !user.isSubscribed {
            panic("User is not subscribed");
        }
        let subscription = Subscription.load();
        return subscription;
    }

    public fun deleteSubscription(ctx: &TxContext, user_id: u64) {
        let user = user.load();
        if !user.isSubscribed {
            panic("User is not subscribed");
        }
        let subscription = Subscription.load();
        subscription.active = false;
        subscription.save();
    }

    public fun pay(ctx: &TxContext, user_id: u64, amount: Coin) {
        let user = user.load();
        if !user.isSubscribed {
            panic("User is not subscribed");
        }
        let subscription = Subscription.load();
        if subscription.active {
            subscription.deposit += amount;
            subscription.last_payment_time = Clock::now();
            subscription.save(); 
        }
    }

    public fun tranfer_balance(ctx: &TxContext, to: address, amount: Coin) {
       transfer::transfer(ctx, to, amount){
            let subscription = Subscription.load();
            trasfer_subscribe(&subscription, to, amount);
       } tx_context::Self::new(ctx);
    }

    public fun see_subscription(ctx: &TxContext) -> Subscription {
        let subscription = Subscription.load();
        return subscription;
    }

    public fun see_user(ctx: &TxContext) -> user {
        let user = user.load();
        return user;
    }

    public fun see_ended_subscriptions(ctx: &TxContext) -> Subscription {
        let subscription = Subscription.load();
        if subscription.end_time < Clock::now() {
            return subscription;
        }
    }

    public fun see_active_subscriptions(ctx: &TxContext) -> Subscription {
        let subscription = Subscription.load();
        if subscription.end_time > Clock::now() {
            return subscription;
        }
    }

    public fun see_duration(ctx: &TxContext) -> u64 {
        let subscription = Subscription.load();
        return subscription.end_time - subscription.start_time;
    }

    public fun claim(ctx: &TxContext) {
        let subscription = Subscription.load();
        if subscription.end_time < Clock::now() {
            let balance = balance::load(subscription.user_id);
            balance += subscription.deposit;
            balance::save(subscription.user_id, balance);
            subscription.active = false;
            subscription.save();
        }
    }
}
