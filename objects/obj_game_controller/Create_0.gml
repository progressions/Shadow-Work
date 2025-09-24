// Start background music
global.music = audio_play_sound(sound_shadow_kingdom_theme, 1, true);

// Optional: Set volume
audio_sound_gain(global.music, 0.7, 0);


// ============================================
// SETUP - In your initialization object
// ============================================
global.idle_bob_timer = 0;  // Global timer that everyone uses
