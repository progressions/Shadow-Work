// Ranged attack state timeout failsafe
// If stuck in ranged_attacking for too long, force return to targeting
if (global.game_paused) exit;

if (state == EnemyState.ranged_attacking) {
    state = EnemyState.targeting;
    show_debug_message("Ranged attack timeout - forcing targeting state");
}
