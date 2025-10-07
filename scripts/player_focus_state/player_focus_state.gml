// ============================================
// PLAYER FOCUS STATE HELPERS
// ============================================
// Provides initialization and management helpers for the player focus
// input mode that allows decoupling aim direction from movement.
// Functions here are intentionally stateless and operate on the player
// instance passed as an argument so tests can call them without requiring
// a live room context.

/// @function player_focus_init(player_instance)
/// @description Initialize focus state fields on the player instance.
function player_focus_init(_player) {
    if (_player == undefined || _player == noone) {
        return;
    }

    _player.focus_enabled = true;
    _player.focus_state = {
        active: false,
        buffer_ready: false,
        aim_direction: "",
        aim_vector_x: 0,
        aim_vector_y: 0,
        retreat_direction: "",
        retreat_vector_x: 0,
        retreat_vector_y: 0,
        hold_duration_ms: 250,
        last_aim_time: 0,
        last_retreat_time: 0,
        prev_facing_dir: "down",
        restore_facing_pending: false,
        last_exit_time: 0,
        last_update_time: 0,
        indicator: {
            aim_visible: false,
            aim_label: "",
            retreat_visible: false,
            retreat_label: ""
        },
        pending_retreat: false,
        pending_retreat_direction: "",
        pending_retreat_vector_x: 0,
        pending_retreat_vector_y: 0,
        suppress_next_release: false,
        ranged_followup: {
            active: false,
            aim_direction: "",
            aim_vector: { x: 0, y: 0 }
        }
    };
}

/// @function player_focus_update(player_instance)
/// @description Update focus state based on current inputs.
function player_focus_update(_player) {
    if (_player == undefined || _player == noone) {
        return;
    }

    if (!variable_struct_exists(_player, "focus_state")) {
        player_focus_init(_player);
    }

    if (!_player.focus_enabled) {
        _player.focus_state.active = false;
        return;
    }

    var _state = _player.focus_state;
    var _focus_key = ord("J");
    var _now = current_time;

    if (!_state.active && keyboard_check_pressed(_focus_key)) {
        _state.active = true;
        _state.buffer_ready = false;
        _state.prev_facing_dir = _player.facing_dir;
        _state.restore_facing_pending = false;
        _state.retreat_direction = "";
        _state.retreat_vector_x = 0;
        _state.retreat_vector_y = 0;
        _state.last_retreat_time = 0;
        _state.indicator.retreat_visible = false;
        _state.indicator.retreat_label = "";
        _state.suppress_next_release = false;
    }

    if (_state.active) {
        var _input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
        var _input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

        // NOTE: WASD during focus mode only controls movement, NOT aim
        // Aim stays locked to prev_facing_dir (direction when J was pressed)
        // if (_input_x != 0 || _input_y != 0) {
        //     player_focus_apply_direction(_player, _input_x, _input_y, _now);
        // } else {
        //     player_focus_prune_buffers(_player, _now);
        // }

        _player.facing_dir = _state.prev_facing_dir;

        if (keyboard_check_released(_focus_key)) {
            _state.active = false;
            _state.last_exit_time = _now;
            _state.restore_facing_pending = true;
            player_focus_prune_buffers(_player, _now);
        }
    } else {
        player_focus_prune_buffers(_player, _now);

        if (_state.restore_facing_pending) {
            _player.facing_dir = _state.prev_facing_dir;
            _state.restore_facing_pending = false;
            if (_state.retreat_direction == "") {
                _state.indicator.retreat_visible = false;
                _state.indicator.retreat_label = "";
            }
        }
    }

    _state.last_update_time = _now;
}

/// @function player_focus_apply_direction(player_instance, dx, dy, timestamp)
/// @description Internal helper to store aim direction based on input axes.
function player_focus_apply_direction(_player, _dx, _dy, _timestamp) {
    if (_player == undefined || _player == noone) {
        return;
    }

    if (!variable_struct_exists(_player, "focus_state")) {
        player_focus_init(_player);
    }

    var _resolved = player_focus_resolve_direction(_dx, _dy);
    if (_resolved == undefined) {
        return;
    }

    var _state = _player.focus_state;
    _state.aim_direction = _resolved.label;
    _state.aim_vector_x = _resolved.x;
    _state.aim_vector_y = _resolved.y;
    _state.last_aim_time = _timestamp;
    _state.buffer_ready = true;

    _state.indicator.aim_visible = true;
    _state.indicator.aim_label = _state.aim_direction;
}

