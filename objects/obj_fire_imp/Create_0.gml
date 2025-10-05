// Inherit the parent event
event_inherited();

attack_damage = 1;
attack_damage_type = DamageType.fire; // Fire imp deals fire damage
attack_speed = 0.8;
attack_range = 32;
hp = 8;
hp_total = hp;
move_speed = 0.75;

// Apply fireborne tag (grants fire_immunity + ice_vulnerability)
apply_tag_traits("fireborne");

// Fire imp attacks cause burning
attack_status_effects = [
    {effect: StatusEffectType.burning, chance: 0.5} // 50% chance to burn on hit
];

enemy_sounds = {
    on_attack: snd_fire_imp_attack,      // Default: snd_enemy_attack_generic
    on_hit: snd_attack_hit,         // Default: snd_enemy_hit_generic
    on_death: snd_fire_imp_death,       // Default: snd_enemy_death
    on_aggro: snd_fire_imp_aggro,       // Default: undefined (no sound)
    on_footstep: snd_fire_imp_footsteps,    // Default: undefined (no sound)
    on_status_effect: undefined // Default: snd_status_effect_generic
};

// Fire imp loot table - fire-themed items
drop_chance = 0.4; // 40% chance to drop loot
loot_table = [
    {item_key: "torch"},  // Equal weights
    {item_key: "small_health_potion"}
];