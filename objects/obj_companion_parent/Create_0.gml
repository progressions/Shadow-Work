// Companion Parent Create Event
// Base object for all companion NPCs

// Call parent create event
event_inherited();

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
last_dir_index = 0; // 0=down, 1=right, 2=left, 3=up
// Animation uses global.idle_bob_timer for synchronized bobbing (set in obj_game_controller)

// Standard companion animation data (same for all companions)
anim_data = {
    // Idle animations (2 frames each)
    idle_down: { start: 0, length: 2 },   // frames 0-1
    idle_right: { start: 2, length: 2 },  // frames 2-3
    idle_left: { start: 4, length: 2 },   // frames 4-5
    idle_up: { start: 6, length: 2 },     // frames 6-7

    // Walk animations
    walk_down: { start: 8, length: 4 },   // frames 8-11 (4 frames)
    walk_right: { start: 12, length: 5 }, // frames 12-16 (5 frames)
    walk_left: { start: 17, length: 5 },  // frames 17-21 (5 frames)
    walk_up: { start: 22, length: 4 }     // frames 22-25 (4 frames)
};

// Movement tracking
move_dir_x = 0;
move_dir_y = 0;
target_x = x;
target_y = y;

// Teleport system - if too far from player for too long, teleport to them
teleport_distance_threshold = 100; // If farther than this
teleport_time_threshold = 90;      // For this many frames (1.5 seconds at 60fps)
time_far_from_player = 0;

// Persistent so companions persist across room changes
persistent = true;
