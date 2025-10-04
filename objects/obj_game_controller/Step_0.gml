// Top of obj_player Step Event - BEFORE everything else:

// Ensure lighting controller exists every frame
if (!instance_exists(obj_lighting_controller)) {
    var _layer = "Instances";
    if (!layer_exists(_layer)) {
        var _first_layer_id = layer_get_id(0);
        _layer = layer_get_name(_first_layer_id);
    }
    instance_create_layer(0, 0, _layer, obj_lighting_controller);
}

// M key to toggle audio - works even when paused
if (keyboard_check_pressed(ord("M"))) {
	global.audio_config.sfx_enabled = !global.audio_config.sfx_enabled;
	global.audio_config.music_enabled = !global.audio_config.music_enabled;
}

if (global.game_paused) return;

global.idle_bob_timer += 0.05;
if (global.idle_bob_timer >= 2) {
    global.idle_bob_timer -= 2;
}
