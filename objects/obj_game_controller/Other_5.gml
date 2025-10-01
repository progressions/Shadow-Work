// Room End Event
// Save current room state and auto-save when leaving room
if (instance_exists(obj_player)) {
    // Store companion data with relative offsets (only if a room transition is pending)
    if (variable_global_exists("pending_player_spawn") && global.pending_player_spawn != undefined) {
        var companion_data = [];
        with (obj_companion_parent) {
            if (is_recruited) {
                array_push(companion_data, {
                    companion_id: companion_id,
                    offset_x: x - obj_player.x,
                    offset_y: y - obj_player.y
                });
            }
        }
        global.pending_player_spawn.companions = companion_data;
    }

    // Save current room state before leaving
    var room_key = string(room);
    show_debug_message("Room End: Saving room state for " + room_get_name(room));
    global.room_states[$ room_key] = serialize_room_state(room);

    // Mark this room as visited
    if (array_get_index(global.visited_rooms, room) == -1) {
        array_push(global.visited_rooms, room);
    }

    // Auto-save
    auto_save();
}
