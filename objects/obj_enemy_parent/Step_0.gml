// Pause path movement when game is paused
if (global.game_paused) {
    // Save the path speed on first pause frame
    if (path_speed != 0) {
        saved_path_speed = path_speed;
        path_speed = 0;
    }
    exit;
}

// Restore path speed when unpaused
if (variable_instance_exists(self, "saved_path_speed") && saved_path_speed != 0) {
    path_speed = saved_path_speed;
    saved_path_speed = 0;
}

// Tick status effects (runs even when dead)
tick_status_effects();

// Update timed traits
update_timed_traits();

// Handle knockback movement when recently hit
if (knockback_timer > 0) {
    if (path_exists(path)) {
        path_end();
    }
    path_speed = 0;

    var _colliders = [tilemap, obj_enemy_parent, obj_rising_pillar, obj_player, obj_companion_parent];
    move_and_collide(kb_x, kb_y, _colliders);

    kb_x *= knockback_damping;
    kb_y *= knockback_damping;

    if (abs(kb_x) < 0.05) kb_x = 0;
    if (abs(kb_y) < 0.05) kb_y = 0;

    knockback_timer--;
    target_x = x;
    target_y = y;

    if (knockback_timer <= 0) {
        kb_x = 0;
        kb_y = 0;
    }

    return;
}

// Safe one-time inits (shared across states)
if (!variable_instance_exists(self, "last_dir_index"))   last_dir_index   = 0;
if (!variable_instance_exists(self, "anim_timer"))       anim_timer       = 0;
if (!variable_instance_exists(self, "anim_speed"))       anim_speed       = 0.18;
if (!variable_instance_exists(self, "move_speed"))       move_speed       = 1;
if (!variable_instance_exists(self, "prev_start_index")) prev_start_index = -1;

// Dedicated dead state handler mirrors player state machine flow
if (state == EnemyState.dead) {
    enemy_state_dead();
    return;
}

if ((state == EnemyState.targeting || state == EnemyState.ranged_attacking) && aggro_release_distance >= 0) {
    var _player_exists = instance_exists(obj_player);
    if (!_player_exists || point_distance(x, y, obj_player.x, obj_player.y) > aggro_release_distance) {
        if (path_exists(path)) {
            path_end();
        }
        path_speed = 0;
        state = EnemyState.wander;
        target_x = x;
        target_y = y;
        alarm[0] = 0;
    }
}

// Party controller weighted decision system
if (instance_exists(party_controller)) {
    party_controller.calculate_decision_weights(id);
}

// Dispatch to state-specific handlers
switch (state) {
    case EnemyState.targeting:
        enemy_state_targeting();
        break;

    case EnemyState.attacking:
        enemy_state_attacking();
        break;

    case EnemyState.ranged_attacking:
        enemy_state_ranged_attacking();
        break;

    case EnemyState.wander:
        enemy_state_wander();
        break;

    case EnemyState.idle:
        enemy_state_idle();
        break;

    default:
        state = EnemyState.targeting;
        enemy_state_targeting();
        break;
}

// Movement delta after state logic (supports path-based motion)
var _dx = x - xprevious;
var _dy = y - yprevious;
var _is_moving = (abs(_dx) > 0.1) || (abs(_dy) > 0.1);

if (!_is_moving) {
    if (path_exists(path)) {
        _dx = current_path_target_x - x;
        _dy = current_path_target_y - y;
        _is_moving = (abs(_dx) > 0.1) || (abs(_dy) > 0.1);
    }

    if (!_is_moving) {
        _dx = target_x - x;
        _dy = target_y - y;
        _is_moving = (abs(_dx) > 0.1) || (abs(_dy) > 0.1);
    }
}

// Determine facing (0=down,1=right,2=left,3=up)
var dir_index;
if (_is_moving) {
    if (abs(_dy) > abs(_dx)) dir_index = (_dy < 0) ? 3 : 0;
    else                     dir_index = (_dx < 0) ? 2 : 1;
    last_dir_index = dir_index;
} else {
    dir_index = last_dir_index;
}

// Update facing_dir string for ranged attacks (matches dir_index)
var _dir_names = ["down", "right", "left", "up"];
facing_dir = _dir_names[dir_index];

// Animation handling
image_speed = 0;

var _using_walk_anim = ((state == EnemyState.targeting || state == EnemyState.wander) && _is_moving);
var anim_info;

if (_using_walk_anim) {
    var _walk_keys = ["walk_down", "walk_right", "walk_left", "walk_up"];
    var _idle_keys = ["idle_down", "idle_right", "idle_left", "idle_up"];
    anim_info = enemy_anim_get(_walk_keys[dir_index], _idle_keys[dir_index]);
} else {
    anim_info = get_enemy_anim(state, dir_index);
}

var start_index = anim_info.start;
var frames_in_seq = anim_info.length;

// Reset timers when the sequence (block/dir) changes
if (prev_start_index != start_index) {
    if (state == EnemyState.attacking || state == EnemyState.ranged_attacking) {
        anim_timer = 0;
    }
    prev_start_index = start_index;
}

// Choose frame
var frame_offset;
var _use_idle_timer = (state == EnemyState.idle) || _using_walk_anim || !_is_moving;

if (_use_idle_timer) {
    frame_offset = global.idle_bob_timer % frames_in_seq;
} else {
    var speed_mult = 1.25; // faster feel for attacks
    anim_timer += anim_speed * speed_mult;
    frame_offset = floor(anim_timer) mod frames_in_seq;

    if (state == EnemyState.attacking && anim_timer >= frames_in_seq) {
        // Keep looping attack animation until alarm[2] finishes and resets state
        anim_timer = 0;
    }
}

// Final image index
var idx = start_index + frame_offset;
var max_index = sprite_get_number(sprite_index) - 1;
if (idx > max_index) idx = max_index;
if (idx < 0)         idx = 0;

image_index = idx;

// Attack cooldowns
if (attack_cooldown > 0) {
    attack_cooldown--;
    can_attack = false;
} else {
    can_attack = true;
}

if (ranged_attack_cooldown > 0) {
    ranged_attack_cooldown--;
    can_ranged_attack = false;
} else {
    can_ranged_attack = true;
}

if (state == EnemyState.ranged_attacking && ranged_attack_cooldown <= 0) {
    state = EnemyState.targeting;
}
