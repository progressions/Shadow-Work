persistent = true;

// Initialize audio configuration
global.audio_config = {
    music_enabled: true,
    sfx_enabled: true,
	music_volume: 1,
	sfx_volume: 1,
	master_volume: 1
};

// Initialize terrain tile mapping using ranges
// Define terrain ranges per layer: [start_index, end_index, "terrain_name"]
// NOTE: Tiles_Forest is mostly empty (grass background). Only define special tiles.
global.terrain_tile_map = {};

// Only define non-grass tiles on Tiles_Forest (if any exist)
// If you have special forest tiles like rocks, trees, etc., add them here
// Example: [10, 15, "forest_floor"] if you have those tiles
global.terrain_tile_map[$ "Tiles_Forest"] = [
    // Add special tiles here if you have any on this layer
    // Otherwise leave empty - index 0 (empty) will default to "grass"
];

// Any non-zero tile on path layer = path
global.terrain_tile_map[$ "Tiles_Path"] = [
    [1, 999, "path"], // Any path tile = path terrain
];

// Any non-zero tile on water layers = water
global.terrain_tile_map[$ "Tiles_Water"] = [
    [1, 999, "water"],
];

global.terrain_tile_map[$ "Tiles_Water_Moving"] = [
    [1, 999, "water"],
];

// Any non-zero tile on lava layer = lava
global.terrain_tile_map[$ "Tiles_Lava"] = [
    [1, 999, "lava"],
];

// Initialize terrain footstep sound mapping
global.terrain_footstep_sounds = {
    grass: snd_footsteps_grass,
    path: snd_footsteps_path,
    // Add more terrain sounds as needed:
    // water: snd_footsteps_water,
    // stone: snd_footsteps_stone,
};

// Initialize tag database (tags grant permanent trait bundles)
global.tag_database = {
    fireborne: {
        name: "Fireborne",
        description: "Born of flame",
        grants_traits: ["fire_immunity", "ice_vulnerability"]
    },

    venomous: {
        name: "Venomous",
        description: "Deadly poison wielder",
        grants_traits: ["poison_immunity", "deals_poison_damage"]
    },

    arboreal: {
        name: "Arboreal",
        description: "Tree-dwelling creature",
        grants_traits: ["fire_vulnerability", "poison_resistance"]
    },

    aquatic: {
        name: "Aquatic",
        description: "Water-born creature",
        grants_traits: ["lightning_vulnerability", "fire_resistance"]
    },

    glacial: {
        name: "Glacial",
        description: "From frozen lands",
        grants_traits: ["ice_immunity", "fire_vulnerability"]
    },

    swampridden: {
        name: "Swampridden",
        description: "Murky swamp dweller",
        grants_traits: ["poison_immunity", "disease_resistance"]
    },

    sandcrawler: {
        name: "Sandcrawler",
        description: "Desert wanderer",
        grants_traits: ["fire_resistance", "heat_adapted"]
    }
};

// Initialize terrain effects map (depends on trait_database)
init_terrain_effects();


// ============================================
// SETUP - In your initialization object
// ============================================
global.idle_bob_timer = 0;  // Global timer that everyone uses

// Initialize companion system
init_companion_global_data();

// Environmental debris particle system (leaves/wood chunks)
if (!variable_global_exists("debris_system")) {
    global.debris_system = part_system_create();
    part_system_depth(global.debris_system, -100);
    part_system_automatic_update(global.debris_system, true);
    part_system_automatic_draw(global.debris_system, true);

    global.part_leaf = part_type_create();
    part_type_sprite(global.part_leaf, spr_leaves, true, true, false);
    part_type_size(global.part_leaf, 1, 1, 0, 0);
    part_type_speed(global.part_leaf, 1, 3, -0.05, 0);
    part_type_direction(global.part_leaf, 0, 360, 0, 0);
    part_type_gravity(global.part_leaf, 0.15, 270);
    part_type_orientation(global.part_leaf, 0, 360, 2, 0, 0);
    part_type_life(global.part_leaf, 40, 80);
    part_type_alpha2(global.part_leaf, 1, 0);

    global.part_wood = undefined;
    if (asset_get_index("spr_planks") != -1) {
        global.part_wood = part_type_create();
        part_type_sprite(global.part_wood, spr_planks, true, true, false);
        part_type_size(global.part_wood, 1, 1, 0, 0);
        part_type_speed(global.part_wood, 2, 4, -0.1, 0);
        part_type_direction(global.part_wood, 0, 360, 0, 0);
        part_type_gravity(global.part_wood, 0.2, 270);
        part_type_life(global.part_wood, 30, 60);
        part_type_alpha2(global.part_wood, 1, 0);
    }
}

