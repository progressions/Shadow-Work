// Lighting controller setup

visible = true;

grid_cell_size = 16;
cached_room_width = room_width;
cached_room_height = room_height;

grid_width = max(1, ceil(cached_room_width / grid_cell_size));
grid_height = max(1, ceil(cached_room_height / grid_cell_size));

depth = -1000000; // Very low depth so overlay draws last (in front of the scene)

light_grid = ds_grid_create(grid_width, grid_height);
room_darkness_level = 0;
darkness_surface = -1;
surface_dirty = true;

function clear_light_grid() {
    if (light_grid == undefined) return;
    ds_grid_clear(light_grid, 0);
}

function init_light_grid() {
    if (light_grid != undefined) {
        ds_grid_destroy(light_grid);
    }

    cached_room_width = room_width;
    cached_room_height = room_height;
    grid_width = max(1, ceil(cached_room_width / grid_cell_size));
    grid_height = max(1, ceil(cached_room_height / grid_cell_size));

    light_grid = ds_grid_create(grid_width, grid_height);
    clear_light_grid();
}

function add_light_source(_x, _y, _radius) {
    if (light_grid == undefined) return;
    if (_radius <= 0) return;

    var _cell_radius = _radius / grid_cell_size;
    var _min_x = max(0, floor((_x - _radius) / grid_cell_size));
    var _max_x = min(grid_width - 1, floor((_x + _radius) / grid_cell_size));
    var _min_y = max(0, floor((_y - _radius) / grid_cell_size));
    var _max_y = min(grid_height - 1, floor((_y + _radius) / grid_cell_size));

    for (var _cx = _min_x; _cx <= _max_x; _cx++) {
        var _cell_center_x = (_cx + 0.5) * grid_cell_size;
        for (var _cy = _min_y; _cy <= _max_y; _cy++) {
            var _cell_center_y = (_cy + 0.5) * grid_cell_size;
            var _distance_cells = point_distance(_x, _y, _cell_center_x, _cell_center_y) / grid_cell_size;
            if (_distance_cells > _cell_radius + 1) continue;

            // Calculate intensity based on distance from center as fraction of radius
            var _intensity = 0;
            var _normalized_distance = _distance_cells / _cell_radius;

            if (_normalized_distance <= 0.25) {
                _intensity = 1;
            } else if (_normalized_distance <= 0.5) {
                _intensity = 0.75;
            } else if (_normalized_distance <= 0.75) {
                _intensity = 0.5;
            } else if (_normalized_distance <= 1.0) {
                _intensity = 0.25;
            }

            if (_intensity <= 0) continue;

            var _current = light_grid[# _cx, _cy];
            if (_intensity > _current) {
                light_grid[# _cx, _cy] = _intensity;
            }
        }
    }
}

function ensure_surface() {
    if (surface_dirty) {
        if (surface_exists(darkness_surface)) {
            surface_free(darkness_surface);
        }
        darkness_surface = -1;
    }

    if (!surface_exists(darkness_surface)) {
        darkness_surface = surface_create(room_width, room_height);
        if (!surface_exists(darkness_surface)) {
            darkness_surface = -1;
            surface_dirty = true;
            return false;
        }
    }

    if (surface_get_width(darkness_surface) != room_width || surface_get_height(darkness_surface) != room_height) {
        surface_free(darkness_surface);
        darkness_surface = surface_create(room_width, room_height);
        if (!surface_exists(darkness_surface)) {
            darkness_surface = -1;
            surface_dirty = true;
            return false;
        }
    }

    surface_dirty = false;
    return true;
}

function render_lighting() {
    if (room_darkness_level <= 0) return;
    if (!ensure_surface()) return;

    surface_set_target(darkness_surface);
    draw_clear_alpha(c_black, room_darkness_level);

    gpu_set_blendmode(bm_subtract);
    draw_set_color(c_white);

    for (var _cx = 0; _cx < grid_width; _cx++) {
        for (var _cy = 0; _cy < grid_height; _cy++) {
            var _intensity = light_grid[# _cx, _cy];
            if (_intensity <= 0) continue;

            draw_set_alpha(_intensity);
            var _left = _cx * grid_cell_size;
            var _top = _cy * grid_cell_size;
            var _right = _left + grid_cell_size - 1;
            var _bottom = _top + grid_cell_size - 1;
            draw_rectangle(_left, _top, _right, _bottom, false);
        }
    }

    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    surface_reset_target();

    draw_surface(darkness_surface, 0, 0);
    draw_set_color(c_white);
}

function cleanup_surface() {
    if (surface_exists(darkness_surface)) {
        surface_free(darkness_surface);
    }
    darkness_surface = -1;

    if (light_grid != undefined) {
        ds_grid_destroy(light_grid);
        light_grid = undefined;
    }

    surface_dirty = true;
}

clear_light_grid();
