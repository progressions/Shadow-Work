
function play_sfx(_sound, _volume=1, _priority=8, _loop=false, _fade_in_speed=0, _fade_out_speed=0) {
	obj_sfx_controller.play_sfx(_sound, _volume, _priority, _loop, _fade_in_speed, _fade_out_speed);
}

function stop_looped_sfx(_sound) {
	obj_sfx_controller.stop_looped_sfx(_sound);
}

function stop_all_footstep_sounds() {
	if (!variable_global_exists("terrain_footstep_sounds")) return;

	var _terrain_names = variable_struct_get_names(global.terrain_footstep_sounds);
	for (var i = 0; i < array_length(_terrain_names); i++) {
		var _sound = global.terrain_footstep_sounds[$ _terrain_names[i]];
		stop_looped_sfx(_sound);
	}
}

function play_enemy_sfx(_event_name, _volume=1) {
	// Check if enemy has custom sound configured
	if (variable_instance_exists(self, "enemy_sounds")) {
		var _sound = enemy_sounds[$ _event_name];
		if (_sound != undefined) {
			play_sfx(_sound, _volume);
			return true;
		}
	}

	// Fallback to default sounds
	switch(_event_name) {
		case "on_death":
			if (audio_exists(snd_enemy_death)) {
				play_sfx(snd_enemy_death, _volume);
				return true;
			}
			break;
		case "on_hit":
			// Default to generic hit sound if available
			if (audio_exists(snd_attack_hit)) {
				play_sfx(snd_attack_hit, _volume);
				return true;
			}
			break;
		case "on_attack":
			// Default to sword sound for enemy attacks
			if (audio_exists(snd_attack_sword)) {
				play_sfx(snd_attack_sword, _volume);
				return true;
			}
			break;
		case "on_aggro":
		case "on_footstep":
		case "on_status_effect":
			// No default sounds for these events yet
			return false;
	}

	return false;
}
