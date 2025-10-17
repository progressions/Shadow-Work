// ============================================
// BANDIT AMBUSH SPAWNER - Example Proximity Spawner
// Spawns mixed enemies when player approaches
// ============================================

// Call parent create event
event_inherited();

// Override configuration for ambush behavior
spawn_mode = SpawnerMode.finite;
max_total_spawns = 6;            // Spawn 6 enemies total
max_concurrent_enemies = 3;       // Max 3 enemies alive at once
spawn_period = 90;                // 1.5 seconds between spawns (at 60 FPS)

// Weighted spawn table - more burglars than orcs
spawn_table = [
	{enemy_object: obj_greenwood_bandit, weight: 40},
];

// Proximity activation - ambush triggers when player gets close
proximity_enabled = true;
proximity_radius = 120;           // Activate within 150 pixels

// Spawner settings
is_visible = false;                // Visible for testing
is_damageable = false;            // Cannot be destroyed

show_debug_message("Bandit Ambush Spawner created - Proximity: " + string(proximity_radius) + "px");
