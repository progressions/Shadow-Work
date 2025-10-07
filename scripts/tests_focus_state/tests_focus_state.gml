// ============================================
// Focus State Tests
// ============================================
// Lightweight assertions to validate focus state helpers without
// requiring a full room or input loop. These tests rely on the helper
// functions exposed by scripts/player_focus_state.

function focus_state_run_tests() {
    var _results = [
        focus_state_test_initialization(),
        focus_state_test_aim_buffer(),
        focus_state_test_diagonal_mapping(),
        focus_state_test_indicator_updates(),
        focus_state_test_focus_attack_consumption(),
        focus_state_test_retreat_queue(),
        focus_state_test_retreat_direction_check(),
        focus_state_test_ranged_followup_flag(),
        focus_state_test_hold_expiry()
    ];

    var _all_passed = true;
    for (var i = 0; i < array_length(_results); i++) {
        if (!_results[i].passed) {
            _all_passed = false;
        }
        show_debug_message(_results[i].message);
    }

    if (_all_passed) {
        show_debug_message("✓ Focus state helper tests passed");
    } else {
        show_debug_message("⚠️ Focus state helper tests reported failures");
    }

    return _all_passed;
}

function focus_state_test_initialization() {
    var _player = {
        facing_dir: "down"
    };

    player_focus_init(_player);

    var _state_exists = variable_struct_exists(_player, "focus_state");
    var _state = _state_exists ? _player.focus_state : undefined;
    var _active_default = _state_exists && !_state.active;
    var _hold_default = _state_exists && (_state.hold_duration_ms == 250);
    var _indicator_default = _state_exists && !_state.indicator.aim_visible && !_state.indicator.retreat_visible;

    return {
        passed: _state_exists && _active_default && _hold_default && _indicator_default,
        message: (_state_exists && _active_default && _hold_default && _indicator_default)
            ? "✓ Focus state initializes with indicator defaults"
            : "✗ Focus state initialization missing defaults"
    };
}

function focus_state_test_aim_buffer() {
    var _player = { facing_dir: "down" };
    player_focus_init(_player);

    var _timestamp = 1000;
    player_focus_apply_direction(_player, 1, 0, _timestamp);

    var _state = _player.focus_state;
    var _aimed_right = (_state.aim_direction == "right") && (_state.aim_vector_x > 0.99);
    var _buffer_ready = _state.buffer_ready;
    var _indicator = _state.indicator.aim_visible && _state.indicator.aim_label == "right";

    return {
        passed: _aimed_right && _buffer_ready && _indicator,
        message: (_aimed_right && _buffer_ready && _indicator)
            ? "✓ Focus aim buffer stores right direction"
            : "✗ Focus aim buffer did not store expected direction"
    };
}

function focus_state_test_diagonal_mapping() {
    var _cases = [
        { dx: 1, dy: 0, label: "right" },
        { dx: -1, dy: 0, label: "left" },
        { dx: 0, dy: 1, label: "down" },
        { dx: 0, dy: -1, label: "up" },
        { dx: 1, dy: -1, label: "up_right" },
        { dx: -1, dy: -1, label: "up_left" },
        { dx: 1, dy: 1, label: "down_right" },
        { dx: -1, dy: 1, label: "down_left" }
    ];

    var _all_ok = true;

    for (var i = 0; i < array_length(_cases); i++) {
        var _case = _cases[i];
        var _resolved = player_focus_resolve_direction(_case.dx, _case.dy);
        if (_resolved == undefined || _resolved.label != _case.label) {
            _all_ok = false;
            break;
        }

        var _length = sqrt(sqr(_resolved.x) + sqr(_resolved.y));
        if (abs(_length - 1) > 0.001) {
            _all_ok = false;
            break;
        }
    }

    return {
        passed: _all_ok,
        message: _all_ok
            ? "✓ Focus resolves eight-direction inputs"
            : "✗ Focus direction mapping failed"
    };
}

function focus_state_test_indicator_updates() {
    var _player = { facing_dir: "down" };
    player_focus_init(_player);

    player_focus_apply_direction(_player, 0, 1, 0);
    player_focus_set_retreat(_player, "up_left");

    var _state = _player.focus_state;
    var _aim_indicator = _state.indicator.aim_visible && _state.indicator.aim_label == "down";
    var _retreat_indicator = _state.indicator.retreat_visible && _state.indicator.retreat_label == "up_left";

    player_focus_set_retreat(_player, "");
    var _retreat_cleared = !_state.indicator.retreat_visible;

    return {
        passed: _aim_indicator && _retreat_indicator && _retreat_cleared,
        message: (_aim_indicator && _retreat_indicator && _retreat_cleared)
            ? "✓ Focus indicators update for aim and retreat"
            : "✗ Focus indicator state did not update"
    };
}

