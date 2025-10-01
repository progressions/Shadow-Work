// Room Start Event
show_debug_message("=== ROOM START EVENT FIRED ===");
show_debug_message("Room: " + room_get_name(room));
show_debug_message("pending_player_spawn exists: " + string(variable_global_exists("pending_player_spawn")));
if (variable_global_exists("pending_player_spawn")) {
    show_debug_message("pending_player_spawn value: " + string(global.pending_player_spawn));
}

// Check for pending player spawn from room transition
if (variable_global_exists("pending_player_spawn") && global.pending_player_spawn != undefined) {
    show_debug_message("Room Start: Found pending player spawn data");
    var spawn_data = global.pending_player_spawn;

    // Move player to spawn position
    if (instance_exists(obj_player)) {
        obj_player.x = spawn_data.x;
        obj_player.y = spawn_data.y;
    }

    // Respawn recruited companions near player
    show_debug_message("Spawning " + string(array_length(spawn_data.companions)) + " companions in new room");
    for (var i = 0; i < array_length(spawn_data.companions); i++) {
        var comp_data = spawn_data.companions[i];

        // Determine companion object type
        var companion_obj = noone;
        switch (comp_data.companion_id) {
            case "canopy":
                companion_obj = obj_canopy;
                break;
            // Add other companions as implemented
        }

        if (companion_obj != noone) {
            // Check if companion already exists in this room
            var companion_exists = false;
            with (obj_companion_parent) {
                if (companion_id == comp_data.companion_id) {
                    companion_exists = true;
                    // Update position and ensure they follow player
                    x = obj_player.x + comp_data.offset_x;
                    y = obj_player.y + comp_data.offset_y;
                    follow_target = obj_player;
                    is_recruited = true;
                    state = CompanionState.following;
                    break;
                }
            }

            // If companion doesn't exist in this room, spawn them
            if (!companion_exists) {
                show_debug_message("Spawning new companion: " + comp_data.companion_id + " at offset (" + string(comp_data.offset_x) + ", " + string(comp_data.offset_y) + ")");
                var new_companion = instance_create_depth(
                    obj_player.x + comp_data.offset_x,
                    obj_player.y + comp_data.offset_y,
                    -1000,
                    companion_obj
                );
                new_companion.is_recruited = true;
                new_companion.state = CompanionState.following;
                new_companion.follow_target = obj_player;
                show_debug_message("Companion spawned successfully: " + new_companion.companion_id);
            } else {
                show_debug_message("Companion already exists in room: " + comp_data.companion_id);
            }
        }
    }

    // Clear pending spawn data
    global.pending_player_spawn = undefined;
}

// Check for pending save data (from load_game room transition)
check_for_pending_save_restore();

// If no pending save, restore room state if this room has been visited before
if (!variable_global_exists("pending_save_data") || global.pending_save_data == undefined) {
    restore_room_state_if_visited();
}
