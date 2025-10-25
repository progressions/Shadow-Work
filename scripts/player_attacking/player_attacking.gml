function player_attacking(){
    // Attack state is handled by animation system
    // The state automatically returns to idle when animation completes
    // This function now only handles attack input detection from other states
}

function player_state_attacking() {
    // Handle knockback first
    player_handle_knockback();

    // Allow movement during ranged charge
    if (ranged_charge_active) {
        // Get movement input - use InputX/InputY for proper analog stick support
        var _hor = InputX(INPUT_CLUSTER.NAVIGATION);
        var _ver = InputY(INPUT_CLUSTER.NAVIGATION);

        // Update move_dir based on input
        if (_hor == 0 && _ver == 0) {
            move_dir = "idle";
            // Stop all footstep sounds when idle
            stop_all_footstep_sounds();

            // Apply friction to decelerate
            velocity_x *= friction_factor;
            velocity_y *= friction_factor;

            // Stop completely if velocity is very small
            if (abs(velocity_x) < 0.01) velocity_x = 0;
            if (abs(velocity_y) < 0.01) velocity_y = 0;
        } else {
            // Update facing direction based on movement (but don't change attack direction)
            // Use strongest axis for analog input
            if (abs(_ver) > abs(_hor)) {
                if (_ver > 0) {
                    move_dir = "down";
                } else if (_ver < 0) {
                    move_dir = "up";
                }
            } else {
                if (_hor > 0) {
                    move_dir = "right";
                } else if (_hor < 0) {
                    move_dir = "left";
                }
            }

            // Detect terrain for footstep sounds
            var _terrain = get_terrain_at_position(x, y);

            // Apply speed modifiers
            var speed_modifier = get_status_effect_modifier("speed");
            var final_move_speed = move_speed * terrain_speed_modifier * speed_modifier;

            // Normalize diagonal input
            var _input_magnitude = sqrt(_hor * _hor + _ver * _ver);
            if (_input_magnitude > 0) {
                _hor /= _input_magnitude;
                _ver /= _input_magnitude;
            }

            // Acceleration-based movement
            velocity_x += _hor * acceleration * final_move_speed;
            velocity_y += _ver * acceleration * final_move_speed;

            // Cap velocity at max_velocity
            var _velocity_magnitude = sqrt(velocity_x * velocity_x + velocity_y * velocity_y);
            if (_velocity_magnitude > max_velocity * final_move_speed) {
                var _scale = (max_velocity * final_move_speed) / _velocity_magnitude;
                velocity_x *= _scale;
                velocity_y *= _scale;
            }

            // Play footstep sounds
            var _footstep_sound = global.terrain_footstep_sounds[$ _terrain] ?? snd_footsteps_grass;
            play_sfx(_footstep_sound, 0.3, 4, true);

            // Stop all other terrain footstep sounds
            var _terrain_names = variable_struct_get_names(global.terrain_footstep_sounds);
            for (var i = 0; i < array_length(_terrain_names); i++) {
                var _other_sound = global.terrain_footstep_sounds[$ _terrain_names[i]];
                if (_other_sound != _footstep_sound) {
                    stop_looped_sfx(_other_sound);
                }
            }
        }

        // Apply velocity to position with collision
        if (velocity_x != 0 || velocity_y != 0) {
            var _collided = move_and_collide(velocity_x, velocity_y, tilemap);
            if (array_length(_collided) > 0) {
                // On collision, reduce velocity
                for (var i = 0; i < array_length(_collided); i++) {
                    var _collision = _collided[i];
                    var _has_struct = is_struct(_collision);
                    var _has_nx = _has_struct && variable_struct_exists(_collision, "nx");
                    var _has_ny = _has_struct && variable_struct_exists(_collision, "ny");

                    if (_has_nx && abs(_collision.nx) > 0.5) velocity_x *= 0.3;
                    if (_has_ny && abs(_collision.ny) > 0.5) velocity_y *= 0.3;

                    if (!_has_struct || (!_has_nx && !_has_ny)) {
                        velocity_x *= 0.3;
                        velocity_y *= 0.3;
                    }
                }
            }
        }
    } else {
        // Normal attack (melee) - stop all movement
        stop_all_footstep_sounds();
    }
}

