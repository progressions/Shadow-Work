// Room End Event
// Save current room state and auto-save when leaving room
if (instance_exists(obj_player)) {
    // Store companion data with relative offsets (only if a room transition is pending)
    if (variable_global_exists("pending_player_spawn") && global.pending_player_spawn != undefined) {
        var companion_data = [];
        with (obj_companion_parent) {
            if (is_recruited) {
                var _torch_remaining = carrying_torch ? torch_time_remaining : 0;
                array_push(companion_data, {
                    companion_id: companion_id,
                    offset_x: x - obj_player.x,
                    offset_y: y - obj_player.y,
                    carrying_torch: carrying_torch,
                    torch_time_remaining: _torch_remaining,
                    torch_light_radius: torch_light_radius
                });
            }
        }
        global.pending_player_spawn.companions = companion_data;

        var torch_state = {
            carrier: global.torch_carrier_id,
            player_active: false,
            player_time_remaining: 0,
            player_light_radius: 0
        };

        var _player_active = false;
        var _player_time_remaining = 0;
        var _player_light_radius = 0;

        if (instance_exists(obj_player)) {
            with (obj_player) {
                other._player_active = torch_active;
                other._player_time_remaining = torch_time_remaining;
                other._player_light_radius = player_get_torch_light_radius();
            }
        }

        torch_state.player_active = _player_active;
        torch_state.player_time_remaining = _player_time_remaining;
        torch_state.player_light_radius = _player_light_radius;

        global.pending_player_spawn.torch_state = torch_state;
    }

    // Save system hooks removed during rebuild
    // Previously saved room state, marked room as visited, and performed auto-save
	
	save_room();
}