/// @function player_focus_prune_buffers(player_instance, timestamp)
/// @description Expire cached aim/retreat buffers when they exceed hold duration.
function player_focus_prune_buffers(_player, _timestamp) {
    if (_player == undefined || _player == noone || !variable_struct_exists(_player, "focus_state")) {
        return;
    }

    var _state = _player.focus_state;
    var _expiry = _state.hold_duration_ms;

    if (_state.aim_direction != "" && (_timestamp - _state.last_aim_time) > _expiry) {
        _state.aim_direction = "";
        _state.aim_vector_x = 0;
        _state.aim_vector_y = 0;
        _state.indicator.aim_visible = false;
        _state.indicator.aim_label = "";
    }

    if (_state.retreat_direction != "" && (_timestamp - _state.last_retreat_time) > _expiry) {
        _state.retreat_direction = "";
        _state.retreat_vector_x = 0;
        _state.retreat_vector_y = 0;
        _state.indicator.retreat_visible = false;
        _state.indicator.retreat_label = "";
    }

    _state.buffer_ready = (_state.aim_direction != "") || (_state.retreat_direction != "");
}

/// @function player_focus_resolve_direction(dx, dy)
/// @description Convert input vector into a normalized direction label.
function player_focus_resolve_direction(_dx, _dy) {
    var _norm_x = clamp(_dx, -1, 1);
    var _norm_y = clamp(_dy, -1, 1);

    if (_norm_x == 0 && _norm_y == 0) {
        return undefined;
    }

    var _label = "";

    if (_norm_y < 0) {
        _label = "up";
    } else if (_norm_y > 0) {
        _label = "down";
    }

    if (_norm_x < 0) {
        _label = (_label == "") ? "left" : _label + "_left";
    } else if (_norm_x > 0) {
        _label = (_label == "") ? "right" : _label + "_right";
    }

    var _length = sqrt(sqr(_norm_x) + sqr(_norm_y));
    if (_length == 0) {
        _length = 1;
    }

    return {
        label: _label,
        x: _norm_x / _length,
        y: _norm_y / _length
    };
}

/// @function player_focus_set_retreat(player_instance, direction_label)
/// @description Set the buffered retreat direction while in focus mode.
function player_focus_set_retreat(_player, _direction_label) {
    if (_player == undefined || _player == noone) {
        return;
    }

    if (!variable_struct_exists(_player, "focus_state")) {
        player_focus_init(_player);
    }

    var _state = _player.focus_state;
    _state.retreat_direction = _direction_label ?? "";
    var _resolved = (_state.retreat_direction != "")
        ? player_focus_resolve_direction_from_label(_state.retreat_direction)
        : undefined;

    if (_resolved != undefined) {
        _state.retreat_vector_x = _resolved.x;
        _state.retreat_vector_y = _resolved.y;
    } else {
        _state.retreat_vector_x = 0;
        _state.retreat_vector_y = 0;
    }

    _state.last_retreat_time = current_time;
    _state.buffer_ready = (_state.aim_direction != "") || (_state.retreat_direction != "");

    if (_state.retreat_direction != "") {
        _state.indicator.retreat_visible = true;
        _state.indicator.retreat_label = _state.retreat_direction;
    } else {
        _state.indicator.retreat_visible = false;
        _state.indicator.retreat_label = "";
    }
}