function player_handle_attack_input() {
    // Can't attack when stunned
    if (is_stunned) {
        can_attack = false;
        return;
    }

    var _was_ready = can_attack;

    if (attack_cooldown > 0) {
        attack_cooldown--;
        can_attack = false;
    } else {
        can_attack = true;
    }

    // Play ready sound when weapon becomes available (transition from not ready to ready)
    if (!_was_ready && can_attack && equipped.right_hand != undefined) {
        play_sfx(snd_player_ready, 1, 5);
    }

    var _attack_pressed = InputPressed(INPUT_VERB.ATTACK);
    var _attack_released = InputReleased(INPUT_VERB.ATTACK);

    // Instant brake on attack button press for precise positioning
    if (_attack_pressed) {
        velocity_x = 0;
        velocity_y = 0;
    }

    // Handle ranged charge release
    if (_attack_released && ranged_charge_active) {
        player_release_ranged_charge();
        return;
    }

    // Start attack on button press
    if (_attack_pressed && can_attack) {
        player_execute_attack();
    }
}

function player_execute_attack() {
    var _was_dashing = (state == PlayerState.dashing);
    var _dash_attack_ready = (dash_attack_window > 0 && facing_dir == last_dash_direction);

    if (_was_dashing) {
        last_dash_direction = facing_dir;
        dash_attack_window = dash_attack_window_duration;
    }

    if (_was_dashing && facing_dir == last_dash_direction) {
        _dash_attack_ready = true;
    }

    if (_dash_attack_ready) {
        is_dash_attacking = true;
        apply_timed_trait("defense_vulnerability", 1.0);
        // Action tracker: dash attack performed
        action_tracker_log("dash_attack");
    } else {
        is_dash_attacking = false;
    }

    dash_attack_window = 0;

    var _is_ranged = false;
    var _attack_speed = 1.0;

    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        _attack_speed = equipped.right_hand.definition.stats.attack_speed;
        if (equipped.right_hand.definition.stats[$ "requires_ammo"] != undefined) {
            _is_ranged = true;
        }
    }

    if (_is_ranged) {
        var _fire_fn = method(self, player_fire_ranged_projectile_local);
        if (_fire_fn(facing_dir)) {
            attack_cooldown = max(15, round(60 / _attack_speed));
            can_attack = false;
        }
    } else {
        // Track state before attacking so we can return to it
        state_before_attack = state;
        state = PlayerState.attacking;

        var attack = instance_create_layer(x, y, "Instances", obj_attack);
        attack.creator = self;

        attack_cooldown = max(15, round(60 / _attack_speed));
        can_attack = false;

        if (is_dash_attacking) {
            play_sfx(snd_dash_attack, 1, false);
        } else if (equipped.right_hand != undefined) {
            switch (equipped.right_hand.definition.handedness) {
                case WeaponHandedness.two_handed:
                    play_sfx(snd_attack_sword, 1, false);
                    break;
                default:
                    play_sfx(snd_attack_sword, 1, false);
                    break;
            }
        } else {
            play_sfx(snd_attack_sword, 1, false);
        }
    }
	
	return true;
}

/// @function spawn_player_arrow()
/// @description Spawns arrow projectile from player after windup completes
/// @param {string} _direction - Direction to fire ("up", "down", "left", "right")
/// @param {real} _charge_multiplier - Damage multiplier from charge time (0.5 to 1.0)
/// @returns {bool} True if arrow spawned successfully
function spawn_player_arrow(_direction, _charge_multiplier = 1.0) {
    if (equipped.right_hand == undefined || equipped.right_hand.definition == undefined) {
        show_debug_message("No ranged weapon equipped");
        return false;
    }

    var _weapon_definition = equipped.right_hand.definition;
    var _weapon_stats = _weapon_definition.stats;
    var _range_profile_id = RangeProfile.generic_arrow;

    if (_weapon_definition.range_profile_override != undefined) {
        _range_profile_id = _weapon_definition.range_profile_override;
    } else if (variable_struct_exists(_weapon_stats, "range_profile_override")) {
        _range_profile_id = _weapon_stats.range_profile_override;
    } else if (_weapon_definition.range_profile != undefined) {
        _range_profile_id = _weapon_definition.range_profile;
    } else if (variable_struct_exists(_weapon_stats, "range_profile")) {
        _range_profile_id = _weapon_stats.range_profile;
    }

    var _arrow_x = x;
    var _arrow_y = y;

    switch (_direction) {
        case "right":
            _arrow_x += 16;
            _arrow_y += 8;
            break;
        case "up":
            _arrow_x += 16;
            _arrow_y -= 16;
            break;
        case "left":
            _arrow_x -= 16;
            _arrow_y -= 20;
            break;
        case "down":
            _arrow_x -= 16;
            _arrow_y += 8;
            break;
    }

    var _arrow = instance_create_layer(_arrow_x, _arrow_y, "Instances", obj_arrow);
    _arrow.creator = self;
    _arrow.damage = get_total_damage();
    _arrow.charge_multiplier = _charge_multiplier; // Store charge multiplier
    _arrow.range_profile_id = _range_profile_id;
    _arrow.range_profile = projectile_get_range_profile(_range_profile_id);
    _arrow.range_profile_id_cached = _range_profile_id;
    _arrow.max_travel_distance = _arrow.range_profile.max_distance + _arrow.range_profile.overshoot_buffer;
    _arrow.spawn_x = _arrow.x;
    _arrow.spawn_y = _arrow.y;
    _arrow.weapon_range_stat = _weapon_stats[$ "range"] ?? 0;

    switch (_direction) {
        case "right": _arrow.direction = 0; break;
        case "up": _arrow.direction = 90; break;
        case "left": _arrow.direction = 180; break;
        case "down": _arrow.direction = 270; break;
    }
    _arrow.image_angle = _arrow.direction;

    // Play attack sound when projectile spawns
    play_sfx(snd_bow_attack, 1, false);

    if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
        show_debug_message("Player arrow spawned - charge multiplier: " + string(_charge_multiplier));
    }

    return true;
}

