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
        hp_per_tick: 0.5, // Slow but constant healing
        tick_interval: 60 // Every 1 second at 60fps
    }
};

// Canopy-specific triggers
triggers = {
    shield: {
        unlocked: true,  // Available from start
        active: false,
        cooldown: 0,
        cooldown_max: 180, // 3 seconds
        dr_bonus: 5,
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

// Animation data inherited from obj_companion_parent
// All companions use the same 26-frame structure

// VN system
vn_sprite = spr_vn_canopy_1; // Portrait sprite for VN dialogue

show_debug_message("=== CANOPY CREATE EVENT ===");
show_debug_message("Shield trigger initialized: active=" + string(triggers.shield.active) + " cooldown=" + string(triggers.shield.cooldown));
