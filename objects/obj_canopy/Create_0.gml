// Canopy Create Event
// Inherits from obj_companion_parent

// Call parent create event
event_inherited();

// Canopy-specific identity
companion_id = "canopy";
companion_name = "Canopy";

// Set sprite
sprite_index = spr_canopy;
image_speed = 0; // Disable automatic animation
image_index = 0; // Start at first frame

// Canopy-specific auras (Protective + Regeneration)
auras = {
    protective: {
        active: false, // Activated on recruitment
        dr_bonus: 1
    },
    regeneration: {
        active: false, // Activated on recruitment
        hp_per_tick: 0.1, // Slow but constant healing
        tick_interval: 60 // Every 1 second at 60fps
    }
};

// Canopy-specific triggers
triggers = {
    shield: {
        unlocked: true,  // Available from start
        active: false,
        cooldown: 0,
        cooldown_max: 600, // 10 seconds
        dr_bonus: 3,
        duration: 180, // 3 seconds
        hp_threshold: 0.3 // Activate at 30% HP
    },
    dash_mend: {
        unlocked: false, // Unlocks at affinity 5+
        active: false,
        cooldown: 0,
        cooldown_max: 60,
        heal_amount: 1
    },
    aegis: {
        unlocked: false, // Unlocks at affinity 8+
        active: false,
        cooldown: 0,
        cooldown_max: 300, // 5 seconds
        dr_bonus: 2,
        duration: 120, // 2 seconds
        heal_amount: 2
    },
    guardian_veil: {
        unlocked: false, // Unlocks at affinity 10
        active: false,
        cooldown: 0,
        cooldown_max: 2400, // 40 seconds
        duration: 90, // 1.5 seconds
        dr_bonus: 5,
        enemy_threshold: 3 // Need 3+ nearby enemies
    }
};

// Animation data for Canopy (26 frames total)
anim_data = {
    // Idle animations (2 frames each)
    idle_down: { start: 0, length: 2 },
    idle_right: { start: 2, length: 2 },
    idle_left: { start: 4, length: 2 },
    idle_up: { start: 6, length: 2 },

    // Walk animations (6 frames each)
    walk_down: { start: 8, length: 6 },
    walk_right: { start: 14, length: 6 },
    walk_left: { start: 20, length: 6 }
    // Note: Only 26 frames total, no walk_up animation in sprite
};

// Canopy starts at a fixed position until recruited
// Position will be set in room editor
