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
    var torch_state = undefined;
    if (variable_struct_exists(spawn_data, "torch_state")) {
        torch_state = spawn_data.torch_state;
    }

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
            case "hola":
                companion_obj = obj_hola;
                break;
            case "yorna":
                companion_obj = obj_yorna;
                break;
            default:
                companion_obj = noone;
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
                    // Activate available auras
                    var _aura_names = variable_struct_get_names(auras);
                    for (var _ai = 0; _ai < array_length(_aura_names); _ai++) {
                        var _aura_key = _aura_names[_ai];
                        if (variable_struct_exists(auras[$ _aura_key], "active")) {
                            auras[$ _aura_key].active = true;
                        }
                    }
                    if (variable_struct_exists(comp_data, "carrying_torch") && comp_data.carrying_torch) {
                        carrying_torch = true;
                        var _torch_time = variable_struct_exists(comp_data, "torch_time_remaining") ? comp_data.torch_time_remaining : torch_duration;
                        torch_time_remaining = clamp(_torch_time, 0, torch_duration);
                        if (variable_struct_exists(comp_data, "torch_light_radius")) {
                            torch_light_radius = comp_data.torch_light_radius;
                        }
                        companion_stop_torch_loop();
                        companion_start_torch_loop();
                        if (audio_emitter_exists(torch_sound_emitter)) {
                            audio_emitter_position(torch_sound_emitter, x, y, 0);
                        }
                        set_torch_carrier(companion_id);
                    } else if (carrying_torch) {
                        companion_stop_torch_loop();
                        carrying_torch = false;
                        torch_time_remaining = 0;
                    }
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
                // Activate available auras
                var _new_aura_names = variable_struct_get_names(new_companion.auras);
                for (var _nai = 0; _nai < array_length(_new_aura_names); _nai++) {
                    var _aura_key = _new_aura_names[_nai];
                    if (variable_struct_exists(new_companion.auras[$ _aura_key], "active")) {
                        new_companion.auras[$ _aura_key].active = true;
                    }
                }
                show_debug_message("Companion spawned successfully: " + new_companion.companion_id);
                if (variable_struct_exists(comp_data, "carrying_torch") && comp_data.carrying_torch) {
                    with (new_companion) {
                        carrying_torch = true;
                        var _torch_time = variable_struct_exists(comp_data, "torch_time_remaining") ? comp_data.torch_time_remaining : torch_duration;
                        torch_time_remaining = clamp(_torch_time, 0, torch_duration);
                        if (variable_struct_exists(comp_data, "torch_light_radius")) {
                            torch_light_radius = comp_data.torch_light_radius;
                        }
                        companion_stop_torch_loop();
                        companion_start_torch_loop();
                        if (audio_emitter_exists(torch_sound_emitter)) {
                            audio_emitter_position(torch_sound_emitter, x, y, 0);
                        }
                        set_torch_carrier(companion_id);
                    }
                }
            } else {
                show_debug_message("Companion already exists in room: " + comp_data.companion_id);
            }
        }
    }

    if (torch_state != undefined) {
        var carrier_id = variable_struct_exists(torch_state, "carrier") ? torch_state.carrier : "none";
        var player_active = variable_struct_exists(torch_state, "player_active") ? torch_state.player_active : false;
        var player_time = variable_struct_exists(torch_state, "player_time_remaining") ? torch_state.player_time_remaining : 0;

        if (carrier_id == "player") {
            if (instance_exists(obj_player)) {
                with (obj_player) {
                    torch_active = player_active;
                    torch_time_remaining = clamp(player_time, 0, torch_duration);
                    if (torch_active) {
                        player_start_torch_loop();
                        if (audio_emitter_exists(torch_sound_emitter)) {
                            audio_emitter_position(torch_sound_emitter, x, y, 0);
                        }
                        set_torch_carrier("player");
                    } else {
                        player_stop_torch_loop();
                        set_torch_carrier("none");
                    }
                }
            } else {
                set_torch_carrier("player");
            }
        } else {
            if (instance_exists(obj_player)) {
                with (obj_player) {
                    torch_active = false;
                    torch_time_remaining = 0;
                    player_stop_torch_loop();
                }
            }

            if (carrier_id == "none" || carrier_id == undefined) {
                set_torch_carrier("none");
            } else {
                set_torch_carrier(carrier_id);
            }
        }
    }

    // Clear pending spawn data
    global.pending_player_spawn = undefined;
}

// Save system hooks removed during rebuild
// Previously called: check_for_pending_save_restore() and restore_room_state_if_visited()
