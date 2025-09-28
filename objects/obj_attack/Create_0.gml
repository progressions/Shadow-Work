damage = 1;
creator = obj_player;

// Set sword sprite
if (creator.equipped.right_hand != undefined) {
    show_debug_message(creator.equipped.right_hand.definition.equipped_sprite_key);
    spr_name = creator.equipped.right_hand.definition.equipped_sprite_key;
    if (spr_name != -1) {
        sprite_index = asset_get_index("spr_wielded_" + spr_name);
    } else {
        sprite_index = spr_slash;
    }
} else {
    sprite_index = spr_slash;
}

// Animation settings
swing_speed = 10; // How fast to swing
swing_range = 90; // Total degrees to swing
swing_progress = 0;

// Set starting angle and base angle based on player's facing direction
switch (creator.facing_dir) {
    case "right":
        start_angle = -45;
        base_angle = 0;    // For slash effect
        break;
    case "left":
        start_angle = 135;
        base_angle = 180;  // For slash effect
        break;
    case "up":
        start_angle = 45;
        base_angle = 90;   // For slash effect
        break;
    case "down":
        start_angle = 225;
        base_angle = 270;  // For slash effect
        break;
}

image_angle = start_angle;