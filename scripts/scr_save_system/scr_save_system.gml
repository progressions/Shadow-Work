// Save System
// Minimal implementation with no-op functions during rebuild phase

/// @function save_game
/// @description Save game to specified slot with full serialization
/// @param {real} _slot_number The save slot number (1-5)
function save_game(_slot_number) {
	
    show_debug_message("=== SAVE GAME - SLOT " + string(_slot_number) + " ===");

    // Debug: Check what's in player's inventory before saving
    if (instance_exists(obj_player)) {
        with (obj_player) {
            show_debug_message("Player inventory count: " + string(array_length(inventory)));
            show_debug_message("Player equipped - Right: " + (equipped.right_hand != undefined ? "YES" : "NO"));
            show_debug_message("Player equipped - Left: " + (equipped.left_hand != undefined ? "YES" : "NO"));
            show_debug_message("Player position: (" + string(x) + ", " + string(y) + ")");
        }
    }

    // Save current room state first
    save_room();

    // Create root save struct
    var _player_data = undefined;
    if (instance_exists(obj_player)) {
        _player_data = obj_player.serialize();
    }

    var _save_struct = {
        save_version: 1,
        timestamp: current_time,
        current_room: room_get_name(room),

        player: _player_data,
        companions: serialize_companions(),
        room_states: global.save_data,
        audio_config: global.audio_config,
        chatterbox_variables: ChatterboxVariablesExport()
    };

    // Convert to JSON
    var _json_string = json_stringify(_save_struct);

    // SHOW WHAT WE'RE ACTUALLY SAVING
    show_debug_message("========================================");
    show_debug_message("SAVING THIS DATA:");
    show_debug_message("Player X: " + string(_save_struct.player.x));
    show_debug_message("Player Y: " + string(_save_struct.player.y));
    show_debug_message("Player HP: " + string(_save_struct.player.hp));
    show_debug_message("Inventory items: " + string(array_length(_save_struct.player.inventory)));
    show_debug_message("Equipped right_hand: " + string(_save_struct.player.equipped.right_hand));
    show_debug_message("Audio Config:");
    show_debug_message("  sfx_enabled: " + string(_save_struct.audio_config.sfx_enabled));
    show_debug_message("  sfx_volume: " + string(_save_struct.audio_config.sfx_volume));
    show_debug_message("  master_volume: " + string(_save_struct.audio_config.master_volume));
    show_debug_message("========================================");

    // Write to file
    var _filename = "save_slot_" + string(_slot_number) + ".json";
    var _file = file_text_open_write(_filename);
    file_text_write_string(_file, _json_string);
    file_text_close(_file);

    show_debug_message("Save complete: " + _filename);
    show_debug_message("File size: " + string(string_length(_json_string)) + " characters");
    return true;
}

/// @function serialize_companions
/// @description Serialize all companion data
function serialize_companions() {
    var _companions_array = [];

    with (obj_companion_parent) {
        var _companion_data = {
            companion_id: companion_id,
            x: x,
            y: y,
            is_recruited: is_recruited,
            state: state,
            affinity: affinity,
            quest_flags: quest_flags,

            // Triggers
            triggers: triggers,

            // Auras
            auras: auras,

            // Animation state
            last_dir_index: last_dir_index
        };

        array_push(_companions_array, _companion_data);
    }

    return _companions_array;
}

