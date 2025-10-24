// Inherit the parent event
event_inherited();

// Greenwood Bandit-specific stats (balanced)
attack_damage = 1;
attack_speed = 0.75;
attack_range = 24;  // Long range for bow attacks (8 tiles)
hp = 4;
move_speed = 0.7;

kb_x = 0;
kb_y = 0;

// Ranged attack configuration
is_ranged_attacker = false;
ranged_damage = 2;           // Higher than melee damage
ranged_attack_speed = 0.6;   // Slower than melee (longer cooldown)

// Ranged enemy ideal distance from player (for kiting/circle strafe)
// PATTERN: Set ideal_range to ~75-80% of attack_range for ranged enemies
// This allows them to maintain shooting distance while having room to maneuver
ideal_range = 24;  // 75% of attack_range (128) - stays at bow range, circles/kites player

// Dual-mode configuration (archer with melee fallback)
enable_dual_mode = false;
preferred_attack_mode = "melee";  // Prefers bow attacks
// attack_damage = 1 already set above (weak dagger swipe for melee fallback)
melee_range_threshold = 24;        
retreat_when_close = false;         // Retreat to maintain bow range

// Approach variation - bandits are tactical archers (moderate flanking)
flank_chance = 0.95;
flank_trigger_distance = 160;  // Trigger beyond attack range to execute flank before shooting

// Configure attack sounds (archer with melee fallback)
enemy_sounds.on_ranged_attack = snd_bow_attack;  // Primary bow attack sound
enemy_sounds.on_melee_attack = snd_attack_sword; // Fallback dagger swipe

// Ranged attack animation overrides (bow attacks)
enemy_anim_overrides = {
    ranged_attack_down: {start: 35, length: 3},
    ranged_attack_right: {start: 38, length: 4},
    ranged_attack_left: {start: 42, length: 4},
    ranged_attack_up: {start: 46, length: 3}
};

state = EnemyState.wander;
aggro_distance = 90;