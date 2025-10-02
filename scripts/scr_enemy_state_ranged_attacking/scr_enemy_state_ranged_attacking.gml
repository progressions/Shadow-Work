// ============================================
// ENEMY STATE: RANGED ATTACKING
// Holds position until projectile cooldown completes
// ============================================

function enemy_state_ranged_attacking() {
    target_x = x;
    target_y = y;

    if (path_exists(path)) {
        path_end();
    }
}
