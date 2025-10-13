// Call parent create event
event_inherited();

// Get the tilemap for collisions
tilemap = layer_tilemap_get_id("Tiles_Col");

hp_total = hp;

// Initialize animation variables - IMPORTANT!
anim_timer = 0;  // Make sure this is here
image_speed = 0;
image_index = 0;
base_image_blend = c_white;
image_blend = base_image_blend;

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

// Critical hit system (configurable per enemy type/instance)
crit_chance = 0.05;      // 5% base crit chance (lower than player)
crit_multiplier = 1.5;   // 1.5x damage on crit (also lower than player)

// Ranged attack system
is_ranged_attacker = false;  // Set to true for enemies that use ranged attacks
ranged_damage = 2;           // Default arrow damage (override in child enemies)
ranged_attack_cooldown = 0;  // Separate cooldown for ranged attacks
ranged_attack_speed = 0.8;   // Attacks per second for ranged (default slower than melee)
can_ranged_attack = true;    // Cooldown flag for ranged attacks
ranged_damage_type = DamageType.physical; // Damage type for ranged projectiles
ranged_status_effects = [];  // Optional status effects applied by ranged projectiles
ranged_projectile_object = obj_enemy_arrow; // Default projectile for ranged enemies
ranged_projectile_speed = 4; // Speed of projectile (pixels per frame)

// Ranged attack windup system (telegraph/anticipation before projectile spawn)
// This creates a visual and audio telegraph by slowing the attack animation and delaying projectile spawn
ranged_windup_speed = 0.5;        // Animation speed multiplier during windup (0.1-1.0, default 0.5 = half-speed)
                                  // Lower values = longer telegraph. Example: 0.3 = very slow, 0.7 = quick
ranged_windup_complete = false;   // Tracks if first animation cycle finished (projectile spawns when true)
                                  // Set to false when entering ranged_attacking state, becomes true after animation completes

melee_damage_resistance = 0;
ranged_damage_resistance = 0;

// Attack structs for melee and ranged (includes stun/stagger properties)
// Child enemies can override these to customize stun/stagger chances per enemy type
melee_attack = {
    damage: attack_damage,
    damage_type: attack_damage_type,
    chance_to_stun: 0.05,       // 5% default stun chance
    chance_to_stagger: 0.10,    // 10% default stagger chance
    stun_duration: 1.5,         // 1.5 seconds default
    stagger_duration: 1.0,      // 1.0 seconds default
    range: attack_range         // Melee reach (overridden by child enemy if needed)
};

ranged_attack = {
    damage: ranged_damage,
    damage_type: ranged_damage_type,
    chance_to_stun: 0.03,       // 3% default (lower for ranged)
    chance_to_stagger: 0.08,    // 8% default (lower for ranged)
    stun_duration: 1.2,         // 1.2 seconds default
    stagger_duration: 0.8,      // 0.8 seconds default
    range: attack_range         // Default to melee range unless overridden
};

// Dual-mode combat system (context-based attack switching)
enable_dual_mode = false;              // When true, enemy can switch between melee and ranged based on distance
preferred_attack_mode = "none";        // Options: "none" (distance-based), "melee" (bias melee), "ranged" (bias ranged, retreat when close)
melee_range_threshold = attack_range * 0.5;  // Distance below which melee is preferred (default 50% of attack_range)
retreat_when_close = false;            // When true and preferred_attack_mode="ranged", enemy retreats if player breaches ideal_range
attack_mode_cache = undefined;         // Cached attack mode decision (for performance optimization)
cache_timer = 0;                       // Timer for attack mode cache refresh (frames)
retreat_cooldown = 0;                  // Cooldown timer to prevent retreat pathfinding spam (60 frames = 1 second)

// Party formation integration (optional, set by party controller)
formation_role = undefined;            // Formation role: "rear", "front", "support" - influences attack mode selection

// Status effects system
init_status_effects();

