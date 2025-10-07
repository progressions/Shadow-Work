function player_handle_dash_cooldown() {
    if (dash_cooldown > 0) {
        // Base cooldown reduction
        var _reduction = 1;

        // Check for Slipstream Boost from Hola
        var companions = get_active_companions();
        for (var i = 0; i < array_length(companions); i++) {
            var companion = companions[i];

            if (variable_struct_exists(companion.triggers, "slipstream_boost")) {
                var trigger = companion.triggers.slipstream_boost;

                if (trigger.active && variable_instance_exists(companion, "slipstream_boost_timer") && companion.slipstream_boost_timer > 0) {
                    _reduction += trigger.dash_cd_boost; // Add 35% boost
                }
            }
        }

        dash_cooldown = max(0, dash_cooldown - _reduction);
    }
}