/// @function serialize_inventory
/// @description Serialize inventory and equipment
function serialize_inventory() {
    if (!instance_exists(obj_player)) {
        return undefined;
    }

    with (obj_player) {
        // Helper function to safely get item identifier from equipped items or inventory items
        var _get_item_key = function(_item) {
            if (_item == undefined) return undefined;
            if (!is_struct(_item)) return undefined;

            // Check if this is an equipped item (has item_key/item_id directly)
            if (variable_struct_exists(_item, "item_key")) {
                return _item.item_key;
            }
            if (variable_struct_exists(_item, "item_id")) {
                return _item.item_id;
            }

            // Check if this is an inventory item (has definition with item_key/item_id)
            if (variable_struct_exists(_item, "definition")) {
                var _def = _item.definition;
                if (is_struct(_def)) {
                    if (variable_struct_exists(_def, "item_key")) {
                        return _def.item_key;
                    }
                    if (variable_struct_exists(_def, "item_id")) {
                        return _def.item_id;
                    }
                }
            }

            return undefined;
        };

        // Serialize equipped items (store item keys)
        var _equipped_serialized = {
            right_hand: _get_item_key(equipped.right_hand),
            left_hand: _get_item_key(equipped.left_hand),
            head: _get_item_key(equipped.head),
            torso: _get_item_key(equipped.torso),
            legs: _get_item_key(equipped.legs)
        };

        // Serialize inventory items (array of item keys with counts)
        var _inventory_serialized = [];
        for (var i = 0; i < array_length(inventory); i++) {
            var _inv_item = inventory[i];
            if (is_struct(_inv_item)) {
                var _item_key = _get_item_key(_inv_item);
                if (_item_key != undefined) {
                    // Store item key and count for stacking support
                    array_push(_inventory_serialized, {
                        item_key: _item_key,
                        count: variable_struct_exists(_inv_item, "count") ? _inv_item.count : 1
                    });
                }
            }
        }

        return {
            inventory: _inventory_serialized,
            equipped: _equipped_serialized
        };
    }

    return undefined;
}

/// @function load_game
/// @description Load game from specified slot with full deserialization
/// @param {real} _slot_number The save slot number (1-5)
function load_game(_slot_number) {
    show_debug_message("=== LOAD GAME - SLOT " + string(_slot_number) + " ===");

    // Check if save file exists
    var _filename = "save_slot_" + string(_slot_number) + ".json";
    if (!file_exists(_filename)) {
        show_debug_message("ERROR: Save file does not exist: " + _filename);
        return false;
    }

    // Read JSON file
    var _file = file_text_open_read(_filename);
    var _json_string = file_text_read_string(_file);
    file_text_close(_file);

    // Parse JSON
    var _save_struct = json_parse(_json_string);
    if (!is_struct(_save_struct)) {
        show_debug_message("ERROR: Failed to parse save file");
        return false;
    }

    // Check save version
    if (!variable_struct_exists(_save_struct, "save_version")) {
        show_debug_message("ERROR: Save file missing version");
        return false;
    }

    // SHOW WHAT WE'RE LOADING
    show_debug_message("========================================");
    show_debug_message("LOADING THIS DATA:");
    if (variable_struct_exists(_save_struct, "player")) {
        show_debug_message("Player X: " + string(_save_struct.player.x));
        show_debug_message("Player Y: " + string(_save_struct.player.y));
        show_debug_message("Player HP: " + string(_save_struct.player.hp));
        if (variable_struct_exists(_save_struct.player, "inventory")) {
            show_debug_message("Inventory items: " + string(array_length(_save_struct.player.inventory)));
        }
        if (variable_struct_exists(_save_struct.player, "equipped")) {
            show_debug_message("Equipped right_hand: " + string(_save_struct.player.equipped.right_hand));
        }
    }
    show_debug_message("========================================");

    // Restore global room states
    if (variable_struct_exists(_save_struct, "room_states")) {
        global.save_data = _save_struct.room_states;
    }

    // Restore audio config
    if (variable_struct_exists(_save_struct, "audio_config")) {
        show_debug_message("Restoring audio config from save file:");
        show_debug_message("  sfx_enabled: " + string(_save_struct.audio_config.sfx_enabled) + " (type: " + typeof(_save_struct.audio_config.sfx_enabled) + ")");
        show_debug_message("  sfx_volume: " + string(_save_struct.audio_config.sfx_volume));
        show_debug_message("  master_volume: " + string(_save_struct.audio_config.master_volume));

        // Manually reconstruct audio_config to ensure correct types
        global.audio_config.music_enabled = _save_struct.audio_config[$ "music_enabled"] ?? true;
        global.audio_config.sfx_enabled = _save_struct.audio_config[$ "sfx_enabled"] ?? true;
        global.audio_config.music_volume = _save_struct.audio_config[$ "music_volume"] ?? 1;
        global.audio_config.sfx_volume = _save_struct.audio_config[$ "sfx_volume"] ?? 1;
        global.audio_config.master_volume = _save_struct.audio_config[$ "master_volume"] ?? 1;

        show_debug_message("After restoration:");
        show_debug_message("  sfx_enabled: " + string(global.audio_config.sfx_enabled) + " (type: " + typeof(global.audio_config.sfx_enabled) + ")");
    } else {
        show_debug_message("WARNING: No audio_config in save file!");
    }

    // Restore Chatterbox variables
    if (variable_struct_exists(_save_struct, "chatterbox_variables")) {
        ChatterboxVariablesImport(_save_struct.chatterbox_variables);
    }

    // Store save data for room transition
    global.pending_load_data = _save_struct;

    // Transition to saved room if different
    var _saved_room_name = _save_struct.current_room;
    var _saved_room_index = asset_get_index(_saved_room_name);

    if (_saved_room_index == -1) {
        show_debug_message("ERROR: Saved room not found: " + _saved_room_name);
        return false;
    }

    show_debug_message("Transitioning to saved room: " + _saved_room_name);

    // Pause gameplay while transition plays out
    global.game_paused = true;

    // Kick off room transition (fall back to direct room change if transition unavailable)
    if (!transition_start(_saved_room_index, seq_fade_out, seq_fade_in)) {
        show_debug_message("WARNING: transition_start failed, falling back to immediate room change");
        room_goto(_saved_room_index);
    }

    show_debug_message("Load complete: " + _filename);
    return true;
}

