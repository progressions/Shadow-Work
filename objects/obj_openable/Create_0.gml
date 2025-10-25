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
/// Supports both string format ("item_key") and struct format ({item_key: "arrows", count: 10})
function spawn_specific_loot() {
    if (!is_array(loot_items) || array_length(loot_items) == 0) {
        show_debug_message("No specific items configured for container");
        return;
    }

    // Spawn each item from the loot_items array
    for (var i = 0; i < array_length(loot_items); i++) {
        var loot_entry = loot_items[i];
        var item_key = undefined;
        var item_count = 1;

        // Support both string and struct formats
        if (is_string(loot_entry)) {
            // Legacy format: just the item key
            item_key = loot_entry;
        } else if (is_struct(loot_entry)) {
            // New format: {item_key: "arrows", count: 10}
            item_key = loot_entry[$ "item_key"];
            item_count = loot_entry[$ "count"] ?? 1;
        } else {
            show_debug_message("Invalid loot entry format at index " + string(i));
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
            spawn_item(spawn_pos.x, spawn_pos.y, item_key, item_count);
            show_debug_message("Container dropped: " + string(item_count) + "x " + item_key + " at (" + string(spawn_pos.x) + ", " + string(spawn_pos.y) + ")");
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
function serialize() {
    var _struct = {
        // Base persistent_parent fields
        object_type: object_get_name(object_index),
        persistent_id: persistent_id,
		openable_id: openable_id,
        x: x,
        y: y,
        room_name: room_get_name(room),
        sprite_index: sprite_get_name(sprite_index),
        image_index: image_index,
        image_xscale: image_xscale,
        image_yscale: image_yscale,

        // Openable-specific fields
        is_opened: is_opened,
        loot_spawned: loot_spawned,

        // Loot configuration (must be preserved when recreating from save)
        loot_mode: loot_mode,
        loot_items: loot_items,
        loot_table: loot_table,
        loot_count: loot_count,
        loot_count_min: loot_count_min,
        loot_count_max: loot_count_max,
        use_variable_quantity: use_variable_quantity
    };

    return _struct;
}

// { loot_mode : "specific", object_type : "obj_chest", x : 347, loot_items : [ "wooden_bow","torch","torch" ], y : 253, image_xscale : 1, room_name : "room_level_1", image_yscale : 1, persistent_id : "obj_chest_347_253", loot_table : [  ], is_opened : 0, loot_spawned : 0, loot_count : 1, loot_count_min : 1, loot_count_max : 1, sprite_index : "spr_item_chest", use_variable_quantity : 0, image_index : 0 }

function deserialize(_obj_data) {
	// Position
	x = _obj_data[$ "x"] ?? x;
	y = _obj_data[$ "y"] ?? y;

	// Sprite and animation
	sprite_index = asset_get_index(_obj_data[$ "sprite_index"] ?? sprite_get_name(sprite_index));
	image_index = _obj_data[$ "image_index"] ?? 0;
	image_xscale = _obj_data[$ "image_xscale"] ?? 1;
	image_yscale = _obj_data[$ "image_yscale"] ?? 1;

	// Persistent ID
	persistent_id = _obj_data[$ "persistent_id"] ?? persistent_id;
	openable_id = _obj_data[$ "openable_id"] ?? openable_id;

	// State
	is_opened = _obj_data[$ "is_opened"] ?? false;
	loot_spawned = _obj_data[$ "loot_spawned"] ?? false;

	// Loot configuration
	loot_mode = _obj_data[$ "loot_mode"] ?? "specific";
	loot_items = _obj_data[$ "loot_items"] ?? [];
	loot_table = _obj_data[$ "loot_table"] ?? [];
	loot_count = _obj_data[$ "loot_count"] ?? 1;
	loot_count_min = _obj_data[$ "loot_count_min"] ?? 1;
	loot_count_max = _obj_data[$ "loot_count_max"] ?? 1;
	use_variable_quantity = _obj_data[$ "use_variable_quantity"] ?? false;
}

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
