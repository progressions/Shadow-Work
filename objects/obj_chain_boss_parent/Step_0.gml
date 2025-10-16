/// Chain Boss Parent - Step Event
// Check for enrage phase trigger when all auxiliaries are defeated

// Inherit parent Step behavior first
event_inherited();

// ============================================
// ENRAGE PHASE SYSTEM
// ============================================

// Check if all auxiliaries are dead and boss hasn't enraged yet
if (!is_enraged && auxiliaries_alive <= 0) {
    is_enraged = true;

    // Apply enrage stat multipliers
    attack_speed *= enrage_attack_speed_multiplier;
    move_speed *= enrage_move_speed_multiplier;
    attack_damage *= enrage_damage_multiplier;

    // Also boost ranged damage if dual-mode enemy
    if (variable_instance_exists(self, "ranged_damage")) {
        ranged_damage *= enrage_damage_multiplier;
    }

    // Visual feedback - red tint
    image_blend = c_red;

    // Play enrage sound if available
    if (variable_instance_exists(self, "enemy_sounds") &&
        variable_struct_exists(enemy_sounds, "on_enrage") &&
        audio_exists(enemy_sounds.on_enrage)) {
        play_sfx(enemy_sounds.on_enrage, 1, false);
    }

    show_debug_message("CHAIN BOSS ENRAGED! All auxiliaries defeated.");
    show_debug_message("  Attack Speed: " + string(attack_speed));
    show_debug_message("  Move Speed: " + string(move_speed));
    show_debug_message("  Attack Damage: " + string(attack_damage));
}