/// @function restore_save_data
/// @description Restore save data after room transition (called in Room Start or immediately if same room)
function restore_save_data(_save_struct) {
    show_debug_message("=== RESTORING SAVE DATA ===");
    show_debug_message("Current room: " + room_get_name(room));
    show_debug_message("Player exists: " + string(instance_exists(obj_player)));

    // Ensure audio groups are loaded after save/load
    show_debug_message("Checking audio groups...");
    show_debug_message("  audiogroup_sfx_ui loaded: " + string(audio_group_is_loaded(audiogroup_sfx_ui)));
    show_debug_message("  audiogroup_sfx_world loaded: " + string(audio_group_is_loaded(audiogroup_sfx_world)));

    // Load audio groups if they aren't already loaded
    if (!audio_group_is_loaded(audiogroup_sfx_ui)) {
        audio_group_load(audiogroup_sfx_ui);
    }
    if (!audio_group_is_loaded(audiogroup_sfx_world)) {
        audio_group_load(audiogroup_sfx_world);
    }

    // Debug: Check audio config
    show_debug_message("Audio config in restore_save_data:");
    show_debug_message("  sfx_enabled: " + string(global.audio_config.sfx_enabled) + " (type: " + typeof(global.audio_config.sfx_enabled) + ")");
    show_debug_message("  sfx_volume: " + string(global.audio_config.sfx_volume) + " (type: " + typeof(global.audio_config.sfx_volume) + ")");
    show_debug_message("  master_volume: " + string(global.audio_config.master_volume) + " (type: " + typeof(global.audio_config.master_volume) + ")");

    // Calculate what the final volume should be
    var _final_volume_test = global.audio_config.sfx_enabled
        ? global.audio_config.sfx_volume * global.audio_config.master_volume
        : 0;
    show_debug_message("  Calculated final SFX volume: " + string(_final_volume_test));

    // Set flag to prevent movement/stuck detection during restoration
    global.loading_from_save = true;

    // Clear any previous pending player restore payload
    if (variable_global_exists("pending_player_restore_data")) {
        global.pending_player_restore_data = undefined;
    }

    var _player_data = variable_struct_exists(_save_struct, "player") ? _save_struct.player : undefined;
    var _player_position = undefined;
    var _player_restored = false;

    if (is_struct(_player_data)) {
        if (variable_struct_exists(_player_data, "x") && variable_struct_exists(_player_data, "y")) {
            _player_position = { x: _player_data.x, y: _player_data.y };
        }

        if (instance_exists(obj_player)) {
            show_debug_message("Restoring player data...");
            show_debug_message("BEFORE RESTORE - Player is at: (" + string(obj_player.x) + ", " + string(obj_player.y) + ")");
            obj_player.deserialize(_player_data);
            show_debug_message("AFTER RESTORE - Player is at: (" + string(obj_player.x) + ", " + string(obj_player.y) + ")");
            _player_restored = true;
        } else {
            show_debug_message("WARNING: Player instance not yet available - deferring restore");
        }
    } else {
        show_debug_message("WARNING: Save file missing player data!");
    }

    if (!_player_restored && is_struct(_player_data)) {
        global.pending_player_restore_data = _player_data;
    }

    // Restore companions data SECOND (they need to follow the player's restored position)
    if (variable_struct_exists(_save_struct, "companions")) {
        show_debug_message("Restoring companions...");
        deserialize_companions(_save_struct.companions);
    } else {
        show_debug_message("WARNING: No companion data in save file!");
    }

    // Restore current room state LAST (enemies, chests, etc.)
    show_debug_message("Loading room state...");
    load_room();

    // Reassert saved player position on the next frame to override any spawn adjustments
    if (_player_position != undefined) {
        global.pending_player_position = {
            x: _player_position.x,
            y: _player_position.y
        };
        call_later(1, time_source_units_frames, function() {
            if (instance_exists(obj_player) && is_struct(global.pending_player_position)) {
                obj_player.x = global.pending_player_position.x;
                obj_player.y = global.pending_player_position.y;
            }
            global.pending_player_position = undefined;
        });
    }

    // Attempt deferred player restore now that the room has been rebuilt
    if (!_player_restored) {
        apply_pending_player_restore();
    }

    // Clear the loading flag after a brief delay to let everything settle
    // Use alarm or just clear it after a frame
    call_later(30, time_source_units_frames, function() {
        // If player restore was still pending, try one final time before unpausing systems
        apply_pending_player_restore();

        global.loading_from_save = false;
        global.game_paused = false;
        show_debug_message("Load complete - movement systems re-enabled");

        // Verify player position after delay
        if (instance_exists(obj_player)) {
            show_debug_message("VERIFICATION - Player position after 30 frames: (" + string(obj_player.x) + ", " + string(obj_player.y) + ")");
        }
    });

    show_debug_message("Save data restored successfully");
}


