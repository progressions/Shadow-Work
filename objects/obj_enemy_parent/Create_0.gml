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

party_controller_id = -1;

// Store movement direction for animation
move_dir_x = 0;
move_dir_y = 0;

current_base_frame = 0;
frame_counter = 0;

if (!variable_instance_exists(self, "state")) {
    state = EnemyState.targeting;
}

wander_center_x = xstart;
wander_center_y = ystart;
wander_radius   = 100;
aggro_release_distance = -1;
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

// Hazard Spawning System
// Enemies can spawn projectiles that create persistent hazards (fire pools, poison clouds, etc)
enable_hazard_spawning = false;                  // Enable hazard spawning ability
hazard_spawn_cooldown = 180;                     // Frames between spawns (3 seconds at 60fps, default)
hazard_spawn_cooldown_timer = 0;                 // Current cooldown counter (counts up to hazard_spawn_cooldown)
hazard_spawn_windup_time = 30;                   // Frames for windup animation (0.5 seconds default)
hazard_spawn_windup_timer = 30;                  // Current windup counter (counts down from hazard_spawn_windup_time)

// Projectile Configuration
hazard_projectile_object = obj_hazard_projectile;     // Projectile object to spawn
hazard_projectile_distance = 128;                     // Pixels projectile travels before landing
hazard_projectile_speed = 3;                          // Movement speed (pixels per frame)
hazard_projectile_damage = 2;                         // Damage on player hit
hazard_projectile_damage_type = DamageType.fire;      // Damage type (fire, poison, etc)
hazard_projectile_direction_offset = 0;               // Degrees offset from facing_dir

// Hazard Configuration
hazard_spawn_object = obj_fire;                       // Object created at landing point
hazard_status_effects = [];                           // Optional status effects to apply on hit
hazard_lifetime = -1;                                 // Hazard duration in seconds (-1 = permanent)

// Explosion Configuration (optional blast when projectile lands)
hazard_explosion_enabled = false;                     // Enable explosion at landing point
hazard_explosion_object = obj_explosion;              // Explosion visual/damage object
hazard_explosion_damage = 3;                          // Explosion damage
hazard_explosion_damage_type = DamageType.fire;       // Explosion damage type

// Multi-Attack Boss Support
// Allows boss enemies to use melee, ranged, AND hazard spawning attacks with independent cooldowns
allow_multi_attack = false;                           // Enable multiple attack types
hazard_priority = 30;                                 // Weight for hazard attack in decision making (0-100)

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

// Collision Damage System
// Enemies can damage player on contact (configurable per enemy type)
collision_damage_enabled = false;        // Enable/disable collision damage
collision_damage_amount = 2;             // Base damage on collision
collision_damage_type = DamageType.physical;  // Damage type
collision_damage_cooldown = 30;          // Frames between collision hits (0.5s)
collision_damage_timer = 0;              // Current cooldown timer

// Trait system v2.0 - Stacking traits
traits = [];
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
    on_hazard_windup: undefined,  // Default: snd_enemy_attack_generic or snd_ranged_attack (hazard spawn telegraph)
    on_hazard_vocalize: undefined,  // Default: undefined (monster vocalization - played alongside on_hazard_windup)
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
unstuck_mode = 0;           // Frames remaining in unstuck movement
unstuck_attempts = 0;       // Number of unstuck attempts
unstuck_direction = 0;      // Direction to move when unstuck
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

// Serialize/deserialize methods removed during save system rebuild
function serialize() {
    var _struct = {
        // Base persistent_parent fields
        object_type: object_get_name(object_index),
        persistent_id: persistent_id,
        x: x,
        y: y,
        room_name: room_get_name(room),
        sprite_index: sprite_get_name(sprite_index),
        image_index: image_index,
        image_xscale: image_xscale,
        image_yscale: image_yscale,

        // Enemy-specific fields
        hp: hp,
        hp_total: hp_total,
        state: state,

        // Knockback
        kb_x: kb_x,
        kb_y: kb_y,
        knockback_timer: knockback_timer,

        // Combat state
        can_attack: can_attack,
        attack_cooldown: attack_cooldown,
        can_ranged_attack: can_ranged_attack,
        ranged_attack_cooldown: ranged_attack_cooldown,
        ranged_windup_complete: ranged_windup_complete,

        // Crowd control
        is_stunned: is_stunned,
        is_staggered: is_staggered,
        stun_timer: stun_timer,
        stagger_timer: stagger_timer,

        // Movement and targeting
        target_x: target_x,
        target_y: target_y,
        facing_dir: facing_dir,
        approach_mode: approach_mode,
        approach_chosen: approach_chosen,
        flank_offset_angle: flank_offset_angle,

        // Animation
        anim_timer: anim_timer,
        last_dir_index: last_dir_index,
        prev_start_index: prev_start_index,

        // Aggro and wandering
        aggro_distance: aggro_distance,
        aggro_release_distance: aggro_release_distance,
        wander_center_x: wander_center_x,
        wander_center_y: wander_center_y,
        wander_radius: wander_radius,

        // Traits
        traits: traits,

        // Party controller
        party_controller_id: party_controller_id
    };

    return _struct;
}

