/// @function spawn_hazard_and_destroy
/// @description Spawns explosion (if enabled), then hazard, then destroys projectile
/// Applies range profile damage multiplier to explosion and hazard damage
function spawn_hazard_and_destroy() {
    hazard_spawned = true;

    // Spawn explosion first (if enabled)
    if (explosion_enabled && object_exists(explosion_object)) {
        var _explosion = instance_create_depth(x, y, depth - 1, explosion_object);

        if (instance_exists(_explosion)) {
            // Pass damage configuration to explosion with range multiplier applied
            _explosion.damage_amount = explosion_damage * current_damage_multiplier;
            _explosion.damage_type = explosion_damage_type;
            _explosion.creator = creator;
        }
    }

    // Spawn the hazard object at current position (use depth instead of layer)
    if (object_exists(hazard_object)) {
        var _hazard = instance_create_depth(x, y, depth, hazard_object);

        // Pass creator information to hazard for damage attribution
        if (instance_exists(_hazard) && variable_instance_exists(_hazard, "creator")) {
            _hazard.creator = creator;
        }

        // Optional: Pass damage type to hazard if it supports it
        if (instance_exists(_hazard) && variable_instance_exists(_hazard, "damage_type")) {
            _hazard.damage_type = damage_type;
        }

        // Pass damage multiplier to hazard so it can scale continuous damage
        if (instance_exists(_hazard) && variable_instance_exists(_hazard, "damage_amount")) {
            _hazard.damage_amount = _hazard.damage_amount * current_damage_multiplier;
        }

        // Pass lifetime to hazard if configured
        if (instance_exists(_hazard) && hazard_lifetime > 0) {
            // Set alarm to destroy hazard after lifetime (convert seconds to frames)
            _hazard.alarm[0] = hazard_lifetime * 60;  // 60 fps
        }
    }

    // Play landing sound effect (optional - can be customized)
    if (audio_exists(snd_bump)) {
        play_sfx(snd_bump, 0.8, false);
    }

    // Destroy target indicator now that hazard is spawned
    if (instance_exists(creator) && variable_instance_exists(creator, "target_indicator")) {
        if (instance_exists(creator.target_indicator)) {
            instance_destroy(creator.target_indicator);
            creator.target_indicator = noone;
        }
    }

    // Destroy the projectile
    instance_destroy();
}