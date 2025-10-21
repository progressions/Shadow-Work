// Save System
// Minimal implementation with no-op functions during rebuild phase

/// @function save_game
/// @description Empty no-op save function (to be reimplemented)
/// @param {real} _slot_number The save slot number (1-5)
function save_game(_slot_number) {
    // Intentionally empty - to be reimplemented
}

/// @function load_game
/// @description Empty no-op load function (to be reimplemented)
/// @param {real} _slot_number The save slot number (1-5)
function load_game(_slot_number) {
    // Intentionally empty - to be reimplemented
}

function save_room() {
	// should we have separate arrays for each of these categories?
	// or just one collection for children of obj_persistent_parent?
	
	var _room_struct = {
		objects: []
	}
	
	// find all instances in this room of children of obj_persistent_parent and
	// iterate over all companions, enemies, items, openables, breakables
	// populate the arrays above with the JSON serialized data for each
	
	with (obj_persistent_parent) {
		array_push(_room_struct.objects, serialize());
	}
	
	show_debug_message("room_struct " + string(_room_struct));
	
	return _room_struct;
}

function load_room() {
	var _room_struct = 0;
	
	if (room == room_level_1) { _room_struct = global.save_data.room_level_1; }
	
	if (!is_struct(_room_struct)) exit;
	
	if (instance_exists(obj_persistent_parent)) { instance_destroy(obj_persistent_parent) }
	
	// iterate over the saved objects in _room_struct
	// create them with instance_create_layer at their x, y coordinates
}