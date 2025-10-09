function player_handle_dash_cooldown() {
    if (dash_cooldown > 0) {
        // Base cooldown reduction + companion auras/triggers
        // get_companion_dash_cd_reduction() returns passive auras (scaled) + active triggers (unscaled)
        var _reduction = 1 + get_companion_dash_cd_reduction();

        dash_cooldown = max(0, dash_cooldown - _reduction);
    }
}