function focus_state_test_focus_attack_consumption() {
    var _player = { facing_dir: "down" };
    player_focus_init(_player);

    player_focus_apply_direction(_player, 1, 0, 5);
    player_focus_set_retreat(_player, "up_left");

    var _info = player_focus_consume_for_attack(_player);
    var _state = _player.focus_state;

    var _aim_cleared = (_state.aim_direction == "") && !_state.indicator.aim_visible;
    var _retreat_retained = (_state.retreat_direction == "up_left");

    var _info_valid = _info.use_focus && _info.aim_direction == "right" && _info.retreat_direction == "up_left";

    return {
        passed: _aim_cleared && _retreat_retained && _info_valid,
        message: (_aim_cleared && _retreat_retained && _info_valid)
            ? "✓ Focus attack consumption clears aim and reports retreat"
            : "✗ Focus attack consumption produced unexpected data"
    };
}

function focus_state_test_retreat_queue() {
    var _player = { facing_dir: "down" };
    player_focus_init(_player);

    player_focus_queue_retreat_dash(_player, "down_right");

    var _peek = player_focus_peek_pending_retreat(_player);
    var _peek_valid = (_peek != undefined) && (_peek.direction == "down_right");

    var _consumed = player_focus_consume_pending_retreat(_player);
    var _state = _player.focus_state;
    var _cleared = !_state.pending_retreat && _state.pending_retreat_direction == "";

    return {
        passed: _peek_valid && (_consumed != undefined) && (_consumed.direction == "down_right") && _cleared,
        message: (_peek_valid && (_consumed != undefined) && (_consumed.direction == "down_right") && _cleared)
            ? "✓ Focus retreat queue stores and clears pending dash"
            : "✗ Focus retreat queue did not behave as expected"
    };
}

function focus_state_test_retreat_direction_check() {
    var _cases = [
        { facing: "up", retreat: "down", expected: true },
        { facing: "up", retreat: "up", expected: false },
        { facing: "right", retreat: "left", expected: true },
        { facing: "right", retreat: "down_right", expected: false }
    ];

    var _all_ok = true;
    for (var i = 0; i < array_length(_cases); i++) {
        var _case = _cases[i];
        var _result = player_focus_is_retreat_direction(_case.facing, _case.retreat);
        if (_result != _case.expected) {
            _all_ok = false;
            break;
        }
    }

    return {
        passed: _all_ok,
        message: _all_ok
            ? "✓ Retreat direction check distinguishes forward vs backward"
            : "✗ Retreat direction check failed"
    };
}

function focus_state_test_ranged_followup_flag() {
    var _player = {
        facing_dir: "right",
        focus_enabled: true,
        dash_cooldown: 0,
        state: PlayerState.idle,
        dash_called: false,
        dash_last_dir: ""
    };

    _player.start_dash = function(_dir, _preserve) {
        self.dash_called = true;
        self.dash_last_dir = _dir;
        self.state = PlayerState.dashing;
    };

    player_focus_init(_player);

    var _result = player_focus_execute_ranged_volley(_player, "right", "left", { x: -1, y: 0 }, true);

    var _state = _player.focus_state;
    var _follow = _state.ranged_followup.active && _state.ranged_followup.aim_direction == "right";
    var _dash_called = _player.dash_called && _player.dash_last_dir == "left";

    _state.ranged_followup.active = false; // reset for reusable state

    return {
        passed: _result && _follow && _dash_called,
        message: (_result && _follow && _dash_called)
            ? "✓ Ranged followup volley queues dash and follow-up"
            : "✗ Ranged volley setup failed"
    };
}

function focus_state_test_hold_expiry() {
    var _player = { facing_dir: "down" };
    player_focus_init(_player);

    player_focus_apply_direction(_player, 0, -1, 0);

    var _state = _player.focus_state;
    var _expiry_time = _state.hold_duration_ms + 1;
    player_focus_prune_buffers(_player, _expiry_time);

    var _aim_cleared = (_state.aim_direction == "") && !_state.indicator.aim_visible;

    return {
        passed: _aim_cleared,
        message: _aim_cleared
            ? "✓ Focus aim buffer expires after hold duration"
            : "✗ Focus aim buffer did not expire after hold duration"
    };
}