// Initialize VN system state
global.vn_active = false;           // Is VN mode currently active?
global.vn_chatterbox = undefined;   // Current Chatterbox instance
global.vn_companion = undefined;    // Reference to companion being talked to
global.vn_yarn_file = "";           // Current yarn file being used
global.game_paused = false;         // General pause flag for gameplay
global.vn_torch_transfer_success = false;

// Initialize VN intro system
global.vn_intro_seen = {};          // Track which intro IDs have been seen (for persistence)
global.vn_intro_instance = undefined; // Reference to instance triggering current intro (non-companion)
global.debug_vn_intro = false;      // F3 to toggle debug overlay
global.vn_intro_startup_delay = 60; // Wait 1 second before checking intros (let camera settle on player)

// Initialize camera pan state
global.camera_pan_state = {
	active: false,
	start_x: 0,
	start_y: 0,
	target_x: 0,
	target_y: 0,
	timer: 0,
	duration: 30,  // Default 30 frames (0.5 seconds at 60fps)
	hold_duration: 0,  // Frames to hold at target before callback
	hold_timer: 0,     // Current hold timer
	on_complete: undefined  // Optional callback function/method to call when pan completes
};

// VN torch variables and identifiers
ChatterboxVariableDefault("torch_carrier", "none");
ChatterboxVariableDefault("vn_torch_transfer_success", false);
set_torch_carrier("none");
if (variable_global_exists("ChatterboxVariableSetConstant")) {
    ChatterboxVariableSetConstant("player_id", "player");
    ChatterboxVariableSetConstant("canopy_id", "canopy");
    ChatterboxVariableSetConstant("hola_id", "hola");
    ChatterboxVariableSetConstant("yorna_id", "yorna");
}

if (variable_global_exists("ChatterboxVariableSet")) {
    ChatterboxVariableSet("vn_torch_transfer_success", false);
}
global.vn_torch_transfer_success = false;

// Register custom Chatterbox functions
ChatterboxAddFunction("bg", background_set_index);
ChatterboxAddFunction("quest_accept", quest_accept);
ChatterboxAddFunction("quest_is_active", quest_is_active);
ChatterboxAddFunction("quest_is_complete", quest_is_complete);
ChatterboxAddFunction("quest_can_accept", quest_can_accept);
ChatterboxAddFunction("companion_take_torch", companion_take_torch_function);
ChatterboxAddFunction("companion_stop_carrying_torch", companion_stop_carrying_torch_function);

// Declare Chatterbox variables for companions
ChatterboxVariableDefault("canopy_recruited", false);
ChatterboxVariableDefault("hola_thanked_for_yorna", false);

// Initialize quest system
global.quest_flags = {};      // Boolean quest flags (struct instead of ds_map for JSON compatibility)
global.quest_counters = {};   // Numeric quest counters
init_quest_database();        // Initialize quest database with quest definitions

// Initialize room state persistence system
global.room_states = {};      // Struct keyed by room name/index - stores state of each visited room
global.visited_rooms = [];    // Array of visited room indices

// Initialize world state tracking
global.opened_chests = [];    // Array of opened chest IDs
global.broken_breakables = []; // Array of broken breakable IDs
global.picked_up_items = [];  // Array of picked-up item spawn IDs

// Pathfinding debug visualization
global.debug_pathfinding = false; // Set to false for production

// Enemy approach variation debug visualization
global.debug_enemy_approach = false; // Set to false for production

// Debug mode for damage reduction display
global.debug_mode = false;

// Initialize formation database for party controller system
global.formation_database = {
    line_3: {
        max_members: 3,
        roles: ["frontline", "frontline", "frontline"],
        offsets: [
            {x: 0, y: 0},      // Leader/center
            {x: -48, y: 0},    // Left
            {x: 48, y: 0}      // Right
        ]
    },

    wedge_5: {
        max_members: 5,
        roles: ["frontline", "frontline", "frontline", "backline", "backline"],
        offsets: [
            {x: 0, y: 0},      // Point
            {x: -32, y: 32},   // Left front
            {x: 32, y: 32},    // Right front
            {x: -48, y: 64},   // Left back
            {x: 48, y: 64}     // Right back
        ]
    },

    circle_4: {
        max_members: 4,
        roles: ["defender", "defender", "defender", "defender"],
        offsets: [
            {x: 0, y: -48},    // North
            {x: 48, y: 0},     // East
            {x: 0, y: 48},     // South
            {x: -48, y: 0}     // West
        ]
    },

    protective_3: {
        max_members: 3,
        roles: ["frontline", "backline", "backline"],
        offsets: [
            {x: 0, y: 0},      // Tank front
            {x: -32, y: 48},   // Ranged left
            {x: 32, y: 48}     // Ranged right
        ]
    }
};

// Initialize interaction manager (singleton pattern)
if (!instance_exists(obj_interaction_manager)) {
    instance_create_depth(0, 0, -9999, obj_interaction_manager);
}

