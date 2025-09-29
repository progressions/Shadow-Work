persistent = true;

// Initialize audio configuration
global.audio_config = {
    music_enabled: true,
    sfx_enabled: true
};

// Initialize trait database
global.trait_database = {
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
