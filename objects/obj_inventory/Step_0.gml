// === STEP EVENT ===
if (keyboard_check_pressed(ord("I"))) {
    is_open = !is_open;
    
    // Create a global pause variable if it doesn't exist
    global.game_paused = is_open;
}