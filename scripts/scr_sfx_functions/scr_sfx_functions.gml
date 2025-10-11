
function play_sfx(_sound, _volume=1, _priority=8, _loop=false, _fade_in_speed=0, _fade_out_speed=0) {
	var _sound_asset = _sound;
	var _base_name = "";

	// Handle both string and asset references
	if (is_string(_sound)) {
		_base_name = _sound;
		_sound_asset = asset_get_index(_sound);
	} else {
		// Asset reference - get the name
		_base_name = audio_get_name(_sound);
	}

	// Check for variants in cache
	var _variant_count = global.sound_variant_lookup[$ _base_name] ?? 0;

	if (_variant_count > 0) {
		// Pick random variant
		var _variant_num = irandom_range(1, _variant_count);
		var _variant_name = _base_name + "_" + string(_variant_num);
		_sound_asset = asset_get_index(_variant_name);

		// Debug logging (optional, controlled by global flag)
		if (global.debug_sound_variants) {
			show_debug_message("Sound variant: " + _variant_name + " (picked " + string(_variant_num) + " of " + string(_variant_count) + ")");
		}
	} else {
		// No variants, use original sound
		if (global.debug_sound_variants && _base_name != "") {
			show_debug_message("Sound (no variants): " + _base_name);
		}
	}

	// Fallback: if sound asset is invalid, try base name one more time
	if (_sound_asset == -1 && _base_name != "") {
		_sound_asset = asset_get_index(_base_name);
	}

	// Final check: if sound doesn't exist, log warning and return
	if (_sound_asset == -1) {
		show_debug_message("⚠ WARNING: Sound asset not found: " + _base_name);
		return;
	}

	// Call existing sfx controller logic
	obj_sfx_controller.play_sfx(_sound_asset, _volume, _priority, _loop, _fade_in_speed, _fade_out_speed);
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
		case "on_melee_attack":
			// Default to sword sound for enemy attacks
			if (audio_exists(snd_attack_sword)) {
				play_sfx(snd_attack_sword, _volume);
				return true;
			}
			break;
		case "on_ranged_attack":
			// Default to bow attack sound for ranged attacks
			if (audio_exists(snd_bow_attack)) {
				play_sfx(snd_bow_attack, _volume);
				return true;
			}
			break;
		case "on_ranged_windup":
			// Default to ranged windup sound
			if (audio_exists(snd_ranged_windup)) {
				play_sfx(snd_ranged_windup, _volume);
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
