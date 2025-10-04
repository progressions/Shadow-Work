if (global.game_paused) exit;

var _expected_width = max(1, ceil(room_width / grid_cell_size));
var _expected_height = max(1, ceil(room_height / grid_cell_size));

if (_expected_width != grid_width || _expected_height != grid_height) {
    init_light_grid();
    surface_dirty = true;
}

clear_light_grid();

if (room_darkness_level <= 0 && !surface_dirty) {
    // When room fully lit, keep surface but no need to gather lights
    exit;
}

var _player = obj_player;
if (_player != noone) {
    if (_player.torch_active) {
        var _get_radius = method(_player, player_get_torch_light_radius);
        var _radius = _get_radius();
        add_light_source(_player.x, _player.y, _radius);
    }
}

with (obj_companion_parent) {
    if (carrying_torch) {
        other.add_light_source(x, y, torch_light_radius);
    }
}

with (obj_light_source) {
    if (light_active) {
        other.add_light_source(x, y, light_radius);
    }
}
