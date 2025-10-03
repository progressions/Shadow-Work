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

state = EnemyState.targeting;
facing_dir = "down"; // String direction for ranged attacks (updated from dir_index in Step event)

kb_x = 0;
kb_y = 0;

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