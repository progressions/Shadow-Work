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

/// @description Look up animation data using instance overrides when available
function enemy_anim_lookup(key) {
    if (variable_instance_exists(self, "enemy_anim_overrides")) {
        var _overrides = enemy_anim_overrides;
        if (is_struct(_overrides) && variable_struct_exists(_overrides, key)) {
            return _overrides[$ key];
        }
    }

    if (variable_struct_exists(global.enemy_anim_data, key)) {
        return global.enemy_anim_data[$ key];
    }

    return undefined;
}

/// @description Get animation data with optional fallback key
function enemy_anim_get(key, fallback_key) {
    var _anim = enemy_anim_lookup(key);
    if (_anim != undefined) return _anim;

    if (!is_undefined(fallback_key)) {
        _anim = enemy_anim_lookup(fallback_key);
        if (_anim != undefined) return _anim;
    }

    return global.enemy_anim_data.idle_down;
}

// Get animation data for enemy state and direction
function get_enemy_anim(state, dir_index) {
    var dir_names = ["down", "right", "left", "up"];

    if (state == EnemyState.ranged_attacking) {
        var ranged_key = "ranged_attack_" + dir_names[dir_index];
        var ranged_anim = enemy_anim_lookup(ranged_key);
        if (ranged_anim != undefined) {
            return ranged_anim;
        }
        // Fall back to melee attack frames if no ranged-specific data exists
        var fallback_key = "attack_" + dir_names[dir_index];
        return enemy_anim_get(fallback_key);
    }

    switch(state) {
        case EnemyState.idle:
            return enemy_anim_get("idle_" + dir_names[dir_index]);

        case EnemyState.wander:
            return enemy_anim_get("idle_" + dir_names[dir_index]);

        case EnemyState.attacking:
            return enemy_anim_get("attack_" + dir_names[dir_index]);

        case EnemyState.dead:
            return enemy_anim_lookup("dying") ?? global.enemy_anim_data.dying;

        default:
            return enemy_anim_get("idle_" + dir_names[dir_index]);
    }
}
