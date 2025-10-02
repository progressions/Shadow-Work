// ============================================
// ENEMY STATE: ATTACKING
// Locks enemy in place while melee attack resolves
// ============================================

function enemy_state_attacking() {
    target_x = x;
    target_y = y;

    if (path_exists(path)) {
        path_end();
    }
}
