module subscription::main {
    use sui::sui::SUI;
    use sui::tx_context::{TxContext, Self, sender};
    use sui::coin::{Coin, Self};
    use sui::balance::{Self, Balance};
    use sui::transfer::Self;
    use sui::clock::{Self, Clock, timestamp_ms};
    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};

    const ERROR_INVALID_CAP :u64 = 0;
    const ERROR_INSUFFCIENT_FUNDS : u64 = 1;
    const ERROR_NOT_OWNER : u64 = 2;
    const ERROR_ALREADY_SUB : u64 = 3;
    const ERROR_NOT_SUB : u64 = 4;

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
        subscription_id:ID
    }

    struct SubRecipient has key {
        id: UID,
        platfrom: ID,
        owner: address
    }

    public fun new_subscribe(user_id: u64, period: u64, price_: u64, c: &Clock, ctx:&mut TxContext) {
        let id_ = object::new(ctx);
        let inner = object::uid_to_inner(&id_);
        let subscription = Subscription{
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

    public fun transfer_subscribe(cap: &SubscriptionCap, self: &mut Subscription, amount: u64, ctx: &mut TxContext) : Coin<SUI> {
        assert!(cap.subscription_id == object::id(self), ERROR_INVALID_CAP);
        assert!(amount > 0, ERROR_INSUFFCIENT_FUNDS);

        let coin_= coin::take(&mut self.deposit, amount, ctx);
        coin_
    }

    
    public fun get_subscribe(self: &mut Subscription, coin: Coin<SUI>, ctx: &mut TxContext) : SubRecipient {
        assert!(coin::value(&coin) == self.price, ERROR_INSUFFCIENT_FUNDS);
        assert!(!table::contains(&self.users, sender(ctx)), ERROR_ALREADY_SUB);

        let balance_ = coin::into_balance(coin);
        balance::join(&mut self.deposit, balance_);

        table::add(&mut self.users, sender(ctx), true);
        let sub = SubRecipient {
            id: object::new(ctx),
            platfrom: object::id(self),
            owner: sender(ctx)
        };
        sub
    }

    public fun deleteSubscription(self: SubRecipient, ctx: &mut TxContext) {
       assert!(sender(ctx) == self.owner, ERROR_NOT_OWNER);
       let SubRecipient {
        id,
        platfrom: _,
        owner: _
       } = self;
       object::delete(id);
    }

    public fun get_recepient(self: &SubRecipient) :(ID, address) {
        (
            self.platfrom,
            self.owner
        )
    }

    public fun get_ended_subscriptions(self: &Subscription) : u64 {
        self.end_time
    }

    public fun get_active_subscriptions(self: &Subscription, user: address) : bool {
        assert!(!table::contains(&self.users, user), ERROR_NOT_SUB);
        true
    }
}
