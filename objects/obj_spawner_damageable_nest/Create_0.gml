// ============================================
// DAMAGEABLE NEST SPAWNER - Example Damageable Spawner
// Visible spawner with health that can be destroyed by player
// ============================================

// Call parent create event
event_inherited();

// Override configuration for damageable nest behavior
spawn_mode = SpawnerMode.continuous; // Spawns until destroyed
max_total_spawns = -1;               // Unlimited total spawns
max_concurrent_enemies = 3;           // Max 3 enemies alive at once
spawn_period = 180;                   // 3 seconds between spawns (at 60 FPS)

// Spawn table - single enemy type
spawn_table = [
    {enemy_object: obj_burglar, weight: 1}
];

// Spawner settings
proximity_enabled = false;        // Always active
is_visible = true;                // VISIBLE - player can see it
is_damageable = true;             // DAMAGEABLE - can be destroyed
hp_total = 20;                    // 20 HP total
hp_current = 20;                  // Start at full health

// Optional: Add spawn sound (example - uncomment if sound exists)
// spawn_sound = snd_spawn_enemy;

show_debug_message("Damageable Nest Spawner created - HP: " + string(hp_total) + " | Visible & Damageable");
