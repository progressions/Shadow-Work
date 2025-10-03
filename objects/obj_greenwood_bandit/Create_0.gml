// Inherit the parent event
event_inherited();

// Greenwood Bandit-specific stats (balanced)
attack_damage = 2;
attack_speed = 0.9;
attack_range = 128;  // Long range for bow attacks (8 tiles)
hp = 4;
move_speed = 1.0;

// Ranged attack configuration
is_ranged_attacker = true;
ranged_damage = 3;           // Higher than melee damage
ranged_attack_speed = 0.8;   // Slower than melee (longer cooldown)

// Ranged enemy ideal distance from player (for kiting/circle strafe)
// PATTERN: Set ideal_range to ~75-80% of attack_range for ranged enemies
// This allows them to maintain shooting distance while having room to maneuver
ideal_range = 24;  // 75% of attack_range (128) - stays at bow range, circles/kites player

// Configure bow attack sound
enemy_sounds.on_attack = snd_bow_attack;