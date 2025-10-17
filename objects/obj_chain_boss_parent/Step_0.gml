/// Chain Boss Parent - Step Event
// Check for enrage phase trigger when all auxiliaries are defeated

// Inherit parent Step behavior first
event_inherited();

// ============================================
// AUXILIARY RESPAWN COOLDOWN
// ============================================

// Countdown auxiliary respawn cooldown
if (auxiliary_respawn_cooldown_timer > 0) {
    auxiliary_respawn_cooldown_timer--;
}

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

// ============================================
// THROW ATTACK SYSTEM
// ============================================

// Countdown throw cooldown
if (throw_cooldown_timer > 0) {
    throw_cooldown_timer--;
}

// Only attempt throw if enabled and not currently throwing
if (enable_throw_attack && throw_state == "none" && throw_cooldown_timer <= 0) {
    // Check if player exists and is in range
    if (instance_exists(obj_player)) {
        var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

        // Check if player is in throw range
        if (_dist_to_player >= throw_range_min && _dist_to_player <= throw_range_max) {
            // If no auxiliaries left and respawn enabled and cooldown elapsed, respawn them first
            if (auxiliaries_alive <= 0 && enable_auxiliary_respawn && auxiliary_respawn_cooldown_timer <= 0) {
                chain_boss_respawn_auxiliaries();
                auxiliary_respawn_cooldown_timer = auxiliary_respawn_cooldown;
            }

            // Find an available auxiliary (not stunned, not already being thrown)
            var _available_aux = noone;
            for (var i = 0; i < array_length(auxiliaries); i++) {
                var _aux = auxiliaries[i];
                if (instance_exists(_aux) &&
                    _aux.throw_state == "idle" &&
                    !_aux.is_stunned &&
                    _aux.state != EnemyState.dead) {
                    _available_aux = _aux;
                    break;
                }
            }

            // Start throw attack if auxiliary available
            if (_available_aux != noone) {
                throw_state = "winding_up";
                throw_target_auxiliary = _available_aux;
                throw_windup_timer = throw_windup_time;

                // Play throw start sound
                if (audio_exists(throw_sound_start)) {
                    play_sfx(throw_sound_start, 1, 8, false);
                }

                show_debug_message("Chain Boss initiating throw attack!");
            }
        }
    }
}

// Handle throw windup
if (throw_state == "winding_up") {
    throw_windup_timer--;

    if (throw_windup_timer <= 0) {
        // Launch the auxiliary
        if (instance_exists(throw_target_auxiliary) && instance_exists(obj_player)) {
            var _aux = throw_target_auxiliary;

            // Calculate throw velocity toward player
            var _angle = point_direction(_aux.x, _aux.y, obj_player.x, obj_player.y);
            _aux.throw_velocity_x = lengthdir_x(throw_speed, _angle);
            _aux.throw_velocity_y = lengthdir_y(throw_speed, _angle);

            // Set auxiliary to thrown state
            _aux.throw_state = "being_thrown";

            // Save original collision damage state and enable during throw
            _aux.original_collision_damage_enabled = _aux.collision_damage_enabled;
            _aux.collision_damage_enabled = true;
            _aux.collision_damage_amount = throw_damage;
            _aux.collision_damage_type = throw_damage_type;

            // Play flying sound (looping)
            if (audio_exists(throw_sound_flying)) {
                play_sfx(throw_sound_flying, 0.7, 8, true); // volume, priority, loop
            }

            // Boss enters throwing state
            throw_state = "throwing";

            show_debug_message("Auxiliary launched at player!");
        } else {
            // Target lost, abort
            throw_state = "none";
            throw_target_auxiliary = noone;
        }
    }
}

// ============================================
// SPIN ATTACK SYSTEM
// ============================================

// Countdown spin cooldown
if (spin_cooldown_timer > 0) {
    spin_cooldown_timer--;
}

