creator = obj_player;

// Attack category for damage reduction calculations
attack_category = AttackCategory.melee;

// Track which enemies have been hit to prevent multi-hit on same enemy
hit_enemies = ds_list_create();

// Hit count limiting system (for multi-hit traits in future)
max_hit_count = 1;        // Default: can only damage 1 enemy total
current_hit_count = 0;    // Track how many enemies have been damaged

// Default hit properties (updated after querying the creator)
hit_range = 28;
hit_scale = 1;

// Pull combat values from the player instance
knockback_force = 6;
with (creator) {
    other.damage = get_total_damage();
    other.hit_range = get_attack_range();
    if (equipped.right_hand != undefined) {
        var _weapon_stats = equipped.right_hand.definition.stats;
        if (variable_struct_exists(_weapon_stats, "knockback_force")) {
            other.knockback_force = _weapon_stats.knockback_force;
        }
    }
}

// Use the slash sprite for collision detection regardless of the visual weapon
mask_index = spr_slash;

// Select the appropriate weapon sprite for visuals
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

// Keep fast weapons responsive but ensure a reasonable active window
var _target_frames = clamp(round(18 / max(_attack_speed, 0.1)), 10, 26);
swing_speed = 100 / _target_frames;
swing_range = 90; // Total degrees to swing
swing_progress = 0;

// Scale visual and collision footprint based on weapon reach
var _base_visual_range = 32;
hit_scale = clamp(hit_range / _base_visual_range, 0.8, 1.6);
image_xscale = hit_scale;
image_yscale = hit_scale;

// Offset adjustments grow slightly with weapon reach
var _range_bonus = (hit_range - _base_visual_range);

switch (creator.facing_dir) {
    case "right":
        start_angle = -45;
        base_angle = 0;    // For slash effect
        offset_x = 8 + (_range_bonus * 0.35);
        offset_y = -8;
        break;
    case "left":
        start_angle = 135;
        base_angle = 180;  // For slash effect
        offset_x = -8 - (_range_bonus * 0.35);
        offset_y = -8;
        break;
    case "up":
        start_angle = 45;
        base_angle = 90;   // For slash effect
        offset_x = 0;
        offset_y = -16 - (_range_bonus * 0.2);
        break;
    case "down":
        start_angle = 225;
        base_angle = 270;  // For slash effect
        offset_x = 0;
        offset_y = (_range_bonus * 0.15);
        break;
}

image_angle = start_angle;
