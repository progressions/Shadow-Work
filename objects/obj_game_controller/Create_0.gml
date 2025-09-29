persistent = true;

// Initialize audio configuration
global.audio_config = {
    music_enabled: true,
    sfx_enabled: true
};

show_debug_message("Audio config initialized - Music: " + string(global.audio_config.music_enabled) + ", SFX: " + string(global.audio_config.sfx_enabled));

// Load all audio groups
audio_group_load(audiogroup_default);
audio_group_load(audiogroup_music);
audio_group_load(audiogroup_sfx);

show_debug_message("Audio groups loaded");

// Set audio group gains
audio_group_set_gain(audiogroup_default, 1, 0);
audio_group_set_gain(audiogroup_music, 1, 0);
audio_group_set_gain(audiogroup_sfx, 1, 0);

show_debug_message("Audio group gains set");

// Initialize music variable
global.music = -1;

// Check if music audio group is loaded before playing
show_debug_message("Checking if music audio group is loaded: " + string(audio_group_is_loaded(audiogroup_music)));

if (global.audio_config.music_enabled) {
    if (audio_group_is_loaded(audiogroup_music)) {
        show_debug_message("Attempting to start music directly");
        global.music = audio_play_sound(Shadow_Kingdom_theme_2025_09_29, 1, true);
        show_debug_message("Direct audio_play_sound returned: " + string(global.music));

        // Set volume if music is playing
        if (global.music != -1) {
            audio_sound_gain(global.music, 0.7, 0);
            show_debug_message("Music volume set to 0.7");
        } else {
            show_debug_message("ERROR: audio_play_sound returned -1");
        }
    } else {
        show_debug_message("Music audio group not loaded yet, waiting...");
        alarm[0] = 30; // Wait 30 frames (0.5 seconds at 60fps) then try again
    }
} else {
    show_debug_message("Music disabled in config");
}


// ============================================
// SETUP - In your initialization object
// ============================================
global.idle_bob_timer = 0;  // Global timer that everyone uses
