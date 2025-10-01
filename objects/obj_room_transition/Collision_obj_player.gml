// Collision with obj_player - Trigger room transition

// Prevent multiple triggers
if (variable_instance_exists(id, "triggered") && triggered) {
    exit;
}
triggered = true;

if (target_room != undefined) {
    var spawn_x = (target_x != -1) ? target_x : obj_player.x;
    var spawn_y = (target_y != -1) ? target_y : obj_player.y;

    // Store pending player spawn position (companions will be added in Room End event)
    global.pending_player_spawn = {
        x: spawn_x,
        y: spawn_y,
        companions: [] // Will be populated in Room End event
    };

    transition_start(target_room, seq_fade_out, seq_fade_in);
}