// Only attempt spin if enabled, not currently spinning or throwing
if (enable_spin_attack && spin_state == "none" && throw_state == "none" && spin_cooldown_timer <= 0) {
    // Check if player exists and is in range
    if (instance_exists(obj_player)) {
        var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

        // If not enough auxiliaries and respawn enabled and cooldown elapsed, respawn them first
        if (auxiliaries_alive < 2 && enable_auxiliary_respawn && auxiliary_respawn_cooldown_timer <= 0) {
            chain_boss_respawn_auxiliaries();
            auxiliary_respawn_cooldown_timer = auxiliary_respawn_cooldown;
        }

        // Check if player is in spin range and boss has at least 2 living auxiliaries
        if (_dist_to_player <= spin_range_max && auxiliaries_alive >= 2) {
            // Start spin attack
            spin_state = "winding_up";
            spin_windup_timer = spin_windup_time;
            spin_current_angle = 0;

            // Play spin start sound
            if (audio_exists(spin_sound_start)) {
                play_sfx(spin_sound_start, 1, 8, false);
            }

            show_debug_message("Chain Boss initiating spin attack!");
        }
    }
}

// Handle spin windup
if (spin_state == "winding_up") {
    spin_windup_timer--;

    if (spin_windup_timer <= 0) {
        // Start spinning
        spin_state = "spinning";
        spin_duration_timer = spin_duration;

        // Set all living auxiliaries to spinning state
        for (var i = 0; i < array_length(auxiliaries); i++) {
            var _aux = auxiliaries[i];
            if (instance_exists(_aux) &&
                _aux.throw_state == "idle" &&
                _aux.state != EnemyState.dead) {
                _aux.spin_state = "spinning";

                // Save original collision damage state and enable during spin
                _aux.original_collision_damage_enabled = _aux.collision_damage_enabled;
                _aux.collision_damage_enabled = true;
                _aux.collision_damage_amount = spin_damage;
                _aux.collision_damage_type = spin_damage_type;
            }
        }

        // Play spinning sound (looping)
        if (audio_exists(spin_sound_spinning)) {
            play_sfx(spin_sound_spinning, 0.8, 8, true); // volume, priority, loop
        }

        show_debug_message("Spin attack started! Duration: " + string(spin_duration) + " frames");
    }
}

// Handle active spin
if (spin_state == "spinning") {
    spin_duration_timer--;

    // Rotate all spinning auxiliaries
    spin_current_angle += spin_rotation_speed;
    if (spin_current_angle >= 360) {
        spin_current_angle -= 360;
    }

    // Position auxiliaries in orbit at max chain length
    var _spinning_count = 0;
    for (var i = 0; i < array_length(auxiliaries); i++) {
        var _aux = auxiliaries[i];
        if (instance_exists(_aux) && _aux.spin_state == "spinning") {
            _spinning_count++;
        }
    }

    // Calculate angle spacing
    var _angle_step = 360 / max(1, _spinning_count);
    var _current_index = 0;

    for (var i = 0; i < array_length(auxiliaries); i++) {
        var _aux = auxiliaries[i];
        if (instance_exists(_aux) && _aux.spin_state == "spinning") {
            // Calculate orbital position
            var _orbit_angle = spin_current_angle + (_current_index * _angle_step);
            _aux.x = x + lengthdir_x(chain_max_length, _orbit_angle);
            _aux.y = y + lengthdir_y(chain_max_length, _orbit_angle);
            _aux.spin_orbit_angle = _orbit_angle;

            _current_index++;
        }
    }

    // Check if spin duration finished
    if (spin_duration_timer <= 0) {
        // End spin
        spin_state = "none";
        spin_cooldown_timer = spin_cooldown;

        // Stop spinning sound
        if (audio_exists(spin_sound_spinning)) {
            stop_looped_sfx(spin_sound_spinning);
        }

        // Play spin end sound
        if (audio_exists(spin_sound_end)) {
            play_sfx(spin_sound_end, 1, 8, false);
        }

        // Reset all auxiliaries to idle
        for (var i = 0; i < array_length(auxiliaries); i++) {
            var _aux = auxiliaries[i];
            if (instance_exists(_aux) && _aux.spin_state == "spinning") {
                _aux.spin_state = "idle";
                _aux.collision_damage_enabled = _aux.original_collision_damage_enabled;
            }
        }

        show_debug_message("Spin attack complete! Cooldown started.");
    }
}
