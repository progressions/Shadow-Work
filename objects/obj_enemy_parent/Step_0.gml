
if (alarm[1] > 0) {
	target_x = x + kb_x;
	target_y = y + kb_y;
}
if (state == PlayerState.dead) {
	// Play dying animation once, then stay on final frame
	if (!variable_instance_exists(self, "death_anim_complete")) {
		death_anim_complete = false;
		death_anim_timer = 0;
	}

	if (!death_anim_complete) {
		// Play dying animation (frames 32-34)
		var dying_anim = global.enemy_anim_data.dying;
		death_anim_timer += anim_speed;
		var frame_offset = floor(death_anim_timer) % dying_anim.length;
		image_index = dying_anim.start + frame_offset;

		// Check if we've completed the dying animation
		if (death_anim_timer >= dying_anim.length) {
			death_anim_complete = true;
			image_index = dying_anim.start + dying_anim.length - 1; // Final frame (34)
		}
	} else {
		// Stay on final dead frame
		image_index = 34;
	}
	return; // Skip the rest of the animation logic
}
if (state != PlayerState.dead) {
/// STEP EVENT — Movement + Directional Animation (using structured anim data)
/// Animation frames are defined in global.enemy_anim_data

/// ---------- Safe one-time inits
if (!variable_instance_exists(self, "last_dir_index"))   last_dir_index   = 0;   // 0=down,1=right,2=left,3=up
if (!variable_instance_exists(self, "anim_timer"))       anim_timer       = 0;   // used for attack only
if (!variable_instance_exists(self, "anim_speed"))       anim_speed       = 0.18;
if (!variable_instance_exists(self, "move_speed"))       move_speed       = 1;
if (!variable_instance_exists(self, "prev_start_index")) prev_start_index = -1;

/// ---------- Movement vector toward target
var _hor = clamp(target_x - x, -1, 1);
var _ver = clamp(target_y - y, -1, 1);
var _is_moving = (abs(_hor) > 0.1) || (abs(_ver) > 0.1);

/// ---------- State control
if (state != PlayerState.attacking) {
    state = _is_moving ? PlayerState.walking : PlayerState.idle;
}

/// ---------- Apply movement
move_and_collide(_hor * move_speed, _ver * move_speed, [tilemap, obj_enemy_parent, obj_rising_pillar]);

/// ---------- Determine facing (0=down,1=right,2=left,3=up)
var dir_index;
if (_is_moving) {
    if (abs(_ver) > abs(_hor)) dir_index = (_ver < 0) ? 3 : 0;
    else                       dir_index = (_hor < 0) ? 2 : 1;
    last_dir_index = dir_index;
} else {
    dir_index = last_dir_index;
}

/// ---------- Animation block + direction offsets
image_speed = 0;

// Get animation data using the new structured system
var anim_info = get_enemy_anim(state, dir_index);
var start_index = anim_info.start;
var frames_in_seq = anim_info.length;

/// ---------- Reset timers when the sequence (block/dir) changes
if (prev_start_index != start_index) {
    // idle/walk use global timer so no need to reset anything there
    // attack uses local timer; reset it for crisp starts
    if (state == PlayerState.attacking) anim_timer = 0;
    prev_start_index = start_index;
}

/// ---------- Choose frame
var frame_offset;

if (state == PlayerState.idle || state == PlayerState.walking) {
    // Sync idle + walking to the shared global bob timer
    frame_offset = global.idle_bob_timer % frames_in_seq;
} else { 
    // Attacking uses local timing (can also be switched to global if desired)
    var speed_mult = 1.25; // faster feel for attacks
    anim_timer += anim_speed * speed_mult;
    frame_offset = floor(anim_timer) mod frames_in_seq;
}

/// ---------- Final image index
var idx = start_index + frame_offset;

var max_index = sprite_get_number(sprite_index) - 1;
if (idx > max_index) idx = max_index;
if (idx < 0)         idx = 0;

image_index = idx;

/// ---------- Attack System
// Update attack cooldown
if (attack_cooldown > 0) {
    attack_cooldown--;
    can_attack = false;
} else {
    can_attack = true;
}

// Check if player is in attack range and we can attack
if (can_attack && state != PlayerState.attacking) {
    var _player = instance_nearest(x, y, obj_player);
    if (_player != noone) {
        var _dist = point_distance(x, y, _player.x, _player.y);
        if (_dist <= attack_range) {
            // Start attack
            state = PlayerState.attacking;
            attack_cooldown = round(90 / attack_speed); // Enemy attacks are slower
            can_attack = false;

            // Create attack after a short delay (so animation plays first)
            alarm[2] = 15; // Attack hits after 15 frames
        }
    }
}
}