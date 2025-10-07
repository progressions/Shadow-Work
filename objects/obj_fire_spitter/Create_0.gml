// Inherit the parent event
event_inherited();

attack_damage = 1;
attack_damage_type = DamageType.fire; // Fire spitter deals elemental damage
attack_speed = 0.8;
attack_range = 128;
hp = 8;
hp_total = hp;
move_speed = 0.85;

// Apply fireborne tag (grants fire_immunity + ice_vulnerability)
apply_tag_traits("fireborne");

// Fire spitter attacks cause burning
attack_status_effects = [
    {trait: "burning", chance: 0.35} // 35% chance to burn on hit
];

// Ranged attack configuration (mirrors Greenwood Bandit behavior)
is_ranged_attacker = true;
ranged_damage = 2;          // Firebolt damage matches melee claws
ranged_attack_speed = 1;
ideal_range = 72;           // Maintain ~75% of attack range to kite the player
ranged_projectile_object = obj_fireball;
ranged_damage_type = DamageType.fire;
ranged_status_effects = [
    {trait: "burning", chance: 0.35}
];

// Fire spitter loot table - ranged items and fire gear
drop_chance = 0.35; // 35% chance to drop loot
loot_table = [
    {item_key: "arrows", weight: 4},
    {item_key: "torch", weight: 2},
    {item_key: "small_health_potion", weight: 2},
    {item_key: "wooden_bow", weight: 1}
];
