// ============================================
// ENEMY STATE: IDLE
// Wander toward target with terrain/status modifiers
// ============================================

function enemy_state_idle() {
    // Idle state is deprecated - transition to targeting
    state = EnemyState.targeting;
    alarm[0] = 1;
}
