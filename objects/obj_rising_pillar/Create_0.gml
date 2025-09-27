
y_offset = -(4 + (height * 2));
is_toggled = false;

// Set sprite based on height
switch(height) {
    case 0: 
        // sprite_index = spr_simple_pillar_low;
		image_index = 0;
        break;
    case 1: 
        // sprite_index = spr_simple_pillar_med;
		image_index = 1;
        break;
    case 2: 
        // sprite_index = spr_simple_pillar_high;
		image_index = 2;
        break;
}

original_height = height;
image_speed = 0 ;
depth = -bbox_bottom;

// Highlight feedback
highlight_timer   = 0;     // frames remaining
highlight_length  = 24;    // how long the highlight lasts
highlight_color   = c_yellow; // tint when triggered



/// ---- Height helpers
function pillar_height_step_down(height_value) {
    switch (height_value) {
        case 2: return 1; // High -> Med
        case 1: return 0; // Med  -> Low
        default: return 2; // Low  -> High (wrap)
    }
}
function pillar_height_step_up(height_value) {
    switch (height_value) {
        case 1: return 2; // Med  -> High
        case 0: return 1; // Low  -> Med
        default: return 0; // High -> Low (wrap)
    }
}

/// obj_rising_pillar: toggle the pillar whose pillar_id == this.target_pillar_id
function toggle_target() {
    // --- Validate that this source pillar has a target set ---
    if (!variable_instance_exists(id, "target_pillar_id")) {
        show_debug_message("toggle_target: source pillar " 
            + (variable_instance_exists(id,"pillar_id") ? string(pillar_id) : "<?>") 
            + " has no target_pillar_id defined.");
        return;
    }
    var desired_target_pillar_id = real(target_pillar_id);

    // --- Find the unique pillar instance whose pillar_id matches ---
    var found_target_pillar_instance = noone;
    var pillar_count = instance_number(obj_rising_pillar);

    for (var i = 0; i < pillar_count; i++) {
        var candidate_pillar = instance_find(obj_rising_pillar, i);
        if (variable_instance_exists(candidate_pillar, "pillar_id")) {
            if (real(candidate_pillar.pillar_id) == desired_target_pillar_id) {
                found_target_pillar_instance = candidate_pillar;
                break;
            }
        }
    }

    if (found_target_pillar_instance == noone) {
        show_debug_message("toggle_target: no obj_rising_pillar with pillar_id == "
            + string(desired_target_pillar_id));
        return;
    }

    // --- Apply toggle logic on the target pillar ---
    with (found_target_pillar_instance) {
		emphasize_pillar_feedback();

        if (!variable_instance_exists(id, "height")) height = 0; // safety default
        if (!variable_instance_exists(id, "is_toggled")) is_toggled = false;

        if (!is_toggled) {
            height     = pillar_height_step_down(height);  // First toggle: move down
            is_toggled = true;
        } else {
            height     = pillar_height_step_up(height);    // Second toggle: move up
            is_toggled = false;
        }

        show_debug_message("toggle_target: pillar_id " + string(pillar_id)
            + " new height=" + string(height) 
            + " (is_toggled=" + string(is_toggled) + ")");
    }
}
function emphasize_pillar_feedback() {
    // Start the highlight
    highlight_timer = highlight_length;

    // Play a sound if you want feedback
    audio_play_sound(snd_chest_open, 1, false);
}
