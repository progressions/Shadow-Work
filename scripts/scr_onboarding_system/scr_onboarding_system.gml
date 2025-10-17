// ============================================
// ONBOARDING QUEST SYSTEM - Room-Based Quest System
// ============================================
// Uses action tracker for generic action logging
// Quest sequences defined in room creation code
// Auto-skips quests with already-completed objectives

/// @function onboarding_initialize()
/// @description Initialize the global onboarding quest system at game start
function onboarding_initialize() {
    global.onboarding_quests = {
        active_quest_index: 0,
        quest_sequence: [],           // Array of quest definitions
        current_quest: undefined,     // Current active quest struct
        all_completed: false,
        room_initialized: false       // Flag to prevent re-initialization
    };
}

/// @function onboarding_initialize_for_room(quest_definitions)
/// @description Initialize onboarding quests for a specific room (call from Room Creation Code)
/// @param {array} quest_definitions Array of quest definition structs
function onboarding_initialize_for_room(_quest_definitions) {
    // Initialize system if not already done
    if (!variable_global_exists("onboarding_quests")) {
        onboarding_initialize();
    }

    // Don't re-initialize if already done for this room
    if (global.onboarding_quests.room_initialized) {
        show_debug_message("[Onboarding] Already initialized for this room");
        return;
    }

    // Set quest sequence
    global.onboarding_quests.quest_sequence = _quest_definitions;
    global.onboarding_quests.active_quest_index = 0;
    global.onboarding_quests.all_completed = false;
    global.onboarding_quests.room_initialized = true;

    show_debug_message("[Onboarding] Initialized with " + string(array_length(_quest_definitions)) + " quests");

    // Start the first quest
    onboarding_start_sequence();
}

/// @function onboarding_check_action_completion()
/// @description Check if current quest's completion condition is met (called by action tracker)
function onboarding_check_action_completion() {
    // Don't process if onboarding hasn't been initialized or is complete
    if (!variable_global_exists("onboarding_quests")) return;
    if (global.onboarding_quests.all_completed) return;

    var _quest = global.onboarding_quests.current_quest;

    // No current quest or already completed
    if (_quest == undefined || _quest.completed) return;

    // Check if quest has a completion function
    if (!variable_struct_exists(_quest, "check_completion")) {
        show_debug_message("[Onboarding] Warning: Quest " + _quest.quest_id + " has no check_completion function");
        return;
    }

    // Call the completion check function
    if (_quest.check_completion()) {
        show_debug_message("[Onboarding] Quest objective completed: " + _quest.quest_id);
        onboarding_complete_quest(_quest.quest_id);
    }
}

/// @function onboarding_complete_quest(quest_id)
/// @description Mark quest as complete, award XP, play sound, and advance to next quest
/// @param {string} quest_id The ID of the quest to complete
function onboarding_complete_quest(_quest_id) {
    var _quest = global.onboarding_quests.current_quest;

    // Verify we're completing the correct quest
    if (_quest == undefined || _quest.quest_id != _quest_id) return;

    // Mark as completed
    _quest.completed = true;

    // Award XP to player
    if (instance_exists(obj_player) && variable_struct_exists(_quest, "xp_reward")) {
        obj_player.xp += _quest.xp_reward;
        // Show floating text for XP reward
        spawn_floating_text(obj_player.x, obj_player.y, "+" + string(_quest.xp_reward) + " XP", c_yellow);
    }

    // Play quest resolved sound
    if (asset_get_index("snd_onboarding_quest_resolved") != -1) {
        play_sfx(snd_onboarding_quest_resolved, 1);
    }

    show_debug_message("[Onboarding] Quest completed: " + _quest_id);

    // Advance to next quest
    onboarding_advance_to_next_quest();
}

/// @function onboarding_advance_to_next_quest()
/// @description Move to the next quest in the sequence or mark tutorial complete
function onboarding_advance_to_next_quest() {
    global.onboarding_quests.active_quest_index++;

    var _quest_count = array_length(global.onboarding_quests.quest_sequence);

    if (global.onboarding_quests.active_quest_index >= _quest_count) {
        // All quests complete - tutorial finished
        global.onboarding_quests.all_completed = true;
        global.onboarding_quests.current_quest = undefined;

        show_debug_message("[Onboarding] Tutorial complete!");
        return;
    }

    // Load next quest
    global.onboarding_quests.current_quest = global.onboarding_quests.quest_sequence[global.onboarding_quests.active_quest_index];

    // AUTO-SKIP LOGIC: Check if objective is already completed
    if (variable_struct_exists(global.onboarding_quests.current_quest, "check_completion")) {
        if (global.onboarding_quests.current_quest.check_completion()) {
            show_debug_message("[Onboarding] Quest objective already completed - auto-skipping: " + global.onboarding_quests.current_quest.quest_id);

            // Mark as completed and advance (recursive call)
            global.onboarding_quests.current_quest.completed = true;
            onboarding_advance_to_next_quest();
            return; // Exit - recursion will handle next quest
        }
    }

    // Quest is not yet completed - activate it normally
    show_debug_message("[Onboarding] Advanced to quest: " + global.onboarding_quests.current_quest.quest_id);

    // Play quest available sound for new quest
    if (asset_get_index("snd_onboarding_quest_available") != -1) {
        play_sfx(snd_onboarding_quest_available, 1);
    }

    // Spawn marker if quest has one
    if (variable_struct_exists(global.onboarding_quests.current_quest, "marker_location")) {
        var _marker_loc = global.onboarding_quests.current_quest.marker_location;
        if (_marker_loc != undefined) {
            onboarding_spawn_marker(
                global.onboarding_quests.current_quest.quest_id,
                _marker_loc.x,
                _marker_loc.y
            );
        }
    }
}