/// @function deserialize_companions
/// @description Restore companion data from save
function deserialize_companions(_companions_array) {
    if (!is_array(_companions_array)) {
        return;
    }

    for (var i = 0; i < array_length(_companions_array); i++) {
        var _companion_data = _companions_array[i];
        if (!is_struct(_companion_data) || !variable_struct_exists(_companion_data, "companion_id")) {
            continue;
        }

        var _companion_id = _companion_data.companion_id;

        // Find companion instance by ID
        with (obj_companion_parent) {
            if (companion_id == _companion_id) {
                // Restore position
                if (variable_struct_exists(_companion_data, "x")) x = _companion_data.x;
                if (variable_struct_exists(_companion_data, "y")) y = _companion_data.y;

                // Restore state
                if (variable_struct_exists(_companion_data, "is_recruited")) is_recruited = _companion_data.is_recruited;
                if (variable_struct_exists(_companion_data, "state")) state = _companion_data.state;
                if (variable_struct_exists(_companion_data, "affinity")) affinity = _companion_data.affinity;
                if (variable_struct_exists(_companion_data, "quest_flags")) quest_flags = _companion_data.quest_flags;
                if (variable_struct_exists(_companion_data, "last_dir_index")) last_dir_index = _companion_data.last_dir_index;

                // Restore triggers
                if (variable_struct_exists(_companion_data, "triggers")) {
                    triggers = _companion_data.triggers;
                }

                // Restore auras
                if (variable_struct_exists(_companion_data, "auras")) {
                    auras = _companion_data.auras;
                }

                show_debug_message("Restored companion: " + _companion_id);
            }
        }
    }

    show_debug_message("Companions restored");
}

