global.mid_transition = -1;
global.room_target = -1;
global.is_loading = false;

function transition_place_sequence(_type) {
	if (layer_exists("transition")) layer_destroy("transition");
	var _lay = layer_create(-9999, "transition");
	layer_sequence_create(_lay, 0, 0, _type);
}

function transition_start(_room_target, _type_out, _type_in) {
	if (!global.mid_transition) {
		global.mid_transition = true;
		global.room_target = _room_target;
		transition_place_sequence(_type_out);
		layer_set_target_room(_room_target);
		transition_place_sequence(_type_in);
		layer_reset_target_room();
		return true;
	}
	else return false;
}

function transition_change_room() {
	// Check if we're loading a save in the same room
	if (variable_global_exists("pending_save_data") && global.pending_save_data != undefined && room == global.room_target) {
		// Same room restore - call restore directly
		restore_save_data(global.pending_save_data);
	} else {
		// Normal room transition
		room_goto(global.room_target);
	}
}

function transition_finished() {
	layer_sequence_destroy(self.elementID);
	global.mid_transition = false;
}