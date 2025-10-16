// Alarm[5] - Hazard Spawning State Transition
// Triggered after hazard projectile is spawned to return to targeting

if (state == EnemyState.hazard_spawning) {
    // Reset windup timer for next hazard spawn
    hazard_spawn_windup_timer = hazard_spawn_windup_time;

    // Return to targeting state to resume combat behavior
    state = EnemyState.targeting;
}
