// Call parent create event
event_inherited();

// Get the tilemap for collisions
tilemap = layer_tilemap_get_id("Tiles_Col");

hp_total = hp;

// Initialize animation variables - IMPORTANT!
anim_timer = 0;  // Make sure this is here
image_speed = 0;
image_index = 0;

target_x = x;
target_y = y;

alarm[0] = 60;

// Store movement direction for animation
move_dir_x = 0;
move_dir_y = 0;

current_base_frame = 0;
frame_counter = 0;

if (!variable_instance_exists(self, "state")) {
    state = EnemyState.targeting;
}

if (!variable_instance_exists(self, "wander_center_x")) wander_center_x = xstart;
if (!variable_instance_exists(self, "wander_center_y")) wander_center_y = ystart;
if (!variable_instance_exists(self, "wander_radius"))   wander_radius   = 100;
if (!variable_instance_exists(self, "aggro_release_distance")) aggro_release_distance = -1;
facing_dir = "down"; // String direction for ranged attacks (updated from dir_index in Step event)

kb_x = 0;
kb_y = 0;
knockback_timer = 0;
knockback_damping = 0.8;

// Attack system stats
attack_damage = 2; // Base enemy damage
attack_damage_type = DamageType.physical; // Default physical damage
attack_speed = 0.8; // Slower than default player
attack_range = 20; // Melee range
attack_cooldown = 0;
can_attack = true;

// Ranged attack system
is_ranged_attacker = false;  // Set to true for enemies that use ranged attacks
ranged_damage = 2;           // Default arrow damage (override in child enemies)
ranged_attack_cooldown = 0;  // Separate cooldown for ranged attacks
ranged_attack_speed = 0.8;   // Attacks per second for ranged (default slower than melee)
can_ranged_attack = true;    // Cooldown flag for ranged attacks
ranged_damage_type = DamageType.physical; // Damage type for ranged projectiles
ranged_status_effects = [];  // Optional status effects applied by ranged projectiles
ranged_projectile_object = obj_enemy_arrow; // Default projectile for ranged enemies

// Status effects system
init_status_effects();

// Trait system v2.0 - Stacking traits
tags = []; // Thematic descriptors (fireborne, venomous, etc.) - set by child enemies
permanent_traits = {}; // From tags (applied at creation)
temporary_traits = {};  // From buffs/debuffs (applied during combat)

// Enemy sound configuration
// Child enemies can override specific sounds: enemy_sounds.on_attack = snd_orc_roar;
enemy_sounds = {
    on_attack: undefined,      // Default: snd_enemy_attack_generic
    on_hit: undefined,         // Default: snd_enemy_hit_generic
    on_death: undefined,       // Default: snd_enemy_death
    on_aggro: undefined,       // Default: undefined (no sound)
    on_footstep: undefined,    // Default: undefined (no sound)
    on_status_effect: undefined // Default: snd_status_effect_generic
};

// Pathfinding system variables
path = path_add();              // GameMaker path instance
ideal_range = attack_range;     // Ideal distance from player (override in child enemies for ranged)
                                // RANGED ENEMIES: Set ideal_range to ~75-80% of attack_range in child Create event
                                // This enables kiting/circle strafe behavior while staying in attack range
path_update_timer = 0;          // Frame counter for path updates
last_target_x = 0;              // Track player position changes
last_target_y = 0;
current_path_target_x = 0;      // Where path is leading
current_path_target_y = 0;
last_seen_player_x = 0;         // Last position where enemy had LOS to player
last_seen_player_y = 0;

// Stuck detection
stuck_check_x = x;
stuck_check_y = y;
alarm[4] = 60; // Check if stuck every second

// Approach variation system (flanking behavior)
approach_mode = "direct";        // "direct" or "flanking" - chosen when entering trigger range
approach_chosen = false;         // Set to true once approach angle selected (prevents re-selection)
flank_offset_angle = 0;          // Perpendicular offset angle (±90 degrees) for flanking
flank_trigger_distance = 120;    // Distance threshold to trigger approach selection
flank_chance = 0.4;              // Probability of flanking vs direct approach (40% default)

