// Only pick random targets if idle (not targeting player with pathfinding)
if (global.game_paused) exit;

if (state == EnemyState.idle) {
    if (instance_exists(obj_player) && distance_to_object(obj_player) < aggro_distance) {
        state = EnemyState.targeting;
        play_enemy_sfx("on_aggro");
        alarm[0] = 1; // Trigger immediate path calculation
    } else {
        target_x = random_range(xstart - 100, xstart + 100);
        target_y = random_range(ystart - 100, ystart + 100);
        alarm[0] = 60;
    }
} else if (state == EnemyState.targeting) {
    // Path recalculation happens in enemy_state_targeting()
    // This alarm is used as a timer flag, reset there
}