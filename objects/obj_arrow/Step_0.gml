// Update range profile if spawning code assigned a new id
if (!variable_instance_exists(self, "range_profile_id_cached")) {
    range_profile_id_cached = range_profile_id;
}

if (range_profile == undefined || range_profile_id_cached != range_profile_id) {
    range_profile = projectile_get_range_profile(range_profile_id);
    range_profile_id_cached = range_profile_id;
    max_travel_distance = range_profile.max_distance + range_profile.overshoot_buffer;
}

// Track distance travelled and damage multiplier
var _distance_travelled = point_distance(spawn_x, spawn_y, x, y);
distance_travelled = _distance_travelled;
previous_damage_multiplier = current_damage_multiplier;
current_damage_multiplier = projectile_calculate_damage_multiplier(range_profile, _distance_travelled);

if (variable_global_exists("debug_mode") && global.debug_mode) {
    if (abs(current_damage_multiplier - previous_damage_multiplier) > 0.01) {
        show_debug_message("[Projectile] profile=" + string(range_profile_id) + " dist=" + string_format(_distance_travelled, 0, 1) + " mult=" + string_format(current_damage_multiplier, 0, 3));
    }
}

// Auto-destroy if beyond allowable travel distance
if (projectile_distance_should_cull(range_profile, _distance_travelled)) {
    instance_destroy();
    exit;
}

// Check for collision with Tiles_Col layer
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, x, y);
    if (_tile_value != 0) {
        // Hit a wall - play sound and destroy
        play_sfx(snd_bump, 1, false);
        instance_destroy();
        exit;
    }
}

// Check for collision with enemies
var _hit_enemy = instance_place(x, y, obj_enemy_parent);
if (_hit_enemy != noone) {
    var _damage_type = DamageType.physical;
    if (variable_instance_exists(self, "damage_type")) {
        _damage_type = damage_type;
    }
    __proj_damage_type = _damage_type;
    __proj_scaled_damage = damage * current_damage_multiplier;
    __proj_damage_multiplier = current_damage_multiplier;
    __proj_travel_distance = distance_travelled;
    __proj_debug_final_damage = undefined;
    __proj_debug_target_name = undefined;
    __proj_debug_before_dr = undefined;
    __proj_debug_ranged_dr = undefined;

    with (_hit_enemy) {
        if (state != EnemyState.dead && alarm[1] < 0) {
            // Apply damage with ranged damage resistance
            var _incoming_damage = other.__proj_scaled_damage;
            var _final_damage = max(0, _incoming_damage - ranged_damage_resistance);
            hp -= _final_damage;
            image_blend = c_red;

            // Play enemy hit sound (same system as melee attacks)
            play_enemy_sfx("on_hit");

            // Spawn damage number
            spawn_damage_number(x, y - 16, _final_damage, other.__proj_damage_type, self);

            // Check if enemy died and award XP
            if (hp <= 0) {
                var attacker = other.creator;
                if (attacker != noone && attacker.object_index == obj_player) {
                    var xp_reward = 5;
                    with (attacker) {
                        gain_xp(xp_reward);
                    }
                }

                state = EnemyState.dead;
                play_enemy_sfx("on_death");
                increment_quest_counter("enemies_defeated", 1);
            }

            // Knockback
            kb_x = sign(x - other.x);
            kb_y = sign(y - other.y);
            alarm[1] = 20;

            other.__proj_debug_final_damage = _final_damage;
            other.__proj_debug_target_name = object_get_name(object_index);
            other.__proj_debug_before_dr = _incoming_damage;
            other.__proj_debug_ranged_dr = ranged_damage_resistance;
        }
    }

    var _log_damage_type = __proj_damage_type;
    var _log_scaled_damage = __proj_scaled_damage;
    var _log_multiplier = __proj_damage_multiplier;
    var _log_distance = __proj_travel_distance;
    var _log_final_damage = __proj_debug_final_damage;
    var _log_target_name = __proj_debug_target_name;
    var _log_before_dr = __proj_debug_before_dr;
    var _log_ranged_dr = __proj_debug_ranged_dr;

    if (variable_global_exists("debug_mode") && global.debug_mode) {
        var _target_name = is_string(_log_target_name) ? _log_target_name : "unknown_target";
        var _final_val = is_real(_log_final_damage) ? _log_final_damage : -1;
        var _scaled_val = is_real(_log_scaled_damage) ? _log_scaled_damage : 0;
        var _before_dr_val = is_real(_log_before_dr) ? _log_before_dr : _scaled_val;
        var _dr_val = is_real(_log_ranged_dr) ? _log_ranged_dr : 0;
        var _mult_val = is_real(_log_multiplier) ? _log_multiplier : current_damage_multiplier;
        var _dist_val = is_real(_log_distance) ? _log_distance : distance_travelled;
        var _type_enum = is_real(_log_damage_type) ? _log_damage_type : DamageType.physical;
        var _type_str = damage_type_to_string(_type_enum);

        show_debug_message("[Player Ranged] target=" + _target_name
            + " final=" + string_format(_final_val, 0, 2)
            + " scaled=" + string_format(_scaled_val, 0, 2)
            + " pre_dr=" + string_format(_before_dr_val, 0, 2)
            + " dr=" + string_format(_dr_val, 0, 2)
            + " mult=" + string_format(_mult_val, 0, 3)
            + " dist=" + string_format(_dist_val, 0, 1)
            + " type=" + _type_str);
    }

    __proj_damage_type = undefined;
    __proj_scaled_damage = undefined;
    __proj_damage_multiplier = undefined;
    __proj_travel_distance = undefined;
    __proj_debug_final_damage = undefined;
    __proj_debug_target_name = undefined;
    __proj_debug_before_dr = undefined;
    __proj_debug_ranged_dr = undefined;
    instance_destroy();
    exit;
}

// Check if arrow is out of bounds
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
    exit;
}
