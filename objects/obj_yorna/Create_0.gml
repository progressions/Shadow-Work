// Yorna Create Event
// Inherits from obj_companion_parent

// Call parent create event
event_inherited();

// Yorna-specific identity
companion_id = "yorna";
companion_name = "Yorna";

// Set sprite
sprite_index = spr_companion_yorna;
image_speed = 0; // Disable automatic animation
image_index = 0; // Start at first frame

// Yorna-specific auras (Offensive power + aggression)
auras = {
    warriors_presence: {
        active: false, // Activated on recruitment
        attack_bonus: 1, // +1 attack damage
        range_bonus: 8 // +8px attack range
    }
};

// Yorna-specific triggers
triggers = {
    on_hit_strike: {
        unlocked: true,  // Available from start
        active: true, // Always checking for player hits
        cooldown: 0,
        cooldown_max: 30, // 0.5 seconds between procs
        bonus_damage: 2 // Bonus damage added per hit
    },
    expose_weakness: {
        unlocked: false, // Unlocks at affinity 8+
        active: false,
        cooldown: 0,
        cooldown_max: 300, // 5 seconds
        armor_reduction: 2, // -2 armor to nearby enemies
        duration: 180, // 3 seconds
        radius: 64
    },
    execution_window: {
        unlocked: false, // Unlocks at affinity 10
        active: false,
        cooldown: 0,
        cooldown_max: 600, // 10 seconds
        damage_multiplier: 2.0, // 2x damage during window
        armor_pierce: 3, // Ignore 3 armor
        duration: 120, // 2 seconds
        true_damage: true
    }
};

// Animation data inherited from obj_companion_parent
// All companions use the same 26-frame structure

// VN system
vn_sprite = spr_yorna_vn_intro; // Portrait sprite for VN dialogue
theme_song = snd_yorna_theme; // Theme music for VN dialogue

// VN intro on first sight
has_vn_intro = true;
vn_intro_id = "yorna_intro";
vn_intro_yarn_file = "yorna_intro.yarn";
vn_intro_node = "Start";
vn_intro_character_name = "";  // No speaker name (just narration)
vn_intro_portrait_sprite = noone;  // No portrait for simple narration
vn_intro_sfx = snd_vn_intro_discovered;  // Sound to play when intro triggers

show_debug_message("=== YORNA CREATE EVENT ===");
show_debug_message("On-Hit Strike trigger initialized: active=" + string(triggers.on_hit_strike.active) + " cooldown=" + string(triggers.on_hit_strike.cooldown));