// Stun/Stagger system (crowd control)
is_stunned = false;      // Can't attack or take actions
is_staggered = false;    // Can't move
stun_timer = 0;          // Countdown in frames
stagger_timer = 0;       // Countdown in frames
stun_resistance = 0;     // 0.0 to 1.0 (can be modified by traits)
stagger_resistance = 0;  // 0.0 to 1.0 (can be modified by traits)

// Stun star overlay
stun_star_state = undefined;

// Trait system v2.0 - Stacking traits
tags = []; // Thematic descriptors (fireborne, venomous, etc.) - set by child enemies
permanent_traits = {}; // From tags (applied at creation)
temporary_traits = {};  // From buffs/debuffs (applied during combat)

// Terrain effects system
terrain_applied_traits = {};  // Struct: {trait_key: true/false} - tracks which terrain traits are active
current_terrain = "grass";    // String: last detected terrain type
terrain_speed_modifier = 1.0; // Real: speed multiplier from current terrain

// Enemy sound configuration
// Child enemies can override specific sounds: enemy_sounds.on_melee_attack = snd_orc_roar;
enemy_sounds = {
    on_melee_attack: undefined,   // Default: snd_enemy_attack_generic
    on_ranged_attack: undefined,  // Default: snd_bow_attack
    on_ranged_windup: undefined,  // Default: snd_ranged_windup (plays when ranged attack animation starts)
    on_hit: undefined,            // Default: snd_enemy_hit_generic
    on_death: undefined,          // Default: snd_enemy_death
    on_aggro: undefined,          // Default: undefined (no sound)
    on_footstep: undefined,       // Default: undefined (no sound)
    on_status_effect: undefined   // Default: snd_status_effect_generic
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

// Movement profile system (specialized movement behaviors)
movement_profile = undefined;           // Assigned profile from global.movement_profile_database
movement_profile_state = "idle";       // Profile-specific state: "idle", "kiting", "swooping", "returning"
movement_profile_anchor_x = x;         // Home position X
movement_profile_anchor_y = y;         // Home position Y
movement_profile_target_x = x;         // Current movement target X
movement_profile_target_y = y;         // Current movement target Y
movement_profile_erratic_timer = 0;    // Timer for erratic adjustments
movement_profile_swoop_cooldown = 0;   // Cooldown timer for swoop attacks

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

// Flash effect system
flash_timer = 0;         // Countdown timer for flash duration
flash_color = c_white;   // Current flash color (c_white for normal hit, c_red for crit)

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
        timed_traits: [] // Captures in-flight timed traits
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

    // Serialize timed traits
    if (variable_instance_exists(self, "timed_traits")) {
        for (var t = 0; t < array_length(timed_traits); t++) {
            var _entry = timed_traits[t];
            array_push(data.timed_traits, {
                trait: _entry.trait,
                remaining_seconds: (_entry.timer ?? 0) / game_get_speed(gamespeed_fps),
                total_seconds: (_entry.total_duration ?? _entry.timer ?? 0) / game_get_speed(gamespeed_fps),
                stacks: _entry.stacks_applied
            });
        }
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

    // Restore timed traits (reapply stacks and timers)
    timed_traits = [];
    if (array_length(data.timed_traits) > 0) {
        for (var tt = 0; tt < array_length(data.timed_traits); tt++) {
            var _saved = data.timed_traits[tt];
            var _trait_key = _saved.trait;
            var _stacks = _saved.stacks ?? 1;
            var _total_seconds = _saved.total_seconds ?? _saved.remaining_seconds ?? 0;
            var _remaining_seconds = _saved.remaining_seconds ?? _total_seconds;

            if (_trait_key == undefined || _trait_key == "") continue;
            if (_total_seconds <= 0) continue;

            apply_timed_trait(_trait_key, _total_seconds, _stacks);

            var _last_index = array_length(timed_traits) - 1;
            if (_last_index >= 0) {
                timed_traits[_last_index].timer = round(max(0, _remaining_seconds) * game_get_speed(gamespeed_fps));
                timed_traits[_last_index].total_duration = round(max(0, _total_seconds) * game_get_speed(gamespeed_fps));
            }
        }
    }
}
