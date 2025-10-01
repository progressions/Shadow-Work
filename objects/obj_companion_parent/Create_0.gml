// Companion Parent Create Event
// Base object for all companion NPCs

// Get tilemap for collision detection
tilemap = layer_tilemap_get_id("Tiles_Col");

// Identity
companion_id = "undefined"; // Override in child objects
companion_name = "Companion"; // Override in child objects

// Recruitment & State
is_recruited = false;
state = CompanionState.not_recruited;

// Following behavior
follow_target = noone;
follow_distance = 28; // Pixels to maintain from player
follow_speed = 1.15; // Slightly slower than player base speed
min_follow_distance = 16; // Don't get closer than this

// Affinity system (1.0 to 10.0)
affinity = 1.0;
affinity_max = 10.0;

// Quest flags for future story expansion
quest_flags = {
    met_player: false,
    first_conversation: false,
    romantic_quest_unlocked: false,
    romantic_quest_complete: false,
    adventure_quest_active: false,
    adventure_quest_complete: false
};

// Dialogue state
dialogue_history = [];
relationship_stage = 0; // 0=stranger, 1=acquaintance, 2=friend, 3=close, 4=romance

// Auras (passive bonuses) - override in child objects
auras = {
    protective: { active: false, dr_bonus: 0 },
    regeneration: { active: false, hp_per_tick: 0, tick_interval: 180 }
};

// Triggers (active abilities) - override in child objects
triggers = {
    shield: {
        unlocked: true,  // Unlocked at affinity 0+
        active: false,
        cooldown: 0,
        cooldown_max: 600, // 10 seconds at 60fps
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
        cooldown_max: 300,
        dr_bonus: 2,
        duration: 120,
        heal_amount: 2
    },
    guardian_veil: {
        unlocked: false, // Unlocks at affinity 10
        active: false,
        cooldown: 0,
        cooldown_max: 2400, // 40 seconds
        duration: 90,
        dr_bonus: 5,
        enemy_threshold: 3
    }
};

// Animation variables
image_speed = 0;
image_index = 0;
anim_timer = 0;
anim_speed = 0.15;
last_dir_index = 0; // 0=down, 1=right, 2=left, 3=up

// Movement tracking
move_dir_x = 0;
move_dir_y = 0;
target_x = x;
target_y = y;

// Persistent across room changes
persistent = true;
