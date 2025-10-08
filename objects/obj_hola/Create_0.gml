// Hola Create Event
// Inherits from obj_companion_parent

// Call parent create event
event_inherited();

// Hola-specific identity
companion_id = "hola";
companion_name = "Hola";

// Set sprite
sprite_index = spr_companion_hola;
image_speed = 0; // Disable automatic animation
image_index = 0; // Start at first frame

// Default trigger sound for Hola
sfx_trigger_sound = snd_dash;

// Hola-specific auras (Wind control + battlefield management)
auras = {
    slowing: {
        active: false, // Activated on recruitment
        slow_percent: 0.50, // trying 50 15% enemy slow
        radius: 120 // Pixels around player
    },
    wind_ward: {
        active: false, // Activated on recruitment
        ranged_damage_reduction: 3 // Strong resistance to ranged damage
    },
    wind_deflection: {
        active: false, // Activated on recruitment
        deflect_chance: 0.25, // 25% chance to deflect projectiles
        radius: 64
    },
    slipstream: {
        active: false, // Activated on recruitment
        dash_cd_reduction: 0.20 // 20% dash cooldown reduction
    }
};

// Hola-specific triggers
triggers = {
    gust: {
        unlocked: true,  // Available from start
        active: false,
        cooldown: 0,
        cooldown_max: 960, // doubled to ~16 seconds
        knockback_distance: 36, // Pixels to push enemies
        slow_percent: 0.30, // 30% slow
        slow_duration: 180, // 3 seconds
        trigger_distance: 40, // Activate when enemies within this distance
        enemy_threshold: 2, // Need 2+ nearby enemies
        sfx_trigger_sound: snd_hola_gust
    },
    slipstream_boost: {
        unlocked: false, // Unlocks at affinity 8+
        active: false,
        cooldown: 0,
        cooldown_max: 120, // doubled to ~2 seconds
        dash_cd_boost: 0.35, // 35% temp boost to dash CD recovery
        duration: 120, // 2 seconds
        sfx_trigger_sound: noone
    },
    maelstrom: {
        unlocked: false, // Unlocks at affinity 10
        active: false,
        cooldown: 0,
        cooldown_max: 3600, // doubled to ~60 seconds
        knockback_distance: 40, // Heavy knockback
        slow_percent: 0.50, // 50% heavy slow
        slow_duration: 240, // 4 seconds
        deflect_bonus: 0.25, // +25% deflection chance
        deflect_duration: 240, // 4 seconds
        radius: 96, // Large AoE
        enemy_threshold: 4, // Need 4+ nearby enemies
        sfx_trigger_sound: noone
    }
};

// Animation data inherited from obj_companion_parent
// All companions use the same 26-frame structure

// VN system
vn_sprite = spr_hola_vn_startled; // Portrait sprite for VN dialogue
// theme_song = snd_hola_theme; // Theme music for VN dialogue

// VN intro on first sight
has_vn_intro = true;
vn_intro_id = "hola_intro";
vn_intro_yarn_file = "hola_intro.yarn";
vn_intro_node = "Start";
vn_intro_character_name = "";  // No speaker name (just narration)
vn_intro_portrait_sprite = noone;  // No portrait for simple narration
vn_intro_sfx = snd_vn_intro_discovered;  // Sound to play when intro triggers

show_debug_message("=== HOLA CREATE EVENT ===");
show_debug_message("Gust trigger initialized: active=" + string(triggers.gust.active) + " cooldown=" + string(triggers.gust.cooldown));
