// ============================================
// SPAWNER PARENT - Step Event
// Handle spawning logic and proximity checks
// ============================================

// Early exit if destroyed
if (is_destroyed) {
    return;
}

// Clean up dead enemy references
spawner_cleanup_dead_enemies(id);

// Handle proximity activation if enabled
if (proximity_enabled) {
    var dist_to_player = spawner_check_proximity(id);

    if (dist_to_player >= 0) { // Valid distance (player exists)
        if (dist_to_player <= proximity_radius) {
            // Player is within radius - activate spawner
            if (!is_active) {
                is_active = true;
                spawn_timer = spawn_period; // Reset timer on activation
                show_debug_message("Spawner activated (player in range)");
            }
        } else {
            // Player is outside radius - deactivate spawner
            if (is_active) {
                is_active = false;
                show_debug_message("Spawner deactivated (player out of range)");
            }
        }
    }
}

// Spawning logic
if (is_active) {
    // Decrement spawn timer
    spawn_timer--;

    // Check if it's time to spawn
    if (spawn_timer <= 0) {
        // Check if spawner can spawn
        if (spawner_can_spawn(id)) {
            // Spawn enemy
            spawner_spawn_enemy(id);
        } else {
            // Can't spawn - reset timer and try again later
            spawn_timer = spawn_period;
        }
    }
}
