function player_attacking(){
    // Attack state is handled by animation system
    // The state automatically returns to idle when animation completes
    // This function now only handles attack input detection from other states
}

function player_state_attacking() {
    // In attack state - wait for animation to complete
    // The animation system will reset state to idle when attack animation finishes
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
        state = PlayerState.attacking;

        var attack = instance_create_layer(x, y, "Instances", obj_attack);
        attack.creator = self;

        // Calculate cooldown based on weapon attack speed
        var _attack_speed = 1.0; // Default unarmed speed
        if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
            _attack_speed = equipped.right_hand.definition.stats.attack_speed;
        }

        // Set cooldown: slower weapons have longer recovery
        attack_cooldown = max(15, round(60 / _attack_speed));
        can_attack = false;

        // Play attack sound based on weapon type
        if (equipped.right_hand != undefined) {
            // Different sounds for different weapon types
            switch(equipped.right_hand.definition.handedness) {
                case WeaponHandedness.two_handed:
                    audio_play_sound(snd_attack_sword, 1, false);
                    break;
                default:
                    audio_play_sound(snd_attack_sword, 1, false);
                    break;
            }
        } else {
            // Unarmed attack sound (could be a different sound)
            audio_play_sound(snd_attack_sword, 1, false);
        }
    }
}