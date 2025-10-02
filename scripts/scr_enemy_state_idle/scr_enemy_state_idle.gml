// ============================================
// ENEMY STATE: IDLE
// Wander toward target with terrain/status modifiers
// ============================================

function enemy_state_idle() {
    var _hor = clamp(target_x - x, -1, 1);
    var _ver = clamp(target_y - y, -1, 1);

    if (abs(_hor) < 0.1) _hor = 0;
    if (abs(_ver) < 0.1) _ver = 0;

    if (_hor == 0 && _ver == 0) {
        return;
    }

    var _speed_modifier = get_status_effect_modifier("speed");
    var _terrain_modifier = enemy_get_terrain_speed_modifier();
    var _final_speed = move_speed * _speed_modifier * _terrain_modifier;

    if (_final_speed <= 0) {
        _final_speed = max(move_speed, 0.1);
    }

    move_and_collide(
        _hor * _final_speed,
        _ver * _final_speed,
        [tilemap, obj_enemy_parent, obj_rising_pillar]
    );
}
