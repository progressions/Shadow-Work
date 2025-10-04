// Companion Parent Draw Event
// Handles sprite animation based on movement and direction

// Draw shadow
draw_sprite_ext(spr_shadow, 0, x, y + 2, 1, 0.5, 0, c_black, 0.3);

// Determine animation state
var _is_moving = (abs(move_dir_x) > 0.1) || (abs(move_dir_y) > 0.1);
var anim_block = _is_moving ? "walk" : "idle";

// Get direction names for animation lookup
var dir_names = ["down", "right", "left", "up"];
var dir_name = dir_names[last_dir_index];

// Look up animation data for this companion
var anim_key = anim_block + "_" + dir_name;

if (variable_struct_exists(anim_data, anim_key)) {
    var anim_info = anim_data[$ anim_key];
    var start_frame = anim_info.start;
    var frame_count = anim_info.length;

    // Use global bob timer for synchronized animation (like enemies and player)
    var frame_offset = floor(global.idle_bob_timer) mod frame_count;
    image_index = start_frame + frame_offset;
}

// Draw companion sprite
draw_self();

// Optional: Draw affinity indicator when recruited (heart icon)
if (is_recruited && affinity >= 5.0) {
    var heart_alpha = 0.6;
    var heart_y = bbox_top - 10;

    // Draw heart outline based on affinity level
    if (affinity >= 10.0) {
        draw_sprite_ext(spr_ui_heart, 0, x, heart_y, 0.5, 0.5, 0, c_red, heart_alpha);
    } else if (affinity >= 8.0) {
        draw_sprite_ext(spr_ui_heart, 0, x, heart_y, 0.5, 0.5, 0, c_orange, heart_alpha);
    } else if (affinity >= 5.0) {
        draw_sprite_ext(spr_ui_heart, 0, x, heart_y, 0.5, 0.5, 0, c_yellow, heart_alpha);
    }
}

// Reset draw settings
draw_set_alpha(1);
