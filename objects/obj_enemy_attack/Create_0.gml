creator = obj_enemy_parent;

// Attack category for damage reduction calculations
attack_category = AttackCategory.melee;

// Set damage based on enemy stats
damage = creator.attack_damage;

// Visual representation - use a simple red slash effect
sprite_index = spr_slash;
image_blend = c_red;
image_alpha = 0.7;

// Animation settings based on enemy attack speed
swing_speed = 8 * creator.attack_speed; // Enemy attacks are a bit slower than player
swing_range = 60; // Smaller swing arc for enemies
swing_progress = 0;

// Set starting angle and base angle based on enemy's direction to player
var _player = instance_nearest(creator.x, creator.y, obj_player);
if (_player != noone) {
    var _angle = point_direction(creator.x, creator.y, _player.x, _player.y);

    // Convert angle to facing direction
    if (_angle >= 315 || _angle < 45) {
        // Right
        start_angle = -30;
        base_angle = 0;
    } else if (_angle >= 45 && _angle < 135) {
        // Down
        start_angle = 225;
        base_angle = 270;
    } else if (_angle >= 135 && _angle < 225) {
        // Left
        start_angle = 150;
        base_angle = 180;
    } else {
        // Up
        start_angle = 60;
        base_angle = 90;
    }
} else {
    // Default to down if no player found
    start_angle = 225;
    base_angle = 270;
}

image_angle = start_angle;