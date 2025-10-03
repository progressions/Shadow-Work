// ============================================
// ORC CAMP SPAWNER - Example Finite Spawner
// Spawns 5 orcs then stops
// ============================================

// Call parent create event
event_inherited();

// Override configuration for orc camp behavior
spawn_mode = SpawnerMode.finite;
max_total_spawns = 5;           // Spawn exactly 5 orcs then stop
max_concurrent_enemies = 2;      // Max 2 orcs alive at once
spawn_period = 120;              // 2 seconds between spawns (at 60 FPS)

spawn_table = [
    {enemy_object: obj_orc, weight: 1}
];

// Spawner settings
proximity_enabled = false;       // Always active
is_visible = false;              // Invisible spawner
is_damageable = false;           // Cannot be destroyed

show_debug_message("Orc Camp Spawner created - Will spawn " + string(max_total_spawns) + " orcs");
