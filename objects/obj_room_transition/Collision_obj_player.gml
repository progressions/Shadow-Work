// Collision with obj_player - Trigger room transition

show_debug_message("=== ROOM TRANSITION COLLISION ===");
show_debug_message("target_room: " + string(target_room));
show_debug_message("target_x: " + string(target_x));
show_debug_message("target_y: " + string(target_y));

// Prevent multiple triggers
if (variable_instance_exists(id, "triggered") && triggered) {
    show_debug_message("Already triggered, exiting");
    exit;
}
triggered = true;

if (target_room != undefined) {
    var spawn_x = (target_x != -1) ? target_x : obj_player.x;
    var spawn_y = (target_y != -1) ? target_y : obj_player.y;

    show_debug_message("Starting transition to room: " + room_get_name(target_room));
    show_debug_message("Spawn position: " + string(spawn_x) + ", " + string(spawn_y));

    // Store pending player spawn position (companions will be added in Room End event)
    global.pending_player_spawn = {
        x: spawn_x,
        y: spawn_y,
        companions: [] // Will be populated in Room End event
    };

    transition_start(target_room, seq_fade_out, seq_fade_in);
} else {
    show_debug_message("ERROR: target_room is undefined! Set it in Creation Code");
}
