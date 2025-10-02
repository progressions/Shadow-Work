function player_attacking(){
    // Attack state is handled by animation system
    // The state automatically returns to idle when animation completes
    // This function now only handles attack input detection from other states
}

function player_state_attacking() {
    // Stop all footstep sounds when attacking
    stop_all_footstep_sounds();

    // In attack state - wait for animation to complete
    // The animation system will reset state to idle when attack animation finishes

    // Handle knockback
    player_handle_knockback();
}

function player_handle_attack_input() {
    // Update attack cooldown
    if (attack_cooldown > 0) {
        attack_cooldown--;
        can_attack = false;
    } else {
        can_attack = true;
    }

    // Handle attack input - can be triggered from any state
    if (keyboard_check_pressed(ord("J")) && can_attack) {
        var _is_ranged = false;
        var _attack_speed = 1.0; // Default unarmed speed

        // Check if equipped weapon is ranged
        if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
            _attack_speed = equipped.right_hand.definition.stats.attack_speed;

            show_debug_message("Weapon: " + equipped.right_hand.definition.item_id);
            show_debug_message("Stats: " + json_stringify(equipped.right_hand.definition.stats));

            if (equipped.right_hand.definition.stats[$ "requires_ammo"] != undefined) {
                _is_ranged = true;
                show_debug_message("Detected ranged weapon! Ammo type: " + equipped.right_hand.definition.stats.requires_ammo);
            }
        }

        show_debug_message("Is ranged: " + string(_is_ranged));

        if (_is_ranged) {
            // Ranged attack logic
            var _has_arrows = has_ammo("arrows");
            show_debug_message("Has arrows: " + string(_has_arrows));

            if (_has_arrows) {
                show_debug_message("Spawning arrow!");
                state = PlayerState.attacking;

                // Calculate spawn position based on facing direction
                var _arrow_x = x;
                var _arrow_y = y;

                switch (facing_dir) {
                    case "right":
                        _arrow_x += 16;
                        _arrow_y += 8;
                        break;
                    case "up":
					    _arrow_x += 16;
                        _arrow_y -= 16;
                        break;
                    case "left":
                        _arrow_x -= 16;
                        _arrow_y -= 20;
                        break;
                    case "down":
						_arrow_x -= 16;
                        _arrow_y += 8;
                        break;
                }

                var _arrow = instance_create_layer(_arrow_x, _arrow_y, "Instances", obj_arrow);
                _arrow.creator = self;
                _arrow.damage = get_total_damage();

                // Set direction based on facing_dir
                switch (facing_dir) {
                    case "right": _arrow.direction = 0; break;
                    case "up": _arrow.direction = 90; break;
                    case "left": _arrow.direction = 180; break;
                    case "down": _arrow.direction = 270; break;
                }
                _arrow.image_angle = _arrow.direction;

                consume_ammo("arrows", 1);

                // Play bow firing sound
                play_sfx(snd_bow_attack, 1, false);

                // Calculate cooldown
                attack_cooldown = max(15, round(60 / _attack_speed));
                can_attack = false;
            } else {
                show_debug_message("No arrows available!");
            }
        } else {
            // Melee attack logic (existing behavior)
            state = PlayerState.attacking;

            var attack = instance_create_layer(x, y, "Instances", obj_attack);
            attack.creator = self;

            // Set cooldown: slower weapons have longer recovery
            attack_cooldown = max(15, round(60 / _attack_speed));
            can_attack = false;

            // Play attack sound based on weapon type
            if (equipped.right_hand != undefined) {
                // Different sounds for different weapon types
                switch(equipped.right_hand.definition.handedness) {
                    case WeaponHandedness.two_handed:
                        play_sfx(snd_attack_sword, 1, false);
                        break;
                    default:
                        play_sfx(snd_attack_sword, 1, false);
                        break;
                }
            } else {
                // Unarmed attack sound (could be a different sound)
                play_sfx(snd_attack_sword, 1, false);
            }
        }
    }
}