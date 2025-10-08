// Inherit the parent event
event_inherited();

// Sandsnake-specific stats (disciplined javelin throws)
attack_damage = 3;
attack_speed = 0.8;
attack_range = 96; // Extended reach for javelin throws (6 tiles)
hp = 18;
hp_total = hp;
move_speed = 1.0;

// Ranged attack configuration (mirrors Greenwood Bandit behavior)
is_ranged_attacker = true;
ranged_damage = 3;          // Javelin strike damage
ranged_attack_speed = 0.75; // Slightly slower cadence than melee strikes
ideal_range = 72;           // Maintain ~75% of attack range to kite the player
ranged_damage_resistance = 3;

// Dual-mode configuration (javelin warrior archetype)
enable_dual_mode = true;
preferred_attack_mode = "ranged";  // Prefers ranged javelin throws
melee_range_threshold = 32;        // Only use melee when player is very close
retreat_when_close = true;         // Kite away to maintain ideal range

enemy_anim_overrides = {
    ranged_attack_down: {start: 35, length: 3},
    ranged_attack_right: {start: 38, length: 4},
    ranged_attack_left: {start: 42, length: 4},
    ranged_attack_up: {start: 46, length: 3}
};

traits = ["sandcrawler"];

// Slither dash configuration
slither_dash_speed = 3.4;
slither_dash_duration = 18;
slither_dash_cooldown_min = 150;
slither_dash_cooldown_max = 240;
slither_dash_trigger_range = 200;
slither_dash_cooldown = irandom_range(slither_dash_cooldown_min, slither_dash_cooldown_max);
slither_dash_active = false;
slither_dash_timer = 0;
slither_dash_direction = 0;
slither_dash_saved_path_speed = 0;