/// @function player_focus_consume_for_attack(player_instance)
/// @description Prepare focus data for an outgoing attack, clearing aim buffers.
function player_focus_consume_for_attack(_player) {
    if (_player == undefined || _player == noone) {
        return {
            use_focus: false,
            aim_direction: "",
            aim_vector: { x: 0, y: 0 },
            retreat_direction: ""
        };
    }

    if (!variable_struct_exists(_player, "focus_state")) {
        var _fallback_vec = player_focus_resolve_direction_from_label(_player.facing_dir);
        if (_fallback_vec == undefined) _fallback_vec = { x: 0, y: 0 };
        return {
            use_focus: false,
            aim_direction: _player.facing_dir,
            aim_vector: _fallback_vec,
            retreat_direction: ""
        };
    }

    var _state = _player.focus_state;
    var _was_in_focus = (_state.prev_facing_dir != "");

    // Always use the locked facing direction (prev_facing_dir) from when J was pressed
    // WASD during focus mode only controls movement, not aim
    var _aim_label = _state.prev_facing_dir;
    var _aim_vector = player_focus_resolve_direction_from_label(_aim_label);
    if (_aim_vector == undefined) _aim_vector = { x: 0, y: 0 };

    var _retreat_label = _state.retreat_direction;
    // Set use_focus to true if we were in focus mode
    var _use_focus = _was_in_focus || (_retreat_label != "");
    var _retreat_vector = player_focus_resolve_direction_from_label(_retreat_label);
    if (_retreat_vector == undefined) _retreat_vector = { x: 0, y: 0 };

    show_debug_message("=== FOCUS CONSUME DEBUG ===");
    show_debug_message("Current facing_dir: " + string(_player.facing_dir));
    show_debug_message("Locked direction (will fire): " + string(_aim_label));
    show_debug_message("Use focus: " + string(_use_focus));
    show_debug_message("==========================");

    // Clear aim buffer after consumption
    _state.aim_direction = "";
    _state.aim_vector_x = 0;
    _state.aim_vector_y = 0;
    _state.indicator.aim_visible = false;
    _state.indicator.aim_label = "";
    _state.buffer_ready = (_retreat_label != "");

    return {
        use_focus: _use_focus,
        aim_direction: _aim_label,
        aim_vector: _aim_vector,
        retreat_direction: _retreat_label,
        retreat_vector: _retreat_vector
    };
}

/// @function player_focus_queue_retreat_dash(player_instance, direction_label)
/// @description Queue a retreat dash to execute once melee recovery completes.
function player_focus_queue_retreat_dash(_player, _direction_label) {
    if (_player == undefined || _player == noone || _direction_label == undefined || _direction_label == "") {
        return false;
    }

    if (!variable_struct_exists(_player, "focus_state")) {
        player_focus_init(_player);
    }

    var _state = _player.focus_state;
    var _resolved = player_focus_resolve_direction_from_label(_direction_label);
    if (_resolved == undefined) {
        return false;
    }

    _state.pending_retreat = true;
    _state.pending_retreat_direction = _direction_label;
    _state.pending_retreat_vector_x = _resolved.x;
    _state.pending_retreat_vector_y = _resolved.y;

    // Clear stored retreat buffer now that it's queued
    _state.retreat_direction = "";
    _state.retreat_vector_x = 0;
    _state.retreat_vector_y = 0;
    _state.indicator.retreat_visible = false;
    _state.indicator.retreat_label = "";
    _state.buffer_ready = false;

    return true;
}

/// @function player_focus_peek_pending_retreat(player_instance)
/// @description Inspect pending retreat dash without consuming it.
function player_focus_peek_pending_retreat(_player) {
    if (_player == undefined || _player == noone || !variable_struct_exists(_player, "focus_state")) {
        return undefined;
    }

    var _state = _player.focus_state;
    if (!_state.pending_retreat || _state.pending_retreat_direction == "") {
        return undefined;
    }

    return {
        direction: _state.pending_retreat_direction,
        vector: {
            x: _state.pending_retreat_vector_x,
            y: _state.pending_retreat_vector_y
        }
    };
}

