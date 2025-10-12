// ============================================
// TERRAIN EFFECTS SYSTEM
// ============================================

/// @function init_terrain_effects()
/// @description Initialize terrain effects map with traits, speed modifiers, and hazard flags
function init_terrain_effects() {
    global.terrain_effects_map = {
        "lava": {
            traits: ["burning"],              // Array of trait keys to apply
            speed_modifier: 0.5,              // 20% slower (0.8x speed)
            is_hazard: true,                  // Mark as obstacle in pathfinding
            hazard_immunity_traits: ["fire_immunity", "ground_hazard_immunity"]  // Entities with these traits ignore hazard flag
        },
        "poison_pool": {
            traits: ["poisoned"],
            speed_modifier: 0.7,              // 30% slower
            is_hazard: true,
            hazard_immunity_traits: ["poison_immunity", "ground_hazard_immunity"]
        },
        "ice": {
            traits: [],                       // No traits applied
            speed_modifier: 1.4,              // 40% faster (slippery)
            is_hazard: false                  // Not a pathfinding obstacle
        },
        "path": {
            traits: [],
            speed_modifier: 1.25,             // 25% faster (existing behavior)
            is_hazard: false
        },
        "water": {
            traits: ["wet"],
            speed_modifier: 0.9,              // 10% slower
            is_hazard: false                  // Not hazardous (just slows)
        },
        "grass": {
            traits: [],
            speed_modifier: 1.0,              // Normal speed
            is_hazard: false
        }
    };
}
