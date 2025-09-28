function player_move_onto_pillar(){
#region Pillar collision checking - ONLY when NOT on grid
    // Use un-offset probe Y so entering from LEFT/RIGHT registers correctly.
	if (!obj_grid_controller.hop.active) {
	    var _instance = noone;
	    var pillar_list = ds_list_create();

	    // Find items in pillar radius — PROBE at (y - GRID_Y_OFFSET)
	    var probe_cx = x + interaction_offset_x;
	    var probe_cy = (y - GRID_Y_OFFSET) + interaction_offset_y;

	    var pillar_count = collision_circle_list(
	        probe_cx, probe_cy,
	        interaction_radius,
	        obj_rising_pillar,
	        false, true,
	        pillar_list, true
	    );

	    if (pillar_count > 0) {
	        _instance = pillar_list[| 0];

	        // Call move_onto to handle the transition
	        obj_grid_controller.move_onto(_instance);
	    }

	    ds_list_destroy(pillar_list);
	}
	#endregion
}