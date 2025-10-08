if (global.game_paused) {
	event_inherited();
	exit;
}

// Handle slither dash before running base enemy logic
if (slither_dash_active) {
	// Apply terrain/status modifiers to dash speed
	var _speed_mod = get_status_effect_modifier("speed");
	var _terrain_mod = enemy_get_terrain_speed_modifier();
	var _dash_speed = slither_dash_speed * _speed_mod * _terrain_mod;
	if (_dash_speed <= 0) _dash_speed = slither_dash_speed;

	var _dx = lengthdir_x(_dash_speed, slither_dash_direction);
	var _dy = lengthdir_y(_dash_speed, slither_dash_direction);
	var _next_x = x + _dx;
	var _next_y = y + _dy;

	// Abort if dash would cross a hazard tile
	if (collision_line(x, y, _next_x, _next_y, obj_hazard_parent, false, true)) {
		slither_dash_active = false;
		slither_dash_timer = 0;
		path_speed = slither_dash_saved_path_speed;
		slither_dash_cooldown = irandom_range(slither_dash_cooldown_min, slither_dash_cooldown_max);
	} else {
		move_and_collide(_dx, _dy, [
			tilemap,
			obj_enemy_parent,
			obj_rising_pillar,
			obj_companion_parent,
			obj_player,
			obj_hazard_parent
		]);

		move_dir_x = sign(_dx);
		move_dir_y = sign(_dy);

		slither_dash_timer--;
		if (slither_dash_timer <= 0) {
			slither_dash_active = false;
			path_speed = slither_dash_saved_path_speed;
		}
	}

	depth = -bbox_bottom;
	exit;
}

// Cooldown management (only when not currently dashing)
if (slither_dash_cooldown > 0) {
	slither_dash_cooldown--;
} else if ((state == EnemyState.targeting || state == EnemyState.ranged_attacking) && instance_exists(obj_player)) {
	var _target_dist = point_distance(x, y, obj_player.x, obj_player.y);
	if (_target_dist <= slither_dash_trigger_range) {
		var _dash_length = slither_dash_speed * slither_dash_duration;
		var _dash_angle = point_direction(x, y, obj_player.x, obj_player.y);
		var _target_x = x + lengthdir_x(_dash_length, _dash_angle);
		var _target_y = y + lengthdir_y(_dash_length, _dash_angle);

		if (!collision_line(x, y, _target_x, _target_y, obj_hazard_parent, false, true)) {
			slither_dash_active = true;
			slither_dash_timer = slither_dash_duration;
			slither_dash_direction = _dash_angle;
			slither_dash_saved_path_speed = path_speed;
			if (path_exists(path)) path_end();
			path_speed = 0;
			move_dir_x = sign(lengthdir_x(1, slither_dash_direction));
			move_dir_y = sign(lengthdir_y(1, slither_dash_direction));
			slither_dash_cooldown = irandom_range(slither_dash_cooldown_min, slither_dash_cooldown_max);
			play_sfx(snd_dash, 0.6);
		} else {
			slither_dash_cooldown = slither_dash_cooldown_min;
		}
	}
}

// Run baseline enemy behavior
event_inherited();
