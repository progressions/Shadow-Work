creator = obj_player;

// Attack category for damage reduction calculations
attack_category = AttackCategory.melee;

// Track which enemies have been hit to prevent multi-hit on same enemy
hit_enemies = ds_list_create();

// Hit count limiting system (for multi-hit traits in future)
max_hit_count = 1;        // Default: can only damage 1 enemy total
current_hit_count = 0;    // Track how many enemies have been damaged

// Critical hit flag (set from creator's last_attack_was_crit)
is_crit = false;

// Default hit properties (updated after querying the creator)
hit_range = 28;
hit_scale = 1;

// Pull combat values from the player instance
knockback_force = 6;
shake_intensity = 2; // Default shake for unarmed/daggers
with (creator) {
    other.damage = get_total_damage(); // This also rolls for crit and sets last_attack_was_crit
    other.is_crit = last_attack_was_crit; // Read crit flag after damage calculation
    other.hit_range = get_attack_range();
    if (equipped.right_hand != undefined) {
        var _weapon_stats = equipped.right_hand.definition.stats;
        if (variable_struct_exists(_weapon_stats, "knockback_force")) {
            other.knockback_force = _weapon_stats.knockback_force;
        }

        // Set screen shake intensity based on weapon handedness
        var _weapon_handedness = equipped.right_hand.definition.handedness;
        if (_weapon_handedness == WeaponHandedness.two_handed) {
            other.shake_intensity = 8; // Heavy weapons = big shake
        } else if (_weapon_handedness == WeaponHandedness.versatile) {
            // Versatile: 6 if two-handing, 4 if one-handing
            other.shake_intensity = is_two_handing() ? 6 : 4;
        } else if (_weapon_handedness == WeaponHandedness.one_handed) {
            other.shake_intensity = 4; // Swords/maces = medium shake
        } else {
            other.shake_intensity = 2; // Daggers/light weapons = light shake
        }
    }

    // Check for multi-target bonuses from companions (Yorna's aura)
    var _multi_params = get_companion_multi_target_params();
    if (_multi_params != undefined) {
        // Roll for multi-target chance
        if (random(1) < _multi_params.chance) {
            other.max_hit_count = _multi_params.max_targets;
            show_debug_message("Multi-target activated! Max targets: " + string(other.max_hit_count));
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

// No position offsets - weapon sprites pivot from player center
offset_x = 0;
offset_y = 0;

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
    default:
        // Fallback if facing_dir has unexpected value
        show_debug_message("WARNING: Unexpected facing_dir: " + string(creator.facing_dir) + ", defaulting to down");
        start_angle = 225;
        base_angle = 270;
        break;
}

image_angle = start_angle;
