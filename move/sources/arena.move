module challenge::arena;

use challenge::hero::{Hero, hero_power};
use sui::event;
use sui::tx_context::{Self as tx};

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {

    let arena = Arena { 
        id: object::new(ctx),
        warrior: hero,
        owner: tx::sender(ctx),
    };
    event::emit(ArenaCreated { 
        arena_id: object::id(&arena),
        timestamp: tx::epoch_timestamp_ms(ctx),
    });

    transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {

    let Arena { id, warrior, owner } = arena;

    let power_Hero = hero_power(&hero);
    let power_Warrior = hero_power(&warrior);

    if (power_Hero>power_Warrior) {
    
        let ts = tx::epoch_timestamp_ms(ctx);
        event::emit(ArenaCompleted {
            winner_hero_id: object::id(&hero),
            loser_hero_id: object::id(&warrior),
            timestamp: ts,
        });
        transfer::public_transfer(hero, tx::sender(ctx));
        transfer::public_transfer(warrior, tx::sender(ctx));
    } else{
        
        let ts = tx::epoch_timestamp_ms(ctx);
        event::emit(ArenaCompleted {
            winner_hero_id: object::id(&warrior),
            loser_hero_id: object::id(&hero),
            timestamp: ts,
        });
        transfer::public_transfer(warrior, owner);
        transfer::public_transfer(hero, owner);
    };
    object::delete(id);
}