/* 
 { object_type : "obj_greenwood_bandit", x : 673.05, y : 438.77, kb_x : 0, kb_y : 0, knockback_timer : 0, approach_mode : "direct", flank_offset_angle : 0, 
is_stunned : 0, is_staggered : 0, can_attack : 1, attack_cooldown : 0, target_x : 650, target_y : 402, facing_dir : "left", 
sprite_index : "spr_greenwood_bandit", image_index : 5, hp_total : 3, image_xscale : 1, image_yscale : 1, traits : [  ], 
persistent_id : "obj_greenwood_bandit_650_402", last_dir_index : 2, aggro_distance : 90, wander_center_x : 650, wander_center_y : 402, 
wander_radius : 100, anim_timer : 103.95, state : 7, can_ranged_attack : 1, room_name : "room_level_1", approach_chosen : 0, aggro_release_distance : -1, prev_start_index : 4, 
party_controller_id : "obj_canopy_threat_657_449", hp : 4, ranged_windup_complete : 0, ranged_attack_cooldown : 0, stun_timer : 0, stagger_timer : 0 }
*/

function deserialize(_obj_data) {
	// Position
	x = _obj_data[$ "x"] ?? x;
	y = _obj_data[$ "y"] ?? y;

	// Knockback
	kb_x = _obj_data[$ "kb_x"] ?? 0;
	kb_y = _obj_data[$ "kb_y"] ?? 0;
	knockback_timer = _obj_data[$ "knockback_timer"] ?? 0;

	// Movement and targeting
	approach_mode = _obj_data[$ "approach_mode"] ?? "direct";
	flank_offset_angle = _obj_data[$ "flank_offset_angle"] ?? 0;
	target_x = _obj_data[$ "target_x"] ?? x;
	target_y = _obj_data[$ "target_y"] ?? y;
	facing_dir = _obj_data[$ "facing_dir"] ?? "down";
	approach_chosen = _obj_data[$ "approach_chosen"] ?? false;

	// Crowd control
	is_stunned = _obj_data[$ "is_stunned"] ?? false;
	is_staggered = _obj_data[$ "is_staggered"] ?? false;
	stun_timer = _obj_data[$ "stun_timer"] ?? 0;
	stagger_timer = _obj_data[$ "stagger_timer"] ?? 0;

	// Combat state
	can_attack = _obj_data[$ "can_attack"] ?? true;
	attack_cooldown = _obj_data[$ "attack_cooldown"] ?? 0;
	can_ranged_attack = _obj_data[$ "can_ranged_attack"] ?? true;
	ranged_attack_cooldown = _obj_data[$ "ranged_attack_cooldown"] ?? 0;
	ranged_windup_complete = _obj_data[$ "ranged_windup_complete"] ?? false;

	// Sprite and animation
	sprite_index = asset_get_index(_obj_data[$ "sprite_index"] ?? sprite_get_name(sprite_index));
	image_index = _obj_data[$ "image_index"] ?? 0;
	image_xscale = _obj_data[$ "image_xscale"] ?? 1;
	image_yscale = _obj_data[$ "image_yscale"] ?? 1;
	anim_timer = _obj_data[$ "anim_timer"] ?? 0;
	last_dir_index = _obj_data[$ "last_dir_index"] ?? 0;
	prev_start_index = _obj_data[$ "prev_start_index"] ?? 0;

	// Health and state
	hp_total = _obj_data[$ "hp_total"] ?? hp_total;
	hp = _obj_data[$ "hp"] ?? hp_total;
	state = _obj_data[$ "state"] ?? EnemyState.targeting;

	// Traits
	traits = _obj_data[$ "traits"] ?? [];

	// Persistent ID
	persistent_id = _obj_data[$ "persistent_id"] ?? persistent_id;

	// Aggro and wandering
	aggro_distance = _obj_data[$ "aggro_distance"] ?? 90;
	aggro_release_distance = _obj_data[$ "aggro_release_distance"] ?? -1;
	wander_center_x = _obj_data[$ "wander_center_x"] ?? x;
	wander_center_y = _obj_data[$ "wander_center_y"] ?? y;
	wander_radius = _obj_data[$ "wander_radius"] ?? 100;

	// Party controller
	party_controller_id = _obj_data[$ "party_controller_id"] ?? -1;
}