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
    if (attack_cooldown > 0) {
        attack_cooldown--;
        can_attack = false;
    } else {
        can_attack = true;
    }

    var _attack_pressed = keyboard_check_pressed(ord("J"));
    var _attack_released = keyboard_check_released(ord("J"));

    // Instant brake on attack button press for precise positioning
    if (_attack_pressed || _attack_released) {
        velocity_x = 0;
        velocity_y = 0;
    }

    if (_attack_released && can_attack) {
        if (focus_enabled && variable_struct_exists(self, "focus_state") && focus_state.suppress_next_release) {
            focus_state.suppress_next_release = false;
            return;
        }
        var _focus_info = player_focus_consume_for_attack(self);
        player_execute_attack(_focus_info);
    } else if (_attack_pressed && !focus_enabled && can_attack) {
        var _fallback_vec = player_focus_resolve_direction_from_label(facing_dir);
        if (_fallback_vec == undefined) _fallback_vec = { x: 0, y: 0 };
        var _fallback_info = {
            use_focus: false,
            aim_direction: facing_dir,
            aim_vector: _fallback_vec,
            retreat_direction: ""
        };
        player_execute_attack(_fallback_info);
    }
}

function player_execute_attack(_focus_info) {
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
    } else {
        is_dash_attacking = false;
    }

    dash_attack_window = 0;

    var _use_focus = false;
    var _focus_attack_dir = facing_dir;
    var _focus_retreat_dir = "";
    var _focus_retreat_vector = { x: 0, y: 0 };

    if (_focus_info != undefined) {
        _use_focus = _focus_info.use_focus;
        if (_focus_info.aim_direction != "") {
            _focus_attack_dir = _focus_info.aim_direction;
        }
        _focus_retreat_dir = _focus_info.retreat_direction;
        if (_focus_info.retreat_vector != undefined) {
            _focus_retreat_vector = _focus_info.retreat_vector;
        }
    }

    var _original_facing = facing_dir;

    var _is_ranged = false;
    var _attack_speed = 1.0;

    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        _attack_speed = equipped.right_hand.definition.stats.attack_speed;
        if (equipped.right_hand.definition.stats[$ "requires_ammo"] != undefined) {
            _is_ranged = true;
        }
    }

    // For ranged attacks, use the focus attack direction directly (don't rely on facing_dir)
    var _fire_direction = _focus_attack_dir;
    if (_fire_direction == "") {
        _fire_direction = facing_dir;
    }

    if (_is_ranged && _use_focus && _focus_retreat_dir != "") {
        if (player_focus_execute_ranged_volley(self, _focus_attack_dir, _focus_retreat_dir, _focus_retreat_vector, _is_ranged)) {
            attack_cooldown = max(15, round(60 / _attack_speed));
            can_attack = false;
            return true;
        }
    }

    if (_is_ranged) {
        var _fire_fn = method(self, player_fire_ranged_projectile_local);
        if (_fire_fn(_fire_direction)) {
            attack_cooldown = max(15, round(60 / _attack_speed));
            can_attack = false;
        }
    } else {
        // For melee attacks, temporarily set facing_dir to focus direction for attack animation
        if (_focus_attack_dir != "" && _focus_attack_dir != facing_dir) {
            facing_dir = _focus_attack_dir;
        }

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

        if (_use_focus) {
            if (_focus_retreat_dir != "") {
                player_focus_queue_retreat_dash(self, _focus_retreat_dir);
            }
        } else if (_focus_retreat_dir != "") {
            if (player_focus_execute_ranged_volley(self, _focus_attack_dir, _focus_retreat_dir, _focus_retreat_vector, _is_ranged)) {
                attack_cooldown = max(15, round(60 / _attack_speed));
                can_attack = false;
                return true;
            }
        }
    }

    // Don't restore facing direction if we used focus mode - keep the attack direction
    if (!_use_focus) {
        facing_dir = _original_facing;
    }

    if (_use_focus && variable_struct_exists(self, "focus_state")) {
        focus_state.active = false;
        focus_state.buffer_ready = false;
    }

    return true;
}

function player_fire_ranged_projectile_local(_direction) {
    if (!has_ammo("arrows")) {
        show_debug_message("No arrows available!");
        return false;
    }

    var _original_facing = facing_dir;
    if (_direction != "") facing_dir = _direction;

    state = PlayerState.attacking;

    var _arrow_x = x;
    var _arrow_y = y;

    switch (facing_dir) {
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

    switch (facing_dir) {
        case "right": _arrow.direction = 0; break;
        case "up": _arrow.direction = 90; break;
        case "left": _arrow.direction = 180; break;
        case "down": _arrow.direction = 270; break;
    }
    _arrow.image_angle = _arrow.direction;

    consume_ammo("arrows", 1);
    play_sfx(snd_bow_attack, 1, false);

    facing_dir = _original_facing;

    return true;
}
