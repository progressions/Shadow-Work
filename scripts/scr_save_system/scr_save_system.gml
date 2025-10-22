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
	// Initialize global.save_data if it doesn't exist
	if (!variable_global_exists("save_data") || !is_struct(global.save_data)) {
		global.save_data = {};
	}

	var _room_struct = {
		objects: []
	}

	// Iterate over all persistent objects and serialize them
	// SKIP objects with GameMaker's persistent flag (player, companions)
	with (obj_persistent_parent) {
		// Only save non-persistent objects (enemies, chests, etc.)
		if (!persistent) {
			show_debug_message("  Saving: " + object_get_name(object_index) + " at (" + string(x) + ", " + string(y) + ")");
			array_push(_room_struct.objects, serialize());
		}
	}

	// Store room data in global.save_data using room name as key
	var _room_name = room_get_name(room);
	global.save_data[$ _room_name] = _room_struct;

	show_debug_message("Saved room: " + _room_name + " with " + string(array_length(_room_struct.objects)) + " objects");

	return _room_struct;
}

function load_room() {
	// Set global flag to prevent party controllers from spawning enemies during load
	global.loading_from_save = true;

	// Get the saved room data for the current room
	var _room_name = room_get_name(room);
	var _room_struct = undefined;

	// Check if save data exists and has this room
	if (variable_global_exists("save_data") && is_struct(global.save_data)) {
		if (variable_struct_exists(global.save_data, _room_name)) {
			_room_struct = global.save_data[$ _room_name];
		}
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

	// Iterate over saved objects and recreate them
	if (variable_struct_exists(_room_struct, "objects") && is_array(_room_struct.objects)) {
		var _objects_array = _room_struct.objects;
		var _party_controllers_to_restore = []; // Track party controllers for second pass

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
				// Restore sprite if it was changed
				if (variable_struct_exists(_obj_data, "sprite_index")) {
					var _sprite_name = _obj_data.sprite_index;
					var _sprite_index = asset_get_index(_sprite_name);
					if (_sprite_index != -1) {
						_instance.sprite_index = _sprite_index;
					}
				}

				// Restore visual properties
				if (variable_struct_exists(_obj_data, "image_index")) {
					_instance.image_index = _obj_data.image_index;
				}
				if (variable_struct_exists(_obj_data, "image_xscale")) {
					_instance.image_xscale = _obj_data.image_xscale;
				}
				if (variable_struct_exists(_obj_data, "image_yscale")) {
					_instance.image_yscale = _obj_data.image_yscale;
				}

				// Restore object-specific properties based on type
				// Enemy properties
				if (object_is_ancestor(_instance.object_index, obj_enemy_parent)) {
					if (variable_struct_exists(_obj_data, "hp")) {
						_instance.hp = _obj_data.hp;
					}
					if (variable_struct_exists(_obj_data, "hp_total")) {
						_instance.hp_total = _obj_data.hp_total;
					}
					if (variable_struct_exists(_obj_data, "state")) {
						_instance.state = _obj_data.state;
					}
				}

				// Companion properties
				if (object_is_ancestor(_instance.object_index, obj_companion_parent)) {
					if (variable_struct_exists(_obj_data, "is_recruited")) {
						_instance.is_recruited = _obj_data.is_recruited;
					}
					if (variable_struct_exists(_obj_data, "affinity")) {
						_instance.affinity = _obj_data.affinity;
					}
					if (variable_struct_exists(_obj_data, "quest_flags")) {
						_instance.quest_flags = _obj_data.quest_flags;
					}
				}

				// Openable properties (chests, etc.)
				if (object_is_ancestor(_instance.object_index, obj_openable)) {
					if (variable_struct_exists(_obj_data, "is_opened")) {
						_instance.is_opened = _obj_data.is_opened;
					}
					if (variable_struct_exists(_obj_data, "loot_spawned")) {
						_instance.loot_spawned = _obj_data.loot_spawned;
					}
				}

				// Breakable properties (vases, boxes, grass, etc.)
				if (object_is_ancestor(_instance.object_index, obj_breakable)) {
					if (variable_struct_exists(_obj_data, "hp")) {
						_instance.hp = _obj_data.hp;
					}
					if (variable_struct_exists(_obj_data, "hp_total")) {
						_instance.hp_total = _obj_data.hp_total;
					}
					if (variable_struct_exists(_obj_data, "state")) {
						_instance.state = _obj_data.state;
					}
					if (variable_struct_exists(_obj_data, "is_destroyed")) {
						_instance.is_destroyed = _obj_data.is_destroyed;
						// If breakable was destroyed, destroy it immediately
						if (_instance.is_destroyed) {
							instance_destroy(_instance);
						}
					}
				}

				// Party controller properties (excluding party_members - restored in second pass)
				if (object_is_ancestor(_instance.object_index, obj_enemy_party_controller)) {
					if (variable_struct_exists(_obj_data, "party_state")) {
						_instance.party_state = _obj_data.party_state;
					}
					if (variable_struct_exists(_obj_data, "formation_template")) {
						_instance.formation_template = _obj_data.formation_template;
					}
					if (variable_struct_exists(_obj_data, "initial_party_size")) {
						_instance.initial_party_size = _obj_data.initial_party_size;
					}
					if (variable_struct_exists(_obj_data, "party_initialized")) {
						_instance.party_initialized = _obj_data.party_initialized;
					}
					if (variable_struct_exists(_obj_data, "can_spawn_enemies")) {
						_instance.can_spawn_enemies = _obj_data.can_spawn_enemies;
					}
					if (variable_struct_exists(_obj_data, "protect_x")) {
						_instance.protect_x = _obj_data.protect_x;
					}
					if (variable_struct_exists(_obj_data, "protect_y")) {
						_instance.protect_y = _obj_data.protect_y;
					}
					if (variable_struct_exists(_obj_data, "protect_radius")) {
						_instance.protect_radius = _obj_data.protect_radius;
					}
					if (variable_struct_exists(_obj_data, "patrol_path_name") && _obj_data.patrol_path_name != "") {
						_instance.patrol_path = asset_get_index(_obj_data.patrol_path_name);
					}
					if (variable_struct_exists(_obj_data, "patrol_speed")) {
						_instance.patrol_speed = _obj_data.patrol_speed;
					}
					if (variable_struct_exists(_obj_data, "patrol_loop")) {
						_instance.patrol_loop = _obj_data.patrol_loop;
					}
					if (variable_struct_exists(_obj_data, "patrol_position")) {
						_instance.patrol_position = _obj_data.patrol_position;
					}
					if (variable_struct_exists(_obj_data, "patrol_aggro_radius")) {
						_instance.patrol_aggro_radius = _obj_data.patrol_aggro_radius;
					}
					if (variable_struct_exists(_obj_data, "patrol_return_radius")) {
						_instance.patrol_return_radius = _obj_data.patrol_return_radius;
					}
					if (variable_struct_exists(_obj_data, "patrol_home_x")) {
						_instance.patrol_home_x = _obj_data.patrol_home_x;
					}
					if (variable_struct_exists(_obj_data, "patrol_home_y")) {
						_instance.patrol_home_y = _obj_data.patrol_home_y;
					}
					if (variable_struct_exists(_obj_data, "patrol_original_state")) {
						_instance.patrol_original_state = _obj_data.patrol_original_state;
					}
					if (variable_struct_exists(_obj_data, "weight_attack")) {
						_instance.weight_attack = _obj_data.weight_attack;
					}
					if (variable_struct_exists(_obj_data, "weight_formation")) {
						_instance.weight_formation = _obj_data.weight_formation;
					}
					if (variable_struct_exists(_obj_data, "weight_flee")) {
						_instance.weight_flee = _obj_data.weight_flee;
					}
					if (variable_struct_exists(_obj_data, "weight_patrol")) {
						_instance.weight_patrol = _obj_data.weight_patrol;
					}

					// Store for second pass (to restore party_members references)
					array_push(_party_controllers_to_restore, {
						instance: _instance,
						data: _obj_data
					});
				}

				show_debug_message("Loaded object: " + _object_type_name + " at (" + string(_obj_data.x) + ", " + string(_obj_data.y) + ")");
			}
		}

		// SECOND PASS: Restore party controller -> enemy references
		for (var i = 0; i < array_length(_party_controllers_to_restore); i++) {
			var _restore_data = _party_controllers_to_restore[i];
			var _controller = _restore_data.instance;
			var _data = _restore_data.data;

			if (!instance_exists(_controller)) continue;
			if (!variable_struct_exists(_data, "party_member_ids")) continue;

			var _member_ids = _data.party_member_ids;
			_controller.party_members = [];

			// Find each party member by persistent_id and restore references
			for (var j = 0; j < array_length(_member_ids); j++) {
				var _persistent_id = _member_ids[j];

				// Search for enemy with matching persistent_id
				with (obj_enemy_parent) {
					if (persistent_id == _persistent_id) {
						array_push(_controller.party_members, id);
						party_controller = _controller; // Set enemy's reference to controller
					}
				}
			}

			show_debug_message("Restored party controller with " + string(array_length(_controller.party_members)) + " members");
		}
	}

	show_debug_message("Room loaded: " + _room_name);

	// Clear loading flag
	global.loading_from_save = false;
}