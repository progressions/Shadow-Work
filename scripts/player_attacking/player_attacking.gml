function player_attacking(){
// Update attack cooldown
if (attack_cooldown > 0) {
    attack_cooldown--;
    can_attack = false;
} else {
    can_attack = true;
}

// Handle attack input
if (keyboard_check_pressed(ord("J")) && can_attack) {
    state = PlayerState.attacking;

    // Calculate attack position based on facing direction
    var attack_x = x;
    var attack_y = y;

    if (facing_dir == "up") {
        attack_y = y - 16;
    }

    var attack = instance_create_layer(attack_x, attack_y, "Instances", obj_attack);
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