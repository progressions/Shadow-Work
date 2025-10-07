// Inherit the parent event
event_inherited();

// Orc-specific stats (stronger, slower)
attack_damage = 12;
attack_speed = 0.5;
attack_range = 25;
hp = 18;
hp_total = hp;
move_speed = 0.5;
melee_damage_resistance = 2;
ranged_damage_resistance = 0;

// Dual-mode configuration (melee-preferring with throwing axes)
enable_dual_mode = true;
preferred_attack_mode = "melee";   // Prefers brutal melee combat
ranged_damage = 3;                 // Throwing axe damage
ranged_attack_speed = 0.6;         // Slower than melee
ranged_projectile_object = obj_enemy_arrow;  // TODO: Create obj_throwing_axe for visual distinction
melee_range_threshold = 48;        // Switch to melee at medium distance
retreat_when_close = false;        // Orcs never retreat

// Orc traits - fire-born warrior, immune to fire but weak to ice
array_push(tags, "fireborne");
apply_tag_traits();

// Approach variation - orcs are brutish and charge directly (low flanking)
flank_chance = 0.2;

// Ranged attack animation overrides (throwing axes)
enemy_anim_overrides = {
    ranged_attack_down: {start: 35, length: 3},
    ranged_attack_right: {start: 38, length: 4},
    ranged_attack_left: {start: 42, length: 4},
    ranged_attack_up: {start: 46, length: 3}
};

enemy_sounds.on_aggro = snd_orc_aggro;
enemy_sounds.on_death = snd_orc_death;
enemy_sounds.on_melee_attack = snd_orc_attack;  // Brutal melee sound
enemy_sounds.on_ranged_attack = snd_orc_attack; // Same sound for throwing axes
enemy_sounds.on_hit = snd_orc_hit;

// Orc loot table - higher drop chance for tougher enemy
drop_chance = 0.5; // 50% chance to drop loot
loot_table = [
    {item_key: "rusty_dagger", weight: 2},
    {item_key: "medium_health_potion", weight: 3},
    {item_key: "leather_armor", weight: 1},
    {item_key: "arrows", weight: 4}
];