// Party controller system
party_controller = noone;  // Reference to obj_enemy_party_controller if in a party
current_objective = "attack"; // Current objective: "attack", "formation", or "flee"
objective_target_x = 0;  // Target x for current objective
objective_target_y = 0;  // Target y for current objective
formation_target_x = 0;  // Formation position x
formation_target_y = 0;  // Formation position y
flee_target_x = 0;       // Flee destination x
flee_target_y = 0;       // Flee destination y

// Loot drop system
// drop_chance: Probability (0.0 to 1.0) that enemy drops loot on death
// loot_table: Array of {item_key, weight} structs
//   - item_key: String matching a key in global.item_database
//   - weight: Optional number (defaults to 1 for equal probability)
//
// Example equal-weight table:
//   loot_table = [
//       {item_key: "small_health_potion"},
//       {item_key: "rusty_dagger"}
//   ];
//
// Example weighted table (5:2:1 ratio):
//   loot_table = [
//       {item_key: "small_health_potion", weight: 5},
//       {item_key: "rusty_dagger", weight: 2},
//       {item_key: "greatsword", weight: 1}
//   ];
//
drop_chance = 0.3; // 30% chance to drop loot (default)
loot_table = [
    {item_key: "small_health_potion", weight: 3},
    {item_key: "water", weight: 2},
    {item_key: "arrows", weight: 1}
];

// Override serialize method for enemy-specific data
function serialize() {
    show_debug_message("SERIALIZING ENEMY: " + object_get_name(object_index) + " at position (" + string(x) + ", " + string(y) + ")");

    var data = {
        object_type: object_get_name(object_index),
        x: x,
        y: y,
        persistent_id: object_get_name(object_index) + "_" + string(x) + "_" + string(y),
        hp: hp,
        hp_max: hp_total,
        state: state,
        facing_dir: variable_instance_exists(id, "facing_dir") ? facing_dir : "down",
        tags: tags,
        traits: [], // Will be populated below
        status_effects: [] // Will be populated below
    };

    // Serialize traits (from both permanent and temporary)
    var trait_names = variable_struct_get_names(permanent_traits);
    for (var i = 0; i < array_length(trait_names); i++) {
        var trait_name = trait_names[i];
        array_push(data.traits, {
            trait_name: trait_name,
            stacks: permanent_traits[$ trait_name]
        });
    }
    trait_names = variable_struct_get_names(temporary_traits);
    for (var i = 0; i < array_length(trait_names); i++) {
        var trait_name = trait_names[i];
        array_push(data.traits, {
            trait_name: trait_name,
            stacks: temporary_traits[$ trait_name]
        });
    }

    // Serialize status effects
    for (var i = 0; i < array_length(status_effects); i++) {
        var effect = status_effects[i];
        array_push(data.status_effects, {
            type: effect.type,
            remaining_duration: effect.remaining_duration,
            tick_timer: effect.tick_timer,
            is_permanent: effect.is_permanent,
            neutralized: effect.neutralized
        });
    }

    return data;
}

// Override deserialize method to restore enemy-specific data
function deserialize(data) {
    show_debug_message("DESERIALIZING ENEMY: " + object_get_name(object_index) + " restoring to position (" + string(data.x) + ", " + string(data.y) + ")");

    x = data.x;
    y = data.y;
    hp = data.hp;
    hp_total = data.hp_max;
    state = data.state;
    facing_dir = data.facing_dir;
    tags = data.tags;

    // Restore traits
    permanent_traits = {};
    temporary_traits = {};
    for (var i = 0; i < array_length(data.traits); i++) {
        var trait_data = data.traits[i];
        permanent_traits[$ trait_data.trait_name] = trait_data.stacks;
    }

    // Restore status effects
    status_effects = [];
    for (var i = 0; i < array_length(data.status_effects); i++) {
        var effect_data = data.status_effects[i];
        var effect_definition = get_status_effect_data(effect_data.type);
        array_push(status_effects, {
            type: effect_data.type,
            remaining_duration: effect_data.remaining_duration,
            tick_timer: effect_data.tick_timer,
            data: effect_definition, // Restore the data property from global definitions
            is_permanent: effect_data.is_permanent,
            neutralized: effect_data.neutralized
        });
    }
}
