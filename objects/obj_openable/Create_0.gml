/// @description Initialize openable container variables

// Inherit from parent (obj_interactable_parent)
event_inherited();

// Override interaction properties
interaction_priority = 50;
interaction_action = "Open";

// State tracking
is_opened = false;
loot_spawned = false;

// Animation control
image_speed = 0;  // Manual animation control
image_index = 0;  // Start on closed frame

// Loot configuration
loot_mode = "specific";  // "specific" or "random_weighted"
loot_items = [];  // Array of item_key strings for specific mode
loot_table = [];  // Array of {item_key, weight} structs for random mode
loot_count = 1;  // Number of items to spawn (random_weighted mode)
loot_count_min = 1;  // Minimum items for variable quantity
loot_count_max = 1;  // Maximum items for variable quantity
use_variable_quantity = false;  // Whether to use min/max range

// Persistent ID for save system
openable_id = object_get_name(object_index) + "_" + string(x) + "_" + string(y);

// Interaction prompt tracking
interaction_prompt = noone;

// Debug validation - check all items exist in database
if (loot_mode == "specific" && is_array(loot_items)) {
    for (var i = 0; i < array_length(loot_items); i++) {
        var item_key = loot_items[i];
        if (!variable_struct_exists(global.item_database, item_key)) {
            show_debug_message("WARNING: Container " + openable_id + " references invalid item_key: " + item_key);
        }
    }
}

if (loot_mode == "random_weighted" && is_array(loot_table)) {
    for (var i = 0; i < array_length(loot_table); i++) {
        var entry = loot_table[i];
        if (variable_struct_exists(entry, "item_key")) {
            var item_key = entry.item_key;
            if (!variable_struct_exists(global.item_database, item_key)) {
                show_debug_message("WARNING: Container " + openable_id + " loot_table references invalid item_key: " + item_key);
            }
        }
    }
}

/// @function open_container()
/// @description Trigger the opening animation and sound
function open_container() {
    if (is_opened) return;

    is_opened = true;
    play_sfx(snd_chest_open);
    // Animation will be handled in Step event
}

/// @function spawn_specific_loot()
/// @description Spawn specific items from loot_items array
function spawn_specific_loot() {
    if (!is_array(loot_items) || array_length(loot_items) == 0) {
        show_debug_message("No specific items configured for container");
        return;
    }

    // Spawn each item from the loot_items array
    for (var i = 0; i < array_length(loot_items); i++) {
        var item_key = loot_items[i];

        // Verify item exists in database
        if (!variable_struct_exists(global.item_database, item_key)) {
            show_debug_message("Item key '" + item_key + "' not found in global.item_database");
            continue;
        }

        // Find valid spawn position
        var spawn_pos = find_loot_spawn_position(x, y);

        if (spawn_pos != noone) {
            spawn_item(spawn_pos.x, spawn_pos.y, item_key, 1);
            show_debug_message("Container dropped: " + item_key + " at (" + string(spawn_pos.x) + ", " + string(spawn_pos.y) + ")");
        }
    }

    // Play loot drop sound
    if (audio_exists(snd_loot_drop)) {
        play_sfx(snd_loot_drop, 0.5, false);
    }
}

/// @function spawn_random_loot()
/// @description Spawn random items from weighted loot table
function spawn_random_loot() {
    if (!is_array(loot_table) || array_length(loot_table) == 0) {
        show_debug_message("No loot table configured for container");
        return;
    }

    // Determine how many items to spawn
    var spawn_count = loot_count;
    if (use_variable_quantity) {
        spawn_count = irandom_range(loot_count_min, loot_count_max);
    }

    // Spawn the items
    for (var i = 0; i < spawn_count; i++) {
        var item_key = select_weighted_loot_item(loot_table);

        if (item_key == undefined) {
            show_debug_message("Failed to select item from loot table");
            continue;
        }

        // Verify item exists in database
        if (!variable_struct_exists(global.item_database, item_key)) {
            show_debug_message("Item key '" + item_key + "' not found in global.item_database");
            continue;
        }

        // Find valid spawn position
        var spawn_pos = find_loot_spawn_position(x, y);

        if (spawn_pos != noone) {
            spawn_item(spawn_pos.x, spawn_pos.y, item_key, 1);
            show_debug_message("Container dropped: " + item_key + " at (" + string(spawn_pos.x) + ", " + string(spawn_pos.y) + ")");
        }
    }

    // Play loot drop sound
    if (audio_exists(snd_loot_drop)) {
        play_sfx(snd_loot_drop, 0.5, false);
    }
}

/// @function spawn_loot()
/// @description Spawn loot items based on loot_mode configuration
function spawn_loot() {
    // Prevent duplicate spawning
    if (loot_spawned) return;
    loot_spawned = true;

    // Check loot mode and call appropriate spawn function
    switch (loot_mode) {
        case "specific":
            spawn_specific_loot();
            break;
        case "random_weighted":
            spawn_random_loot();
            break;
        default:
            show_debug_message("Unknown loot_mode: " + string(loot_mode));
            break;
    }
}

// Serialize/deserialize methods removed during save system rebuild

/// @function can_interact()
/// @description Override - container can be interacted with if not opened
function can_interact() {
    return !is_opened;
}

/// @function on_interact()
/// @description Override - trigger container opening when interacted
function on_interact() {
    // Action tracker: chest opened
    action_tracker_log("chest_opened");
    open_container();
    // Destroy prompt when opened
    if (instance_exists(interaction_prompt)) {
        instance_destroy(interaction_prompt);
        interaction_prompt = noone;
    }
}
