// Companion Parent Draw Event
// Handles sprite animation based on movement and direction

// Draw shadow
draw_sprite_ext(spr_shadow, 0, x, y + 2, 1, 0.5, 0, c_black, 0.3);

// Handle casting animation
if (state == CompanionState.casting) {
    // Get direction names for animation lookup
    var dir_names = ["down", "right", "left", "up"];
    var dir_name = dir_names[last_dir_index];

    // Select casting animation based on direction
    var anim_key = "casting_" + dir_name;

    // Only play if companion has casting animations
    if (variable_struct_exists(anim_data, anim_key)) {
        var anim = anim_data[$ anim_key];
        image_index = anim.start + casting_frame_index;
    }
}
else {
    // Normal idle/walk animation
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
}

// Draw companion sprite with glow effect during casting
if (state == CompanionState.casting) {
    // Draw glow layers - noticeable but not overwhelming
    var glow_alpha = 0.5 + (sin(current_time / 80) * 0.3); // Pulsing glow

    // Outer glow (white)
    draw_sprite_ext(sprite_index, image_index, x, y, 2.2, 2.2, 0, c_white, glow_alpha * 0.4);

    // Middle glow (aqua/cyan)
    draw_sprite_ext(sprite_index, image_index, x, y, 1.8, 1.8, 0, c_aqua, glow_alpha * 0.5);

    // Inner glow (yellow)
    draw_sprite_ext(sprite_index, image_index, x, y, 1.4, 1.4, 0, c_yellow, glow_alpha * 0.6);

    // Draw subtle circle around companion
    var circle_radius = 16 + (sin(current_time / 60) * 4);
    draw_set_alpha(glow_alpha * 0.5);
    draw_circle_color(x, y - 8, circle_radius, c_aqua, c_yellow, false);
    draw_set_alpha(1);
}

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
