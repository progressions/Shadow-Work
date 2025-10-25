// Yorna Step Event
// Handles VN interaction trigger

// Call parent step event first
event_inherited();

// Check for VN interaction (only when near player)
if (instance_exists(obj_player)) {
	if (global.game_paused) {
		return;
	}

	var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

	// Player is close and presses interact - open VN dialogue (only if not recruited)
	if (_dist_to_player < 48 && InputPressed(INPUT_VERB.INTERACT) && !is_recruited) {
		show_debug_message("Starting Yorna VN dialogue!");
		start_vn_dialogue(id, "yorna.yarn", "Start");
	}
}
