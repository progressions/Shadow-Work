function player_state_idle() {
    // Check for dash input first
    if (player_handle_dash_input()) {
        return; // Dash was triggered, state changed
    }

    // Check for input to transition to walking
    var _hor = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _ver = keyboard_check(ord("S")) - keyboard_check(ord("W"));

    if (_hor != 0 || _ver != 0) {
        state = PlayerState.walking;
        return;
    }

    // Stay in idle
    move_dir = "idle";

    // Handle knockback
    player_handle_knockback();
}