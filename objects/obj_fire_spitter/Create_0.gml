// Inherit the parent event
event_inherited();

attack_damage = 1;
attack_damage_type = DamageType.fire; // Fire spitter deals elemental damage
attack_speed = 0.8;
attack_range = 128;
hp = 12;
hp_total = hp;
move_speed = 0.85;

// Apply fireborne tag (grants fire_immunity + ice_vulnerability)
apply_tag_traits("fireborne");

// Fire spitter attacks cause burning
attack_status_effects = [
    {effect: StatusEffectType.burning, chance: 0.35} // 35% chance to burn on hit
];

// Ranged attack configuration (mirrors Greenwood Bandit behavior)
is_ranged_attacker = true;
ranged_damage = 1;          // Firebolt damage matches melee claws
ranged_attack_speed = 1;    // Slightly slower cadence than melee strikes
ideal_range = 72;           // Maintain ~75% of attack range to kite the player
