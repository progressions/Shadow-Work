// Check for Hola's wind deflection aura (passive trajectory alteration)
if (instance_exists(obj_player)) {
    var companions = get_active_companions();
    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check for Hola with affinity 5+
        if (companion.companion_id == "hola" && companion.affinity >= 5.0) {
            if (variable_struct_exists(companion.auras, "wind_deflection") && companion.auras.wind_deflection.active) {
                var aura = companion.auras.wind_deflection;
                var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

                // Only deflect if within radius
                if (dist_to_player <= aura.radius) {
                    // Calculate deflection strength based on distance (stronger closer to player)
                    var proximity_factor = 1 - (dist_to_player / aura.radius); // 1.0 at player, 0.0 at edge

                    // Scale deflection by affinity (affinity 5 = weak, affinity 10 = strong)
                    var affinity_scale = (companion.affinity - 5.0) / 5.0; // 0.0 at affinity 5, 1.0 at affinity 10

                    // Calculate angle away from player
                    var angle_to_player = point_direction(x, y, obj_player.x, obj_player.y);
                    var angle_away = angle_to_player + 180;

                    // Deflection strength (max 15 degrees per frame when very close at high affinity)
                    var max_deflection = 15 * proximity_factor * affinity_scale;

                    // Bend trajectory away from player
                    var current_dir = direction;
                    var angle_diff = angle_difference(angle_away, current_dir);

                    // Apply gradual deflection
                    direction += sign(angle_diff) * min(abs(angle_diff), max_deflection);
                }
            }
        }
    }
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

// Check for collision with player
var _hit_player = instance_place(x, y, obj_player);
if (_hit_player != noone) {
    var _damage_type = DamageType.physical;
    if (variable_instance_exists(self, "damage_type")) {
        _damage_type = damage_type;
    }

    var _status_modifier = 1.0;
    if (instance_exists(creator) && method(creator, get_status_effect_modifier) != undefined) {
        _status_modifier = method(creator, get_status_effect_modifier)("damage");
    }

    // Roll for critical hit
    var _is_crit = false;
    var _crit_multiplier = 1.0;
    if (instance_exists(creator)) {
        if (random(1) < creator.crit_chance) {
            _is_crit = true;
            _crit_multiplier = creator.crit_multiplier;
        }
    }

    var _base_damage = damage * _status_modifier * _crit_multiplier;
    var _resistance_multiplier = method(_hit_player, get_damage_modifier_for_type)(_damage_type);
    var _after_resistance = _base_damage * _resistance_multiplier;

    // Apply player ranged damage reduction (enemy ranged attacks)
    var _player_dr = method(_hit_player, get_ranged_damage_reduction)();
    var _after_defense = _after_resistance - _player_dr;

    var _final_damage;
    if (_resistance_multiplier <= 0) {
        _final_damage = 0;
    } else if (_after_defense <= 0) {
        _final_damage = 1;
    } else {
        _final_damage = _after_defense;
    }

    _final_damage = ceil(_final_damage);

    var _status_effects = [];
    if (variable_instance_exists(self, "status_effects_on_hit") && is_array(status_effects_on_hit)) {
        _status_effects = status_effects_on_hit;
    }

    __proj_damage_type = _damage_type;
    __proj_final_damage = _final_damage;
    __proj_res_multiplier = _resistance_multiplier;
    __proj_status_effects = _status_effects;

    // Store crit flag for player visual feedback
    __proj_is_crit = _is_crit;

    with (_hit_player) {
        if (state != PlayerState.dead) {
            var _impact_damage = other.__proj_final_damage;
            var _impact_type = other.__proj_damage_type;
            var _res_mult = other.__proj_res_multiplier;
            var _was_crit = other.__proj_is_crit;

            if (_impact_damage > 0) {
                hp -= _impact_damage;
                companion_on_player_damaged(id, _impact_damage, _impact_type);
                combat_timer = 0; // Reset combat timer for companion evading

                // Apply visual feedback (stronger for crits)
                if (_was_crit) {
                    image_blend = c_red;
                    alarm[0] = 15; // Longer flash for crit
                    freeze_frame(3); // Freeze on crit
                } else {
                    image_blend = c_red;
                    alarm[0] = 10; // Normal flash
                    freeze_frame(2); // Brief freeze
                }

                play_sfx(snd_player_hit, 1, false);
                spawn_damage_number(x, y - 16, _impact_damage, _impact_type, self);
            } else {
                play_sfx(snd_attack_miss, 1, false);
                spawn_immune_text(x, y - 16, self);
            }

            // Apply knockback
            kb_x = sign(x - other.x) * 2;
            kb_y = sign(y - other.y) * 2;

            // Apply status effects carried by projectile
            if (_impact_damage > 0) {
                var _effects = other.__proj_status_effects;
                if (is_array(_effects)) {
                    for (var i = 0; i < array_length(_effects); i++) {
                        var effect_data = _effects[i];
                        if (random(1) < effect_data.chance) {
                            apply_status_effect(effect_data.effect);
                            if (variable_global_exists("debug_mode") && global.debug_mode) {
                                show_debug_message("Projectile applied status effect: " + string(effect_data.effect));
                            }
                        }
                    }
                }
            }

            // Check if player died
            if (hp <= 0) {
                state = PlayerState.dead;
                play_sfx(snd_player_death, 1, false);
                show_debug_message("Player died from projectile");
            }

            if (variable_global_exists("debug_mode") && global.debug_mode) {
                show_debug_message("Enemy projectile dealt " + string(_impact_damage) + " " + damage_type_to_string(_impact_type) + " damage (res mult=" + string(_res_mult) + ")");
            }
        }
    }

    __proj_damage_type = undefined;
    __proj_final_damage = undefined;
    __proj_res_multiplier = undefined;
    __proj_status_effects = undefined;
    __proj_is_crit = undefined;

    instance_destroy();
    exit;
}

// Check if arrow is out of bounds
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
    exit;
}