/// @function deserialize_inventory
/// @description Restore inventory and equipment from save
function deserialize_inventory(_inventory_data) {
    if (!is_struct(_inventory_data)) {
        show_debug_message("ERROR: Inventory data is not a struct");
        return;
    }

    if (!instance_exists(obj_player)) {
        show_debug_message("ERROR: Player instance does not exist");
        return;
    }

    with (obj_player) {
        show_debug_message("Clearing current inventory...");
        // Clear current inventory
        inventory = [];

        // Restore inventory items
        if (variable_struct_exists(_inventory_data, "inventory") && is_array(_inventory_data.inventory)) {
            var _inv_array = _inventory_data.inventory;
            for (var i = 0; i < array_length(_inv_array); i++) {
                var _inv_entry = _inv_array[i];

                // Handle both old format (string) and new format (struct with item_key and count)
                var _item_key = undefined;
                var _item_count = 1;

                if (is_string(_inv_entry)) {
                    // Old format: just the item key
                    _item_key = _inv_entry;
                } else if (is_struct(_inv_entry)) {
                    // New format: {item_key: "...", count: N}
                    if (variable_struct_exists(_inv_entry, "item_key")) {
                        _item_key = _inv_entry.item_key;
                    }
                    if (variable_struct_exists(_inv_entry, "count")) {
                        _item_count = _inv_entry.count;
                    }
                }

                // Add item to inventory using inventory_add_item for proper structure
                if (_item_key != undefined && variable_struct_exists(global.item_database, _item_key)) {
                    var _item_def = global.item_database[$ _item_key];
                    inventory_add_item(_item_def, _item_count);
                }
            }
        }

        show_debug_message("Inventory items restored: " + string(array_length(inventory)));

        // Restore equipped items
        if (variable_struct_exists(_inventory_data, "equipped") && is_struct(_inventory_data.equipped)) {
            var _equipped_data = _inventory_data.equipped;

            show_debug_message("Restoring equipped items...");

            var _remove_existing_effects = function(_entry) {
                if (_entry != undefined && is_struct(_entry) && variable_struct_exists(_entry, "definition")) {
                    var _def = _entry.definition;
                    if (is_struct(_def) && variable_struct_exists(_def, "stats")) {
                        remove_wielder_effects(_def.stats);
                    }
                }
            };

            _remove_existing_effects(equipped.right_hand);
            _remove_existing_effects(equipped.left_hand);
            _remove_existing_effects(equipped.head);
            _remove_existing_effects(equipped.torso);
            _remove_existing_effects(equipped.legs);

            var _assign_equipped_slot = function(_slot_name, _value) {
                if (!is_function(player_build_equipped_entry_from_save)) {
                    show_debug_message("WARNING: player_build_equipped_entry_from_save not defined");
                    return;
                }
                var _entry = player_build_equipped_entry_from_save(_value);
                if (_entry != undefined) {
                    equipped[$ _slot_name] = _entry;
                    if (variable_struct_exists(_entry.definition, "stats")) {
                        apply_wielder_effects(_entry.definition.stats);
                    }
                }
            };

            // Clear current equipment
            equipped.right_hand = undefined;
            equipped.left_hand = undefined;
            equipped.head = undefined;
            equipped.torso = undefined;
            equipped.legs = undefined;

            // Restore each slot
            if (variable_struct_exists(_equipped_data, "right_hand") && _equipped_data.right_hand != undefined) {
                _assign_equipped_slot("right_hand", _equipped_data.right_hand);
                show_debug_message("  Right hand: " + string(_equipped_data.right_hand));
            }

            if (variable_struct_exists(_equipped_data, "left_hand") && _equipped_data.left_hand != undefined) {
                _assign_equipped_slot("left_hand", _equipped_data.left_hand);
                show_debug_message("  Left hand: " + string(_equipped_data.left_hand));
            }

            if (variable_struct_exists(_equipped_data, "head") && _equipped_data.head != undefined) {
                _assign_equipped_slot("head", _equipped_data.head);
                show_debug_message("  Head: " + string(_equipped_data.head));
            }

            if (variable_struct_exists(_equipped_data, "torso") && _equipped_data.torso != undefined) {
                _assign_equipped_slot("torso", _equipped_data.torso);
                show_debug_message("  Torso: " + string(_equipped_data.torso));
            }

            if (variable_struct_exists(_equipped_data, "legs") && _equipped_data.legs != undefined) {
                _assign_equipped_slot("legs", _equipped_data.legs);
                show_debug_message("  Legs: " + string(_equipped_data.legs));
            }
        }
    }

    show_debug_message("Inventory restored");
}

/// @function apply_pending_player_restore
/// @description Attempt to deserialize the player using any pending save data
function apply_pending_player_restore() {
    if (!variable_global_exists("pending_player_restore_data")) {
        return false;
    }

    var _player_data = global.pending_player_restore_data;
    if (!is_struct(_player_data)) {
        return false;
    }

    if (!instance_exists(obj_player)) {
        return false;
    }

    show_debug_message("Applying deferred player restore...");
    obj_player.deserialize(_player_data);
    global.pending_player_restore_data = undefined;
    return true;
}

