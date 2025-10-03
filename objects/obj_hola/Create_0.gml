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

// Hola-specific auras (Wind control + battlefield management)
auras = {
    slowing: {
        active: false, // Activated on recruitment
        slow_percent: 0.15, // 15% enemy slow
        radius: 80 // Pixels around player
    },
    wind_ward: {
        active: false, // Activated on recruitment
        projectile_dr: 3 // Strong resistance to ranged damage
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
        cooldown_max: 480, // 8 seconds
        knockback_distance: 24, // Pixels to push enemies
        slow_percent: 0.30, // 30% slow
        slow_duration: 180, // 3 seconds
        trigger_distance: 40, // Activate when enemies within this distance
        enemy_threshold: 2 // Need 2+ nearby enemies
    },
    slipstream_boost: {
        unlocked: false, // Unlocks at affinity 8+
        active: false,
        cooldown: 0,
        cooldown_max: 60, // 1 second
        dash_cd_boost: 0.35, // 35% temp boost to dash CD recovery
        duration: 120 // 2 seconds
    },
    maelstrom: {
        unlocked: false, // Unlocks at affinity 10
        active: false,
        cooldown: 0,
        cooldown_max: 1800, // 30 seconds
        knockback_distance: 40, // Heavy knockback
        slow_percent: 0.50, // 50% heavy slow
        slow_duration: 240, // 4 seconds
        deflect_bonus: 0.25, // +25% deflection chance
        deflect_duration: 240, // 4 seconds
        radius: 96, // Large AoE
        enemy_threshold: 4 // Need 4+ nearby enemies
    }
};

// Animation data inherited from obj_companion_parent
// All companions use the same 26-frame structure

// VN system
vn_sprite = spr_hola_vn_startled; // Portrait sprite for VN dialogue

show_debug_message("=== HOLA CREATE EVENT ===");
show_debug_message("Gust trigger initialized: active=" + string(triggers.gust.active) + " cooldown=" + string(triggers.gust.cooldown));
