// ============================================
// ENEMY STATE: RANGED ATTACKING
// Holds position until projectile cooldown completes
// ============================================

function enemy_state_ranged_attacking() {
    // Keep moving along path while in ranged attack cooldown
    // This allows kiting behavior

    // Resume targeting immediately for repositioning or re-engagement
    var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

    // If player moved significantly out of attack range, resume pursuit
    if (_dist_to_player > attack_range + 32) {
        state = EnemyState.targeting;
        return;
    }

    // If player got too close (inside ideal_range), resume to reposition
    if (_dist_to_player < ideal_range - 32) {
        state = EnemyState.targeting;
        return;
    }

    // If cooldown is nearly done and we don't have LOS, start repositioning early
    if (ranged_attack_cooldown <= 10 && !enemy_has_line_of_sight(obj_player.x, obj_player.y)) {
        state = EnemyState.targeting;
        return;
    }
}
