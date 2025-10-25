function player_attacking(){
    // Attack state is handled by animation system
    // The state automatically returns to idle when animation completes
    // This function now only handles attack input detection from other states
}

function player_state_attacking() {
    // Stop all footstep sounds when attacking
    stop_all_footstep_sounds();

    // In attack state - wait for animation to complete
    // The animation system will reset state to idle when attack animation finishes

    // Handle knockback
    player_handle_knockback();
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

    // Instant brake on attack button press for precise positioning
    if (_attack_pressed) {
        velocity_x = 0;
        velocity_y = 0;
    }

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
/// @returns {bool} True if arrow spawned successfully
function spawn_player_arrow(_direction) {
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
        show_debug_message("Player arrow spawned after windup complete");
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
    // Enter windup phase - projectile spawns AFTER animation completes
    state = PlayerState.attacking;
    ranged_windup_active = true;          // Mark that we're winding up a ranged attack
    ranged_windup_complete = false;       // Reset windup flag
    ranged_windup_direction = facing_dir; // Store direction for arrow spawn

    // Consume ammo now (before windup, so interrupt doesn't waste ammo)
    consume_ammo("arrows", 1);

    // Play windup sound (attack sound plays when arrow spawns)
    play_sfx(snd_ranged_windup, 1, false);

    if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
        show_debug_message("Player starting ranged attack windup (arrow will spawn after animation completes)");
    }

    facing_dir = _original_facing;

    return true;
}