/// @function auto_save
/// @description Automatically save game to autosave slot
function auto_save() {
    show_debug_message("=== AUTO SAVE ===");

    // Save current room state first
    save_room();

    // Create root save struct
    var _player_data = undefined;
    if (instance_exists(obj_player)) {
        _player_data = obj_player.serialize();
    }

    var _save_struct = {
        save_version: 1,
        timestamp: current_time,
        current_room: room_get_name(room),

        player: _player_data,
        companions: serialize_companions(),
        room_states: global.save_data,
        audio_config: global.audio_config,
        chatterbox_variables: ChatterboxVariablesExport()
    };

    // Convert to JSON
    var _json_string = json_stringify(_save_struct);

    // Write to autosave file
    var _filename = "autosave.json";
    var _file = file_text_open_write(_filename);
    file_text_write_string(_file, _json_string);
    file_text_close(_file);

    show_debug_message("Auto save complete: " + _filename);
    return true;
}

/// @function get_save_slot_metadata
/// @description Read metadata from a save file without loading the full save
/// @param {real} _slot_number The save slot number (1-5)
/// @return {struct|undefined} Metadata struct or undefined if slot is empty
function get_save_slot_metadata(_slot_number) {
    var _filename = "save_slot_" + string(_slot_number) + ".json";

    // Check if save file exists
    if (!file_exists(_filename)) {
        return undefined;
    }

    // Read and parse the save file
    var _file = file_text_open_read(_filename);
    var _json_string = file_text_read_string(_file);
    file_text_close(_file);

    var _save_struct = json_parse(_json_string);
    if (!is_struct(_save_struct)) {
        return undefined;
    }

    // Extract metadata
    var _metadata = {
        timestamp: _save_struct[$ "timestamp"] ?? 0,
        room_name: _save_struct[$ "current_room"] ?? "Unknown",
        player_level: 1,
        player_hp: 0,
        player_hp_total: 0
    };

    // Extract player data if available
    if (variable_struct_exists(_save_struct, "player") && is_struct(_save_struct.player)) {
        var _player_data = _save_struct.player;
        _metadata.player_level = _player_data[$ "level"] ?? 1;
        _metadata.player_hp = _player_data[$ "hp"] ?? 0;
        _metadata.player_hp_total = _player_data[$ "hp_total"] ?? 0;
    }

    return _metadata;
}

/// @function format_time_ago
/// @description Format a timestamp as "X minutes/hours/days ago"
/// @param {real} _timestamp The timestamp to format (from current_time)
/// @return {string} Formatted time string
function format_time_ago(_timestamp) {
    var _time_diff = current_time - _timestamp; // Milliseconds
    var _seconds = _time_diff / 1000;
    var _minutes = _seconds / 60;
    var _hours = _minutes / 60;
    var _days = _hours / 24;

    if (_seconds < 60) {
        return "Just now";
    } else if (_minutes < 60) {
        var _mins = floor(_minutes);
        return string(_mins) + " min" + (_mins == 1 ? "" : "s") + " ago";
    } else if (_hours < 24) {
        var _hrs = floor(_hours);
        return string(_hrs) + " hour" + (_hrs == 1 ? "" : "s") + " ago";
    } else {
        var _dys = floor(_days);
        return string(_dys) + " day" + (_dys == 1 ? "" : "s") + " ago";
    }
}

/// @function delete_all_saves
/// @description Delete all save files (slots 1-5 and autosave)
function delete_all_saves() {
    show_debug_message("=== DELETING ALL SAVE FILES ===");

    var _deleted_count = 0;

    // Delete manual save slots
    for (var i = 1; i <= 5; i++) {
        var _filename = "save_slot_" + string(i) + ".json";
        if (file_exists(_filename)) {
            file_delete(_filename);
            show_debug_message("Deleted: " + _filename);
            _deleted_count++;
        }
    }

    // Delete autosave
    if (file_exists("autosave.json")) {
        file_delete("autosave.json");
        show_debug_message("Deleted: autosave.json");
        _deleted_count++;
    }

    show_debug_message("Total files deleted: " + string(_deleted_count));
    return _deleted_count;
}

