// ============================================
// ENDLESS ARENA SPAWNER - Example Continuous Spawner
// Continuously spawns enemies until destroyed (invulnerable)
// ============================================

// Call parent create event
event_inherited();

// Override configuration for endless arena behavior
spawn_mode = SpawnerMode.continuous; // Never stops spawning
max_total_spawns = -1;               // Unlimited total spawns
max_concurrent_enemies = 4;           // Max 4 enemies alive at once
spawn_period = 150;                   // 2.5 seconds between spawns (at 60 FPS)

// Weighted spawn table - variety of enemies
spawn_table = [
    {enemy_object: obj_greenwood_bandit, weight: 40},
    {enemy_object: obj_burglar, weight: 35},
    {enemy_object: obj_orc, weight: 25}
];

// Spawner settings
proximity_enabled = false;        // Always active
is_visible = false;               // Invisible spawner
is_damageable = false;            // Invulnerable - cannot be destroyed

show_debug_message("Endless Arena Spawner created - Continuous mode, " + string(max_concurrent_enemies) + " max enemies");
