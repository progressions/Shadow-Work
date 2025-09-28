creator = obj_player;

// Set damage based on weapon or default
with (creator) {
    other.damage = get_total_damage();
}

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

// Animation settings based on weapon attack speed
var _attack_speed = 1.0; // Default unarmed speed
if (creator.equipped.right_hand != undefined && creator.equipped.right_hand.definition.type == ItemType.weapon) {
    _attack_speed = creator.equipped.right_hand.definition.stats.attack_speed;
}

swing_speed = 10 * _attack_speed; // Faster weapons swing quicker
swing_range = 90; // Total degrees to swing
swing_progress = 0;

// Set starting angle, base angle, and offset based on player's facing direction
switch (creator.facing_dir) {
    case "right":
        start_angle = -45;
        base_angle = 0;    // For slash effect
        offset_x = 8;
        offset_y = -8;
        break;
    case "left":
        start_angle = 135;
        base_angle = 180;  // For slash effect
        offset_x = -8;
        offset_y = -8;
        break;
    case "up":
        start_angle = 45;
        base_angle = 90;   // For slash effect
        offset_x = 0;
        offset_y = -16;
        break;
    case "down":
        start_angle = 225;
        base_angle = 270;  // For slash effect
        offset_x = 0;
        offset_y = 0;
        break;
}

image_angle = start_angle;