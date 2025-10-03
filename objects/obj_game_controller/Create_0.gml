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

// Initialize trait database (individual traits with stacking mechanics)
global.trait_database = {
    // Fire traits
    fire_immunity: {
        name: "Fire Immunity",
        damage_modifier: 0.0,
        opposite_trait: "fire_vulnerability",
        max_stacks: 5
    },
    fire_resistance: {
        name: "Fire Resistance",
        damage_modifier: 0.75,
        opposite_trait: "fire_vulnerability",
        max_stacks: 5
    },
    fire_vulnerability: {
        name: "Fire Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "fire_resistance",
        max_stacks: 5
    },

    // Ice traits
    ice_immunity: {
        name: "Ice Immunity",
        damage_modifier: 0.0,
        opposite_trait: "ice_vulnerability",
        max_stacks: 5
    },
    ice_resistance: {
        name: "Ice Resistance",
        damage_modifier: 0.75,
        opposite_trait: "ice_vulnerability",
        max_stacks: 5
    },
    ice_vulnerability: {
        name: "Ice Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "ice_resistance",
        max_stacks: 5
    },

    // Lightning traits
    lightning_immunity: {
        name: "Lightning Immunity",
        damage_modifier: 0.0,
        opposite_trait: "lightning_vulnerability",
        max_stacks: 5
    },
    lightning_resistance: {
        name: "Lightning Resistance",
        damage_modifier: 0.75,
        opposite_trait: "lightning_vulnerability",
        max_stacks: 5
    },
    lightning_vulnerability: {
        name: "Lightning Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "lightning_resistance",
        max_stacks: 5
    },

    // Poison traits
    poison_immunity: {
        name: "Poison Immunity",
        damage_modifier: 0.0,
        opposite_trait: "poison_vulnerability",
        max_stacks: 5
    },
    poison_resistance: {
        name: "Poison Resistance",
        damage_modifier: 0.75,
        opposite_trait: "poison_vulnerability",
        max_stacks: 5
    },
    poison_vulnerability: {
        name: "Poison Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "poison_resistance",
        max_stacks: 5
    },

    // Disease traits
    disease_immunity: {
        name: "Disease Immunity",
        damage_modifier: 0.0,
        opposite_trait: "disease_vulnerability",
        max_stacks: 5
    },
    disease_resistance: {
        name: "Disease Resistance",
        damage_modifier: 0.75,
        opposite_trait: "disease_vulnerability",
        max_stacks: 5
    },

    // Special traits
    deals_poison_damage: {
        name: "Deals Poison Damage",
        effect_type: "damage_type_change",
        max_stacks: 1
    },
    heat_adapted: {
        name: "Heat Adapted",
        effect_type: "environmental",
        max_stacks: 1
    }
};

// Initialize trait database (OLD - will be replaced with new structure)
global.trait_database_old = {
    fireborne: {
        name: "Fireborne",
        description: "Born of flame, immune to fire damage but weak to ice",
        effects: {
            fire_damage_modifier: 0,      // Immune to fire
            ice_damage_modifier: 1.5,     // Takes 50% more ice damage
            burn_immunity: true
        }
    },

    arboreal: {
        name: "Arboreal",
        description: "Tree-dweller, weak to fire and resistant to poison",
        effects: {
            fire_damage_modifier: 1.5,    // Takes 50% more fire damage
            poison_damage_modifier: 0.5   // Takes 50% less poison damage
        }
    },

    aquatic: {
        name: "Aquatic",
        description: "Water-born creature, vulnerable to lightning",
        effects: {
            lightning_damage_modifier: 2.0,    // Takes double lightning damage
            fire_damage_modifier: 0.75,        // Takes 25% less fire damage
            movement_speed_water: 1.5          // 50% faster in water tiles (future)
        }
    },

    glacial: {
        name: "Glacial",
        description: "From frozen lands, immune to ice but weak to fire",
        effects: {
            ice_damage_modifier: 0,          // Immune to ice
            fire_damage_modifier: 2.0,       // Takes double fire damage
            movement_speed_ice: 1.25,        // 25% faster on ice (future)
            freeze_immunity: true
        }
    },

    swampridden: {
        name: "Swampridden",
        description: "Born in murky swamps, resistant to poison and disease",
        effects: {
            poison_damage_modifier: 0,       // Immune to poison
            disease_resistance: 0.75,
            movement_speed_swamp: 1.5        // 50% faster in swamp (future)
        }
    },

    sandcrawler: {
        name: "Sandcrawler",
        description: "Desert wanderer, adapted to heat and sand",
        effects: {
            fire_damage_modifier: 0.5,       // Takes 50% less fire damage
            movement_speed_desert: 1.5,      // 50% faster on desert (future)
            quicksand_immunity: true
        }
    }
};

// ============================================
// SETUP - In your initialization object
// ============================================
global.idle_bob_timer = 0;  // Global timer that everyone uses

// Initialize companion system
init_companion_global_data();

// Initialize VN system state
global.vn_active = false;           // Is VN mode currently active?
global.vn_chatterbox = undefined;   // Current Chatterbox instance
global.vn_companion = undefined;    // Reference to companion being talked to
global.vn_yarn_file = "";           // Current yarn file being used
global.game_paused = false;         // General pause flag for gameplay

// Register custom Chatterbox functions
ChatterboxAddFunction("bg", background_set_index);

// Declare Chatterbox variables for companions
ChatterboxVariableDefault("canopy_recruited", false);

// Initialize quest system
global.quest_flags = {};      // Boolean quest flags (struct instead of ds_map for JSON compatibility)
global.quest_counters = {};   // Numeric quest counters

// Initialize room state persistence system
global.room_states = {};      // Struct keyed by room name/index - stores state of each visited room
global.visited_rooms = [];    // Array of visited room indices

// Initialize world state tracking
global.opened_chests = [];    // Array of opened chest IDs
global.broken_breakables = []; // Array of broken breakable IDs
global.picked_up_items = [];  // Array of picked-up item spawn IDs

// Pathfinding debug visualization
global.debug_pathfinding = false; // Set to false for production

// Loot system debug testing
global.debug_loot_system = false; // Set to true to test weighted selection

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
