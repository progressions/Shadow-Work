// ============================================
// ANIMATION HELPERS - Enemy animation data and utilities
// ============================================

// Standard enemy animation structure based on sprite frame tags
global.enemy_anim_data = {
    idle_down: {start: 0, length: 2},
    idle_right: {start: 2, length: 2},
    idle_left: {start: 4, length: 2},
    idle_up: {start: 6, length: 2},

    walk_down: {start: 8, length: 3},
    walk_right: {start: 11, length: 3},
    walk_left: {start: 14, length: 3},
    walk_up: {start: 17, length: 3},

    attack_down: {start: 20, length: 3},
    attack_right: {start: 23, length: 3},
    attack_left: {start: 26, length: 3},
    attack_up: {start: 29, length: 3},

    dying: {start: 32, length: 3}
};

// Get animation data for enemy state and direction
function get_enemy_anim(state, dir_index) {
    var dir_names = ["down", "right", "left", "up"];
    var state_name = "";

    switch(state) {
        case EnemyState.idle: state_name = "idle"; break;
        case EnemyState.attacking: state_name = "attack"; break;
        case EnemyState.dead: state_name = "dying"; break;
        default: state_name = "idle"; break;
    }

    var anim_key = state_name + "_" + dir_names[dir_index];
    return global.enemy_anim_data[$ anim_key] ?? global.enemy_anim_data.idle_down;
}
