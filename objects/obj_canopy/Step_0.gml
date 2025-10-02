// Canopy Step Event
// Handles VN interaction trigger

// Call parent step event first
event_inherited();

// Check for VN interaction (only when recruited and near player)
if (instance_exists(obj_player)) {
	if (global.game_paused) {
		return;
	}

	var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

	// Debug output
	if (keyboard_check_pressed(ord("0"))) {
		show_debug_message("=== CANOPY VN DEBUG ===");
		show_debug_message("is_recruited: " + string(is_recruited));
		show_debug_message("distance to player: " + string(_dist_to_player));
		show_debug_message("vn_active: " + string(global.vn_active));
	}

	// Debug - reload yarn file
	if (keyboard_check_pressed(ord("9"))) {
		show_debug_message("Reloading canopy.yarn");
		ChatterboxLoadFromFile("canopy.yarn");
	}

	// Player is close and presses space - open VN dialogue (works whether recruited or not)
	if (_dist_to_player < 48 && keyboard_check_pressed(vk_space)) {
		show_debug_message("Starting VN dialogue!");
		start_vn_dialogue(id, "canopy.yarn", "Start");
	}
}