// Loot system debug testing
global.debug_loot_system = false; // Set to true to test weighted selection

// Initialize sound variant randomization system
global.sound_variant_lookup = {};
global.debug_sound_variants = false;

// Scan all sound assets and detect variants (sounds ending in _1, _2, _3, etc.)
var _all_sounds = []; // We'll build this by iterating through audio resources

// GameMaker doesn't have a built-in way to iterate all sounds, so we'll check known sounds
// This will be populated dynamically by checking asset_get_index for common patterns
// For now, we'll scan specific sound prefixes we know exist in the game

// Known sound prefixes to check (add more as needed)
var _sound_prefixes = [
    "snd_party_aggressive",
    "snd_party_cautious",
    "snd_party_desperate",
    "snd_party_retreating",
    "snd_party_patrolling",
    "snd_party_protecting",
    "snd_canopy_shield",
    "snd_hit",
    "snd_player_hit",
    "snd_orc_hit",
    "snd_footsteps_grass",
    "snd_footsteps_path"
];

// For each prefix, check if variants exist
for (var i = 0; i < array_length(_sound_prefixes); i++) {
    var _base_name = _sound_prefixes[i];
    var _variant_count = 0;

    // Check for _1, _2, _3, etc.
    var _variant_num = 1;
    while (true) {
        var _variant_name = _base_name + "_" + string(_variant_num);
        var _sound_index = asset_get_index(_variant_name);

        if (_sound_index == -1) {
            // Variant doesn't exist, stop counting
            break;
        } else {
            _variant_count++;
            _variant_num++;
        }
    }

    // Store the count (0 if no variants, otherwise number of variants)
    global.sound_variant_lookup[$ _base_name] = _variant_count;

    // Debug logging
    if (global.debug_sound_variants && _variant_count > 0) {
        show_debug_message("Sound variants detected: " + _base_name + " has " + string(_variant_count) + " variants");
    }
}

// Test loot system weighted selection (debug mode)
if (global.debug_loot_system) {
    show_debug_message("=== LOOT SYSTEM TEST ===");

    // Test equal weights
    var test_table_equal = [
        {item_key: "small_health_potion"},
        {item_key: "rusty_dagger"},
        {item_key: "arrows"}
    ];

    show_debug_message("Testing equal weights (100 rolls):");
    var results_equal = {};
    for (var i = 0; i < 100; i++) {
        var item = select_weighted_loot_item(test_table_equal);
        results_equal[$ item] = (results_equal[$ item] ?? 0) + 1;
    }
    show_debug_message("small_health_potion: " + string(results_equal[$ "small_health_potion"] ?? 0) + "%");
    show_debug_message("rusty_dagger: " + string(results_equal[$ "rusty_dagger"] ?? 0) + "%");
    show_debug_message("arrows: " + string(results_equal[$ "arrows"] ?? 0) + "%");

    // Test weighted selection
    var test_table_weighted = [
        {item_key: "small_health_potion", weight: 5},
        {item_key: "rusty_dagger", weight: 2},
        {item_key: "greatsword", weight: 1}
    ];

    show_debug_message("Testing weighted selection (100 rolls, weights 5:2:1):");
    var results_weighted = {};
    for (var i = 0; i < 100; i++) {
        var item = select_weighted_loot_item(test_table_weighted);
        results_weighted[$ item] = (results_weighted[$ item] ?? 0) + 1;
    }
    show_debug_message("small_health_potion (weight 5): " + string(results_weighted[$ "small_health_potion"] ?? 0) + "%");
    show_debug_message("rusty_dagger (weight 2): " + string(results_weighted[$ "rusty_dagger"] ?? 0) + "%");
    show_debug_message("greatsword (weight 1): " + string(results_weighted[$ "greatsword"] ?? 0) + "%");
    show_debug_message("=== END LOOT TEST ===");
}

// Initialize freeze frame system
freeze_timer = 0;        // Countdown timer for freeze duration
freeze_active = false;   // Is freeze currently active?

// Initialize screen shake system
shake_intensity = 0;     // Current shake magnitude in pixels
shake_timer = 0;         // Countdown timer for shake duration
shake_decay = 0.8;       // How fast shake intensity decays (0-1, higher = faster decay)

// Initialize slow-motion system
slowmo_active = false;   // Is slow-mo currently active?
slowmo_timer = 0;        // Countdown timer for slow-mo duration (frames at 60fps)
slowmo_recovery_timer = 0; // Timer for smooth speed-up back to normal
slowmo_target_speed = 60;  // Target game speed (60 = normal)
slowmo_current_speed = 60; // Current interpolated speed
slowmo_cooldown_timer = 0;   // Frames remaining until slow-mo can trigger again
slowmo_cooldown_duration = 180; // 3 seconds at 60fps
