persistent = true;

audio_group_load(audiogroup_default);
audio_group_set_gain(audiogroup_default, 1, 0);

// Start background music
global.music = audio_play_sound(Shadow_Kingdom_theme_2025_09_29, 1, true);

// Optional: Set volume
audio_sound_gain(global.music, 0.7, 0);


// ============================================
// SETUP - In your initialization object
// ============================================
global.idle_bob_timer = 0;  // Global timer that everyone uses