function player_fire_ranged_projectile_local(_direction) {
    if (!has_ammo("arrows")) {
        show_debug_message("No arrows available!");
        return false;
    }

    if (equipped.right_hand == undefined || equipped.right_hand.definition == undefined) {
        show_debug_message("No ranged weapon equipped");
        return false;
    }

    var _original_facing = facing_dir;
    if (_direction != "") facing_dir = _direction;

    // Track state before attacking so we can return to it
    state_before_attack = state;
    // Enter charging phase - projectile spawns when button is RELEASED
    state = PlayerState.attacking;
    ranged_charge_active = true;          // Mark that we're charging a ranged attack
    ranged_charge_time = 0;               // Reset charge timer
    ranged_windup_active = true;          // Keep this for animation system compatibility
    ranged_windup_complete = false;       // Reset windup flag
    ranged_windup_direction = facing_dir; // Store direction for arrow spawn

    // DON'T consume ammo yet - wait for button release

    // Play windup sound (attack sound plays when arrow spawns on release)
    play_sfx(snd_ranged_windup, 1, false);

    if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
        show_debug_message("Player starting ranged charge (hold to charge, release to fire)");
    }

    facing_dir = _original_facing;

    return true;
}

/// @function player_release_ranged_charge()
/// @description Fires the charged ranged attack when button is released
function player_release_ranged_charge() {
    if (!ranged_charge_active) {
        return false;
    }

    // Check if we still have ammo
    if (!has_ammo("arrows")) {
        show_debug_message("No arrows available at release!");
        // Cancel the charge
        ranged_charge_active = false;
        ranged_windup_active = false;
        ranged_windup_complete = false;
        state = state_before_attack;
        state_before_attack = PlayerState.idle;
        return false;
    }

    // Get attack speed for cooldown calculation
    var _attack_speed = 1.0;
    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        _attack_speed = equipped.right_hand.definition.stats.attack_speed;
    }

    // Calculate charge multiplier based on charge time vs weapon cooldown
    var _weapon_cooldown = max(15, round(60 / _attack_speed));
    var _charge_ratio = ranged_charge_time / _weapon_cooldown;
    var _charge_multiplier = lerp(0.5, 1.0, min(1.0, _charge_ratio));

    // Consume ammo NOW (at release)
    consume_ammo("arrows", 1);

    // Spawn the arrow with charge multiplier
    spawn_player_arrow(ranged_windup_direction, _charge_multiplier);

    // Set attack cooldown
    attack_cooldown = _weapon_cooldown;
    can_attack = false;

    // Reset all charge flags
    ranged_charge_active = false;
    ranged_charge_time = 0;
    ranged_windup_active = false;
    ranged_windup_complete = false;

    // Return to previous state
    state = state_before_attack;
    state_before_attack = PlayerState.idle;

    if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
        show_debug_message("Ranged charge released! Charge time: " + string(ranged_charge_time) + " frames, Cooldown: " + string(_weapon_cooldown) + " frames, Multiplier: " + string(_charge_multiplier));
    }

    return true;
}
