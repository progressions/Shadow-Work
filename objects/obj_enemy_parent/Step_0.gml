
if (global.game_paused) exit;

// Tick status effects (runs even when dead)
tick_status_effects();

if (alarm[1] > 0) {
	target_x = x + kb_x;
	target_y = y + kb_y;
}
if (state == EnemyState.dead) {
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

			// Create corpse and destroy this enemy instance
			var _corpse = instance_create_layer(x, y, "Instances", obj_enemy_corpse);
			_corpse.sprite_index = sprite_index;
			_corpse.image_index = image_index;
			instance_destroy();
		}
	} else {
		// Stay on final dead frame (shouldn't reach here since instance is destroyed)
		image_index = 34;
	}
	return; // Skip the rest of the animation logic
}
if (state != EnemyState.dead) {
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
if (state != EnemyState.attacking && state != EnemyState.ranged_attacking) {
    state = _is_moving ? EnemyState.idle : EnemyState.idle;
}

/// ---------- Apply movement with status effect speed modifiers
var speed_modifier = get_status_effect_modifier("speed");
var final_move_speed = move_speed * speed_modifier;
move_and_collide(_hor * final_move_speed, _ver * final_move_speed, [tilemap, obj_enemy_parent, obj_rising_pillar]);

/// ---------- Determine facing (0=down,1=right,2=left,3=up)
var dir_index;
if (_is_moving) {
    if (abs(_ver) > abs(_hor)) dir_index = (_ver < 0) ? 3 : 0;
    else                       dir_index = (_hor < 0) ? 2 : 1;
    last_dir_index = dir_index;
} else {
    dir_index = last_dir_index;
}

// Update facing_dir string for ranged attacks (matches dir_index)
switch (dir_index) {
    case 0: facing_dir = "down"; break;
    case 1: facing_dir = "right"; break;
    case 2: facing_dir = "left"; break;
    case 3: facing_dir = "up"; break;
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
    if (state == EnemyState.attacking || state == EnemyState.ranged_attacking) anim_timer = 0;
    prev_start_index = start_index;
}

/// ---------- Choose frame
var frame_offset;

if (state == EnemyState.idle) {
    // Sync idle + walking to the shared global bob timer
    frame_offset = global.idle_bob_timer % frames_in_seq;
} else {
    // Attacking uses local timing (can also be switched to global if desired)
    var speed_mult = 1.25; // faster feel for attacks
    anim_timer += anim_speed * speed_mult;
    frame_offset = floor(anim_timer) mod frames_in_seq;

    // Check if attack animation has completed
    if (state == EnemyState.attacking && anim_timer >= frames_in_seq) {
        // Keep looping attack animation until alarm[2] finishes and resets state
        // Don't reset state here - let the attack complete first
        anim_timer = 0; // Reset animation to loop
    }
}

/// ---------- Final image index
var idx = start_index + frame_offset;

var max_index = sprite_get_number(sprite_index) - 1;
if (idx > max_index) idx = max_index;
if (idx < 0)         idx = 0;

image_index = idx;

/// ---------- Attack System
// Update attack cooldown (melee)
if (attack_cooldown > 0) {
    attack_cooldown--;
    can_attack = false;
} else {
    can_attack = true;
}

// Update ranged attack cooldown
if (ranged_attack_cooldown > 0) {
    ranged_attack_cooldown--;
    can_ranged_attack = false;
} else {
    can_ranged_attack = true;
}

// Handle ranged attacking state transition back to idle
if (state == EnemyState.ranged_attacking && ranged_attack_cooldown <= 0) {
    state = EnemyState.idle;
}

// Check if player is in attack range and we can attack
if (state != EnemyState.attacking && state != EnemyState.ranged_attacking) {
    var _player = instance_nearest(x, y, obj_player);
    if (_player != noone) {
        var _dist = point_distance(x, y, _player.x, _player.y);
        if (_dist <= attack_range) {
            // Play aggro sound on first detection (only if we haven't played it recently)
            if (!variable_instance_exists(self, "last_aggro_time")) {
                last_aggro_time = 0;
            }
            if (current_time - last_aggro_time > 3000) { // Cooldown: only play every 3 seconds
                play_enemy_sfx("on_aggro");
                last_aggro_time = current_time;
            }

            // Ranged attackers fire arrows
            if (is_ranged_attacker && can_ranged_attack) {
                enemy_handle_ranged_attack();
            }
            // Melee attackers use traditional attack
            else if (!is_ranged_attacker && can_attack) {
                state = EnemyState.attacking;
                attack_cooldown = round(90 / attack_speed); // Enemy attacks are slower
                can_attack = false;

                // Create attack after a short delay (so animation plays first)
                alarm[2] = 15; // Attack hits after 15 frames
            }
        }
    }
}
}