function save_room() {
	// Initialize global.save_data if it doesn't exist
	if (!variable_global_exists("save_data") || !is_struct(global.save_data)) {
		global.save_data = {};
	}

	var _room_struct = {
		objects: []
	}

	// Iterate over all persistent objects and serialize them
	// SKIP objects with GameMaker's persistent flag (player, companions)
	var _item_count = 0;
	with (obj_persistent_parent) {
		// Only save non-persistent objects (enemies, chests, etc.)
		if (!persistent) {
			var _obj_name = object_get_name(object_index);
			show_debug_message("  Saving: " + _obj_name + " at (" + string(x) + ", " + string(y) + ")");

			// Track items being saved
			if (object_index == obj_item_parent || object_is_ancestor(object_index, obj_item_parent)) {
				_item_count++;
				if (variable_instance_exists(id, "item_def") && item_def != undefined) {
					show_debug_message("    Item: " + item_def.name);
				}
			}

			array_push(_room_struct.objects, serialize());
		}
	}

	if (_item_count > 0) {
		show_debug_message("  Total items saved: " + string(_item_count));
	}

	// Store room data in global.save_data using room name as key
	var _room_name = room_get_name(room);
	global.save_data[$ _room_name] = _room_struct;

	show_debug_message("Saved room: " + _room_name + " with " + string(array_length(_room_struct.objects)) + " objects");
	show_debug_message("  Items in room: " + string(_item_count));

	return _room_struct;
}

function load_room() {
	// Set global flag to prevent party controllers from spawning enemies during load
	global.loading_from_save = true;

	// Get the saved room data for the current room
	var _room_name = room_get_name(room);
	var _room_struct = undefined;

	// Check if save data exists and has this room
	
		if (variable_struct_exists(global.save_data, _room_name)) {
			_room_struct = global.save_data[$ _room_name];
		}
	

	// Exit if no saved data for this room (first visit - use room-placed instances)
	if (!is_struct(_room_struct)) {
		show_debug_message("No saved data for room: " + _room_name + " (first visit - using room-placed instances)");
		global.loading_from_save = false;
		return;
	}

	// Destroy ALL room-placed instances (they'll be recreated from save data)
	// SKIP player and companions - they use GameMaker's persistent flag
	var _destroyed_count = 0;
	with (obj_persistent_parent) {
		// Destroy everything EXCEPT player and companions
		if (object_index != obj_player && !object_is_ancestor(object_index, obj_companion_parent)) {
			show_debug_message("  Destroying: " + object_get_name(object_index) + " at (" + string(x) + ", " + string(y) + ")");
			instance_destroy();
			_destroyed_count++;
		}
	}
	show_debug_message("Destroyed " + string(_destroyed_count) + " room-placed persistent objects");


	// Track items loaded
	var _items_loaded = 0;

	// Iterate over saved objects and recreate them
	if (variable_struct_exists(_room_struct, "objects") && is_array(_room_struct.objects)) {
		var _objects_array = _room_struct.objects;
		var _party_controllers_to_restore = []; // Track party controllers for second pass
		var _spawners_to_restore = []; // Track spawners for second pass

		show_debug_message("Loading " + string(array_length(_objects_array)) + " objects from save data...");

		// FIRST PASS: Create all objects and restore basic properties
		for (var i = 0; i < array_length(_objects_array); i++) {
			var _obj_data = _objects_array[i];

			// Validate object data
			if (!is_struct(_obj_data)) continue;
			if (!variable_struct_exists(_obj_data, "object_type")) continue;
			if (!variable_struct_exists(_obj_data, "x")) continue;
			if (!variable_struct_exists(_obj_data, "y")) continue;

			// Get object type from name string
			var _object_type_name = _obj_data.object_type;
			var _object_index = asset_get_index(_object_type_name);

			// Verify object exists
			if (_object_index == -1) {
				show_debug_message("WARNING: Object type not found: " + _object_type_name);
				continue;
			}

			// Create instance at saved position
			var _instance = instance_create_layer(_obj_data.x, _obj_data.y, "Instances", _object_index);

			// Restore saved properties
			if (instance_exists(_instance)) {
				show_debug_message(string(_obj_data));
				_instance.deserialize(_obj_data);

				show_debug_message("Loaded object: " + _object_type_name + " at (" + string(_obj_data.x) + ", " + string(_obj_data.y) + ")");
			}
		}
	}

	show_debug_message("Room loaded: " + _room_name);
	show_debug_message("  Items restored: " + string(_items_loaded));

	// Clear loading flag
	global.loading_from_save = false;
}
