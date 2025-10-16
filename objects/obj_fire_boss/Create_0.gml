// Fire Boss - Multi-Attack Boss Enemy
// Inherits from obj_enemy_parent
event_inherited();

// ============================================
// BASIC STATS
// ============================================
hp = 100;
hp_total = hp;
move_speed = 1.0;
aggro_distance = 200;  // Larger aggro radius for boss

// ============================================
// MULTI-ATTACK SYSTEM CONFIGURATION
// ============================================
enable_dual_mode = true;        // Enable ranged attacks
enable_hazard_spawning = true;  // Enable hazard spawning
allow_multi_attack = true;      // Enable multi-attack boss system

// ============================================
// MELEE ATTACK (Shortest Cooldown - 1.5 seconds)
// ============================================
attack_damage = 6;
attack_damage_type = DamageType.fire;
attack_speed = 1.0;  // ~90 frame cooldown (1.5 seconds)
attack_range = 40;   // Slightly longer reach than normal enemies

// Melee attack with higher stun/stagger chances
melee_attack = {
    damage: attack_damage,
    damage_type: attack_damage_type,
    chance_to_stun: 0.15,      // 15% stun chance (higher than normal)
    chance_to_stagger: 0.25,   // 25% stagger chance (higher than normal)
    stun_duration: 2.0,        // 2 seconds
    stagger_duration: 1.5,     // 1.5 seconds
    range: attack_range
};

// Critical hits
crit_chance = 0.10;      // 10% crit chance
crit_multiplier = 2.0;   // 2x damage on crit

// ============================================
// RANGED ATTACK (Medium Cooldown - 3 seconds)
// ============================================
ranged_damage = 4;
ranged_damage_type = DamageType.fire;
ranged_attack_speed = 0.5;  // ~180 frame cooldown (3 seconds)
ranged_projectile_object = obj_enemy_arrow;  // Use standard arrow projectile
ranged_projectile_speed = 5;  // Faster than normal arrows

// Configure ranged attack struct
ranged_attack = {
    damage: ranged_damage,
    damage_type: ranged_damage_type,
    chance_to_stun: 0.08,      // 8% stun chance
    chance_to_stagger: 0.15,   // 15% stagger chance
    stun_duration: 1.5,        // 1.5 seconds
    stagger_duration: 1.0,     // 1.0 seconds
    range: 180                 // Ranged attack range
};

// Ranged attack windup (creates telegraph)
ranged_windup_speed = 0.4;  // Slower windup for boss (40% speed = longer telegraph)

// ============================================
// HAZARD SPAWNING ATTACK (Longest Cooldown - 8 seconds)
// ============================================
hazard_spawn_cooldown = 480;           // 8 seconds (longest cooldown)
hazard_priority = 40;                  // Weight 40 (higher priority than default 30)
hazard_spawn_windup_time = 50;         // 0.83 second windup (longer for boss)
hazard_projectile_object = obj_hazard_projectile;
hazard_projectile_distance = 100;      // Longer range than normal
hazard_projectile_speed = 4;           // Fast projectile
hazard_projectile_damage = 3;          // High damage
hazard_projectile_damage_type = DamageType.fire;
hazard_projectile_direction_offset = 0;  // Straight ahead
hazard_spawn_object = obj_fire;   // Spawns fire hazard at landing

// Optional: Apply burning status effect on projectile hit
hazard_status_effects = [
    {trait: "burning"}
];

// ============================================
// IDEAL RANGE & POSITIONING
// ============================================
ideal_range = 120;  // Boss maintains medium distance
melee_range_threshold = 50;  // Prefers melee when player is very close
retreat_when_close = false;  // Boss doesn't retreat (aggressive positioning)

// ============================================
// DAMAGE RESISTANCE
// ============================================
melee_damage_resistance = 2;   // 2 DR against melee
ranged_damage_resistance = 1;  // 1 DR against ranged

// ============================================
// TRAITS & TAGS
// ============================================
// Fire-based boss with fire immunity
array_push(tags, "fireborne");  // Grants fire_immunity, ice_vulnerability
apply_tag_traits();

// ============================================
// SOUND EFFECTS
// ============================================
// Override default sounds with boss-specific sounds (if available)
// enemy_sounds.on_melee_attack = snd_fire_boss_melee;
// enemy_sounds.on_ranged_attack = snd_fire_boss_ranged;
enemy_sounds.on_hazard_windup = snd_fire_boss_cast;  // Casting sound for hazard windup
// enemy_sounds.on_hit = snd_fire_boss_hit;
// enemy_sounds.on_death = snd_fire_boss_death;
// enemy_sounds.on_aggro = snd_fire_boss_roar;

// ============================================
// LOOT TABLE
// ============================================
drop_chance = 1.0;  // Boss always drops loot
loot_table = [
    {item_key: "greatsword", weight: 1},
    {item_key: "plate_armor", weight: 1},
    {item_key: "small_health_potion", weight: 2}
];

// ============================================
// ANIMATION OVERRIDES (Optional)
// ============================================
// If your sprite uses a custom layout, define overrides here
// Example for 47-frame sprite with extended animations:
// enemy_anim_overrides = {
//     ranged_attack_down: {start: 35, length: 3},
//     ranged_attack_right: {start: 38, length: 4},
//     ranged_attack_left: {start: 42, length: 4},
//     ranged_attack_up: {start: 46, length: 3}
// };
