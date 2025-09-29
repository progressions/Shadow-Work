persistent = true;

audio_group_load(audiogroup_default);
audio_group_set_gain(audiogroup_default, 1, 0);

// Start background music
global.music = audio_play_sound(sound_shadow_kingdom_theme, 1, true);

// Optional: Set volume
audio_sound_gain(global.music, 0.7, 0);


// ============================================
// SETUP - In your initialization object
// ============================================
global.idle_bob_timer = 0;  // Global timer that everyone uses

var _overlay_layer = "GameUI";
var _overlay_layer_id = layer_get_id(_overlay_layer);

if (_overlay_layer_id == -1) {
    _overlay_layer = "UI";
    _overlay_layer_id = layer_get_id(_overlay_layer);
}

if (_overlay_layer_id == -1) {
    var _depth_layer_id = layer_get_id_at_depth(0);
    if (_depth_layer_id != -1) {
        _overlay_layer_id = _depth_layer_id;
        _overlay_layer = layer_get_name(_overlay_layer_id);
    }
}

if (_overlay_layer_id == -1) {
    _overlay_layer = "GameUI";
    _overlay_layer_id = layer_create(0, _overlay_layer);
}

if (!instance_exists(obj_ui_overlay)) {
    instance_create_layer(0, 0, _overlay_layer, obj_ui_overlay);
}