/// @function onboarding_start_sequence()
/// @description Begin the onboarding sequence by setting the first quest as active
function onboarding_start_sequence() {
    if (array_length(global.onboarding_quests.quest_sequence) == 0) {
        show_debug_message("[Onboarding] Error: No quests in sequence");
        return;
    }

    global.onboarding_quests.active_quest_index = 0;
    global.onboarding_quests.current_quest = global.onboarding_quests.quest_sequence[0];

    // Check if first quest is already completed (auto-skip)
    if (variable_struct_exists(global.onboarding_quests.current_quest, "check_completion")) {
        if (global.onboarding_quests.current_quest.check_completion()) {
            show_debug_message("[Onboarding] First quest already completed - auto-skipping: " + global.onboarding_quests.current_quest.quest_id);
            global.onboarding_quests.current_quest.completed = true;
            onboarding_advance_to_next_quest();
            return;
        }
    }

    // Play first quest available sound
    if (asset_get_index("snd_onboarding_quest_available") != -1) {
        play_sfx(snd_onboarding_quest_available, 1);
    }

    show_debug_message("[Onboarding] Sequence started: " + global.onboarding_quests.current_quest.quest_id);

    // Spawn marker if first quest has one
    if (variable_struct_exists(global.onboarding_quests.current_quest, "marker_location")) {
        var _marker_loc = global.onboarding_quests.current_quest.marker_location;
        if (_marker_loc != undefined) {
            onboarding_spawn_marker(
                global.onboarding_quests.current_quest.quest_id,
                _marker_loc.x,
                _marker_loc.y
            );
        }
    }
}

/// @function onboarding_get_current_quest_text()
/// @description Get the display text for the current quest
/// @return {string} Quest display text or empty string
function onboarding_get_current_quest_text() {
    if (global.onboarding_quests.current_quest != undefined) {
        return global.onboarding_quests.current_quest.display_text;
    }
    return "";
}

/// @function onboarding_is_active()
/// @description Check if onboarding sequence is currently running
/// @return {bool} True if there is an active quest
function onboarding_is_active() {
    if (!variable_global_exists("onboarding_quests")) return false;
    return global.onboarding_quests.current_quest != undefined && !global.onboarding_quests.all_completed;
}

/// @function onboarding_is_complete()
/// @description Check if all onboarding quests have been completed
/// @return {bool} True if tutorial is finished
function onboarding_is_complete() {
    if (!variable_global_exists("onboarding_quests")) return false;
    return global.onboarding_quests.all_completed;
}

/// @function onboarding_spawn_marker(quest_id, marker_x, marker_y)
/// @description Spawn an animated quest marker at the specified location
/// @param {string} quest_id The quest this marker belongs to
/// @param {real} marker_x X position for the marker
/// @param {real} marker_y Y position for the marker
/// @return {id} Instance ID of created marker, or noone if failed
function onboarding_spawn_marker(_quest_id, _marker_x, _marker_y) {
    if (!instance_exists(obj_quest_marker)) {
        show_debug_message("[Onboarding] Error: obj_quest_marker does not exist");
        return noone;
    }

    var _marker = instance_create_layer(_marker_x, _marker_y, "Instances", obj_quest_marker);
    _marker.quest_id = _quest_id;

    show_debug_message("[Onboarding] Spawned quest marker: " + _quest_id + " at (" + string(_marker_x) + ", " + string(_marker_y) + ")");
    return _marker;
}

/// @function onboarding_destroy_markers(quest_id)
/// @description Destroy all markers associated with a specific quest
/// @param {string} quest_id The quest ID to clear markers for
function onboarding_destroy_markers(_quest_id) {
    with (obj_quest_marker) {
        if (quest_id == _quest_id) {
            instance_destroy();
        }
    }
}
