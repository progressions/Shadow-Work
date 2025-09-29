// Retry starting background music after audio group loads
show_debug_message("Alarm 0: Retrying music start");
show_debug_message("Music audio group loaded: " + string(audio_group_is_loaded(audiogroup_music)));

if (global.audio_config.music_enabled && audio_group_is_loaded(audiogroup_music)) {
    show_debug_message("Attempting to start music (delayed)");
    global.music = audio_play_sound(Shadow_Kingdom_theme_2025_09_29, 1, true);
    show_debug_message("Delayed audio_play_sound returned: " + string(global.music));

    // Set volume if music is playing
    if (global.music != -1) {
        audio_sound_gain(global.music, 0.7, 0);
        show_debug_message("Music volume set to 0.7 (delayed)");
    } else {
        show_debug_message("ERROR: Delayed audio_play_sound returned -1");
    }
} else if (!audio_group_is_loaded(audiogroup_music)) {
    show_debug_message("Music audio group still not loaded, waiting more...");
    alarm[0] = 60; // Wait another second
} else {
    show_debug_message("Music disabled in config during retry");
}