/// @function player_focus_consume_pending_retreat(player_instance)
/// @description Consume the pending retreat dash request (if any).
function player_focus_consume_pending_retreat(_player) {
    var _peek = player_focus_peek_pending_retreat(_player);
    if (_peek == undefined) {
        return undefined;
    }

    var _state = _player.focus_state;
    _state.pending_retreat = false;
    _state.pending_retreat_direction = "";
    _state.pending_retreat_vector_x = 0;
    _state.pending_retreat_vector_y = 0;

    _state.ranged_followup.active = false;
    return _peek;
}

/// @function player_focus_is_retreat_direction(facing_label, retreat_label)
/// @description Determine if retreat direction is mostly opposite the facing direction.
function player_focus_is_retreat_direction(_facing_label, _retreat_label) {
    var _face_vec = player_focus_resolve_direction_from_label(_facing_label);
    var _retreat_vec = player_focus_resolve_direction_from_label(_retreat_label);

    if (_face_vec == undefined || _retreat_vec == undefined) {
        return false;
    }

    var _dot = (_face_vec.x * _retreat_vec.x) + (_face_vec.y * _retreat_vec.y);
    return (_dot <= -0.25); // Require retreat to be largely opposite
}

/// @function player_focus_try_melee_combo(player_instance, retreat_label)
/// @description Attempt to perform focus melee combo (attack + retreat dash).
function player_focus_try_melee_combo(_player, _retreat_label) {
    if (_player == undefined || _player == noone || _retreat_label == undefined || _retreat_label == "") {
        return false;
    }

    if (!variable_struct_exists(_player, "focus_state")) {
        return false;
    }

    var _state = _player.focus_state;

    if (!_state.active || !_player.can_attack) {
        return false;
    }

    if (!player_focus_is_retreat_direction(_player.facing_dir, _retreat_label)) {
        return false;
    }

    var _attack_vec = player_focus_resolve_direction_from_label(_player.facing_dir);
    if (_attack_vec == undefined) {
        _attack_vec = { x: 0, y: 0 };
    }

    _state.aim_direction = _player.facing_dir;
    _state.aim_vector_x = _attack_vec.x;
    _state.aim_vector_y = _attack_vec.y;
    _state.retreat_direction = _retreat_label;
    var _retreat_vec = player_focus_resolve_direction_from_label(_retreat_label);
    if (_retreat_vec != undefined) {
        _state.retreat_vector_x = _retreat_vec.x;
        _state.retreat_vector_y = _retreat_vec.y;
    }
    _state.buffer_ready = true;

    var _focus_info = player_focus_consume_for_attack(_player);
    _focus_info.use_focus = true;
    _focus_info.retreat_direction = _retreat_label;

    _player.__focus_combo_info = _focus_info;
    with (_player) {
        player_execute_attack(__focus_combo_info);
        __focus_combo_info = undefined;
    }

    _state.suppress_next_release = true;

    return true;
}

/// @function player_focus_fire_ranged_followup(player_instance)
/// @description Fire the stored ranged projectile after retreat dash completes.
function player_focus_fire_ranged_followup(_player) {
    if (_player == undefined || _player == noone) return false;
    if (!variable_struct_exists(_player, "focus_state")) return false;

    var _state = _player.focus_state;
    if (!_state.ranged_followup.active) return false;

    var _aim_dir = _state.ranged_followup.aim_direction;
    var _fire_fn = method(_player, player_fire_ranged_projectile_local);
    var _success = _fire_fn(_aim_dir);

    _state.ranged_followup.active = false;
    _state.ranged_followup.aim_direction = "";
    _state.ranged_followup.aim_vector = { x: 0, y: 0 };

    return _success;
}

