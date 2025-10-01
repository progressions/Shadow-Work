// Collision with obj_player - Trigger room transition

if (target_room != undefined) {
    show_debug_message("=== ROOM TRANSITION TRIGGERED ===");
    show_debug_message("Current room: " + room_get_name(room));
    show_debug_message("Target room: " + room_get_name(target_room));
    show_debug_message("Target position: (" + string(target_x) + ", " + string(target_y) + ")");
    var spawn_x = (target_x != -1) ? target_x : obj_player.x;
    var spawn_y = (target_y != -1) ? target_y : obj_player.y;

    // Store companion data with spacing (only companions following the player)
    var companion_data = [];
    var companion_index = 0;
    with (obj_companion_parent) {
        show_debug_message("Companion found: " + companion_id + ", recruited: " + string(is_recruited) + ", follow_target: " + string(follow_target));
        if (is_recruited && follow_target == obj_player) {
            // Space companions 32 pixels apart (2 tiles at 16px per tile)
            var offset_x = 32 * companion_index;
            var offset_y = 32;

            array_push(companion_data, {
                companion_id: companion_id,
                offset_x: offset_x,
                offset_y: offset_y
            });
            show_debug_message("Added companion to transition: " + companion_id);
            companion_index++;
        }
    }
    show_debug_message("Total companions to transfer: " + string(array_length(companion_data)));

    global.pending_player_spawn = {
        x: spawn_x,
        y: spawn_y,
        companions: companion_data
    };

    room_goto(target_room);
}
