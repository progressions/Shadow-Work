
if (alarm[1] > 0) {
	target_x = x + kb_x;
	target_y = y + kb_y;
}
if (state == PlayerState.dead) {
	image_index = 34;
}
if (state != PlayerState.dead) {
/// STEP EVENT — Movement + Directional Animation (idle/walk use global bob; attack local)
/// Sprite layout (indices):
/// idle_[down,right,left,up]    : 2 frames each -> offsets 0, 2, 4, 6
/// walking_[down,right,left,up] : 3 frames each -> offsets 8, 11, 14, 17
/// attack_[down,right,left,up]  : 3 frames each -> offsets 20, 23, 26, 29
/// (Total frames indexed 0..31)

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

var start_index = 0;
var frames_in_seq = 1;

switch (state) {
    case PlayerState.idle:
        frames_in_seq = 2;
        start_index   = 0 + (dir_index * 2);
        break;
    case PlayerState.walking:
        frames_in_seq = 3;
        start_index   = 8 + (dir_index * 3);
        break;
    case PlayerState.attacking:
        frames_in_seq = 3;
        start_index   = 20 + (dir_index * 3);
        break;
    default:
        frames_in_seq = 2;
        start_index   = 0;
        break;
}

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
}