/// @function player_focus_get_metadata(player_instance)
/// @description Return a copy of the focus state metadata for other systems.
function player_focus_get_metadata(_player) {
    if (_player == undefined || _player == noone || !variable_struct_exists(_player, "focus_state")) {
        return undefined;
    }

    var _state = _player.focus_state;
    return {
        active: _state.active,
        buffer_ready: _state.buffer_ready,
        aim_direction: _state.aim_direction,
        aim_vector: { x: _state.aim_vector_x, y: _state.aim_vector_y },
        retreat_direction: _state.retreat_direction,
        retreat_vector: { x: _state.retreat_vector_x, y: _state.retreat_vector_y },
        hold_duration_ms: _state.hold_duration_ms,
        last_aim_time: _state.last_aim_time,
        last_retreat_time: _state.last_retreat_time,
        last_update_time: _state.last_update_time,
        indicator: {
            aim_visible: _state.indicator.aim_visible,
            aim_label: _state.indicator.aim_label,
            retreat_visible: _state.indicator.retreat_visible,
            retreat_label: _state.indicator.retreat_label
        },
        pending_retreat: _state.pending_retreat,
        pending_retreat_direction: _state.pending_retreat_direction,
        suppress_next_release: _state.suppress_next_release,
        ranged_followup: _state.ranged_followup
    };
}

/// @function player_focus_resolve_direction_from_label(direction_label)
/// @description Convert a direction label back into a normalized vector.
function player_focus_resolve_direction_from_label(_label) {
    if (_label == undefined || _label == "") {
        return undefined;
    }

    var _x = 0;
    var _y = 0;

    switch (_label) {
        case "up": _y = -1; break;
        case "down": _y = 1; break;
        case "left": _x = -1; break;
        case "right": _x = 1; break;
        case "up_left": _x = -1; _y = -1; break;
        case "up_right": _x = 1; _y = -1; break;
        case "down_left": _x = -1; _y = 1; break;
        case "down_right": _x = 1; _y = 1; break;
        default: return undefined;
    }

    var _length = sqrt(sqr(_x) + sqr(_y));
    if (_length == 0) {
        _length = 1;
    }

    return {
        x: _x / _length,
        y: _y / _length
    };
}

/// @function player_focus_allows_facing_updates(player_instance)
/// @description Helper to determine if movement logic can safely update facing.
function player_focus_allows_facing_updates(_player) {
    if (_player == undefined || _player == noone || !variable_struct_exists(_player, "focus_state")) {
        return true;
    }

    return !_player.focus_state.active;
}
/// @function player_focus_execute_ranged_volley(player_instance, aim_dir, retreat_dir, retreat_vector, is_ranged)
/// @description Execute retreat dash first, then fire projectile from buffered aim direction.
function player_focus_execute_ranged_volley(_player, _aim_dir, _retreat_dir, _retreat_vector, _is_ranged) {
    if (_player == undefined || _player == noone) return false;
    if (!_is_ranged) return false;
    if (_retreat_dir == undefined || _retreat_dir == "") return false;

    if (!variable_struct_exists(_player, "focus_state")) {
        player_focus_init(_player);
    }

    if (_player.dash_cooldown > 0 || _player.state == PlayerState.dashing) {
        return false;
    }

    if (!player_focus_is_retreat_direction(_player.facing_dir, _retreat_dir)) {
        return false;
    }

    var _state = _player.focus_state;

    var _aim_vec = player_focus_resolve_direction_from_label(_aim_dir);
    if (_aim_vec == undefined) _aim_vec = { x: 0, y: 0 };

    var _ret_vec = _retreat_vector;
    if (_ret_vec == undefined || (abs(_ret_vec.x) < 0.001 && abs(_ret_vec.y) < 0.001)) {
        _ret_vec = player_focus_resolve_direction_from_label(_retreat_dir);
        if (_ret_vec == undefined) _ret_vec = { x: 0, y: 0 };
    }

    _state.pending_retreat = false;
    _state.pending_retreat_direction = "";
    _state.pending_retreat_vector_x = 0;
    _state.pending_retreat_vector_y = 0;
    _state.ranged_followup.active = true;
    _state.ranged_followup.aim_direction = _aim_dir;
    _state.ranged_followup.aim_vector = _aim_vec;
    _state.active = false;
    _state.buffer_ready = false;
    _state.suppress_next_release = true;
    _state.retreat_direction = "";
    _state.retreat_vector_x = 0;
    _state.retreat_vector_y = 0;
    _state.indicator.retreat_visible = false;
    _state.indicator.retreat_label = "";

    with (_player) {
        start_dash(_retreat_dir, true);
        state = PlayerState.dashing;
    }

    return true;
}
