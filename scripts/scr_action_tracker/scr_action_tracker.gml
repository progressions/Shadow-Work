// ============================================
// ACTION TRACKER SYSTEM - Generic Action Logging
// ============================================
// Lightweight system for tracking player actions without quest-specific code
// Used by room-based quest systems to check completion conditions

/// @function action_tracker_initialize()
/// @description Initialize the global action tracker at game start
function action_tracker_initialize() {
    global.action_tracker = {
        actions: {},           // Struct: action_name -> true or value
        action_log: []         // Array of all actions in order (for debugging)
    };
}

/// @function action_tracker_log(_action_name, _value)
/// @description Log an action that occurred (generic, not quest-specific)
/// @param {string} _action_name Name of the action (e.g., "chest_opened", "torch_lit")
/// @param {any} _value Optional value to associate with the action (e.g., item_id for pickups)
function action_tracker_log(_action_name, _value = true) {
    if (!variable_global_exists("action_tracker")) {
        action_tracker_initialize();
    }

    // Store the action with its value
    global.action_tracker.actions[$ _action_name] = _value;

    // Log to array for debugging
    array_push(global.action_tracker.action_log, {
        action: _action_name,
        value: _value,
        timestamp: current_time
    });

    show_debug_message("[Action Tracker] " + _action_name + " = " + string(_value));

    // Notify onboarding system to check for quest completion
    if (variable_global_exists("onboarding_quests")) {
        onboarding_check_action_completion();
    }
}

/// @function action_tracker_has(_action_name, _expected_value)
/// @description Check if an action has occurred
/// @param {string} _action_name Name of the action to check
/// @param {any} _expected_value Optional value to match against (for specific items, etc.)
/// @return {bool} True if action occurred (and matches expected_value if provided)
function action_tracker_has(_action_name, _expected_value = undefined) {
    if (!variable_global_exists("action_tracker")) {
        return false;
    }

    if (!variable_struct_exists(global.action_tracker.actions, _action_name)) {
        return false;
    }

    var _logged_value = global.action_tracker.actions[$ _action_name];

    // If no expected value, just check if action exists
    if (_expected_value == undefined) {
        return true;
    }

    // Otherwise, check if values match
    return _logged_value == _expected_value;
}

/// @function action_tracker_clear()
/// @description Clear all tracked actions (useful for new game, room reset, etc.)
function action_tracker_clear() {
    if (variable_global_exists("action_tracker")) {
        global.action_tracker.actions = {};
        global.action_tracker.action_log = [];
        show_debug_message("[Action Tracker] Cleared all actions");
    }
}

/// @function action_tracker_debug_print()
/// @description Print all tracked actions for debugging
function action_tracker_debug_print() {
    if (!variable_global_exists("action_tracker")) {
        show_debug_message("[Action Tracker] Not initialized");
        return;
    }

    show_debug_message("=== ACTION TRACKER DEBUG ===");
    show_debug_message("Total actions: " + string(array_length(global.action_tracker.action_log)));

    var _action_names = variable_struct_get_names(global.action_tracker.actions);
    for (var i = 0; i < array_length(_action_names); i++) {
        var _name = _action_names[i];
        var _value = global.action_tracker.actions[$ _name];
        show_debug_message("  " + _name + " = " + string(_value));
    }
}
