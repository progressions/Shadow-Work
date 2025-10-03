// Only pick random targets if idle (not targeting player with pathfinding)
if (global.game_paused) exit;

var _center_x = variable_instance_exists(self, "wander_center_x") ? wander_center_x : xstart;
var _center_y = variable_instance_exists(self, "wander_center_y") ? wander_center_y : ystart;
var _radius = variable_instance_exists(self, "wander_radius") ? wander_radius : 100;

if (state == EnemyState.wander) {
    var _player_in_range = instance_exists(obj_player) && distance_to_object(obj_player) < aggro_distance;

    if (_player_in_range) {
        state = EnemyState.targeting;
        play_enemy_sfx("on_aggro");
        alarm[0] = 1; // Trigger immediate path calculation
    } else {
        target_x = random_range(_center_x - _radius, _center_x + _radius);
        target_y = random_range(_center_y - _radius, _center_y + _radius);

        alarm[0] = irandom_range(45, 120);
    }
} else if (state == EnemyState.idle) {
    if (instance_exists(obj_player) && distance_to_object(obj_player) < aggro_distance) {
        state = EnemyState.targeting;
        play_enemy_sfx("on_aggro");
        alarm[0] = 1;
    } else {
        target_x = random_range(_center_x - _radius, _center_x + _radius);
        target_y = random_range(_center_y - _radius, _center_y + _radius);
        alarm[0] = 60;
    }
} else if (state == EnemyState.targeting) {
    // Path recalculation happens in enemy_state_targeting()
    // This alarm is used as a timer flag, reset there
}
