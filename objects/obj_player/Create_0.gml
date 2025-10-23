move_speed = 1.0;

// Momentum/velocity system
velocity_x = 0;
velocity_y = 0;
acceleration = 0.3;         // How quickly we reach max speed (higher = snappier)
friction_factor = 0.9;     // Deceleration when no input (higher = more slide)
max_velocity = 1.75;         // Cap on velocity (slightly higher than move_speed for momentum feel)

tilemap = layer_tilemap_get_id("Tiles_Col");

#region Stats

hp = 20;
hp_total = hp;
damage = 1;
facing_angle = 0;
level = 1;
xp = 0;
xp_to_next = 50;

// Trait system v2.0 - Stacking traits (replaces old damage_resistances)
tags = []; // Thematic descriptors (fireborne, venomous, etc.)
permanent_traits = {}; // From tags, quests (permanent)
temporary_traits = {};  // From equipment, companions, buffs (temporary)

// Terrain effects system
terrain_applied_traits = {};  // Struct: {trait_key: true/false} - tracks which terrain traits are active
current_terrain = "grass";    // String: last detected terrain type
terrain_speed_modifier = 1.0; // Real: speed multiplier from current terrain

// Combat timer for companion evading behavior
combat_timer = 999; // Start high so companions begin in following mode
combat_cooldown = 3; // Seconds of no combat before evading ends

// Critical hit system
crit_chance = 0.1;      // 10% chance to crit
crit_multiplier = 1.75; // 1.75x damage on crit
last_attack_was_crit = false; // Set by get_total_damage(), read by obj_attack

// Stun/Stagger system (crowd control)
is_stunned = false;      // Can't attack or take actions
is_staggered = false;    // Can't move
stun_timer = 0;          // Countdown in frames
stagger_timer = 0;       // Countdown in frames
stun_resistance = 0;     // 0.0 to 1.0 (can be modified by traits)
stagger_resistance = 0;  // 0.0 to 1.0 (can be modified by traits)

// Stun star overlay
stun_star_state = undefined;

// Invulnerability system (prevents multi-hit from collision damage)
invulnerable = false;                    // Invulnerability flag
invulnerability_duration = 30;           // Frames of invulnerability (0.5s default)
invulnerability_timer = 0;               // Current invulnerability counter

#endregion Stats

move_dir = "right";
facing_dir = "down";

// In obj_player CREATE EVENT, add:
walking_sound = -1;  // Track the sound instance

equipped = {
	right_hand: undefined,
	left_hand: undefined,
	head: undefined,
	torso: undefined,
    legs: undefined,
}

loadouts = {
    active: "melee",
    melee: {
        right_hand: undefined,
        left_hand: undefined
    },
    ranged: {
        right_hand: undefined,
        left_hand: undefined
    }
};

inventory = [];
max_inventory_size = 16;

// Focus combat system configuration
focus_hold_duration_ms = 275; // tweakable duration for aim/retreat buffers
player_focus_init(self);
focus_state.hold_duration_ms = focus_hold_duration_ms;

// Quest system
active_quests = {};

debug = false;

interaction_offset_x = 0;
interaction_offset_y = -8;
interaction_radius = 1;


// Initialize the global frame tracker
global_frame = 0;

paused_frame = 0;

// Create the frame mapping (optional - for the first approach)
frame_mapping = ds_map_create();
frame_mapping[? "idle_down_start"] = 0;
frame_mapping[? "idle_right_start"] = 2;
frame_mapping[? "idle_left_start"] = 4;
frame_mapping[? "idle_up_start"] = 6;
frame_mapping[? "walk_down_start"] = 8;
frame_mapping[? "walk_right_start"] = 12;
frame_mapping[? "walk_left_start"] = 17;
frame_mapping[? "walk_up_start"] = 22;

#region player sprite choice

// Set the sprite once
sprite_index = spr_player;
image_speed = 0;  // IMPORTANT: Disable automatic animation

// In CREATE EVENT add:
// Double-tap detection
double_tap_time = 300;  // milliseconds
last_key_time_w = -999;
last_key_time_a = -999;
last_key_time_s = -999;
last_key_time_d = -999;

// Dash state
dash_duration = 8;  // frames
dash_timer = 0;
dash_speed = 6;

dash_cooldown = 0;
dash_cooldown_time = 75;

// Dash attack system
dash_attack_window = 0;
dash_attack_window_duration = 0.4; // seconds
dash_attack_damage_multiplier = 1.5; // +50% damage
dash_attack_defense_penalty = 0.75; // -25% damage reduction
last_dash_direction = "";
is_dash_attacking = false;
dash_override_direction = "";
dash_hit_enemies = -1;
dash_hit_count = 0;
dash_target_cap = 1;
dash_impact_sound_played = false;
dash_multi_bonus_active = false;
dash_multi_bonus_cap = 0;

// Player animation data based on sprite frame tags
anim_data = {
    // Idle animations (2 frames each)
    idle_down: {start: 0, length: 2},
    idle_right: {start: 2, length: 2},
    idle_left: {start: 4, length: 2},
    idle_up: {start: 6, length: 2},

    // Walk animations (4-5 frames each)
    walk_down: {start: 8, length: 4},
    walk_right: {start: 12, length: 5},
    walk_left: {start: 17, length: 5},
    walk_up: {start: 22, length: 4},

    // Dash animations (4 frames each)
    dash_down: {start: 26, length: 4},
    dash_right: {start: 30, length: 4},
    dash_left: {start: 34, length: 4},
    dash_up: {start: 38, length: 4},

    // Attack animations (4 frames each)
    attack_down: {start: 42, length: 4},
    attack_right: {start: 46, length: 4},
    attack_left: {start: 50, length: 4},
    attack_up: {start: 54, length: 4},

    // Dead animation (3 frames)
    dead: {start: 58, length: 3},

    // Shield animations (3 frames each - raise and hold)
    shielding_down: {start: 61, length: 3},
    shielding_right: {start: 64, length: 3},
    shielding_left: {start: 67, length: 3},
    shielding_up: {start: 70, length: 3}
};

// State tracking
facing_dir = "down";
move_dir = "idle";
current_anim = "idle_down";
current_anim_start = 0;
current_anim_length = 2;
state = PlayerState.idle;

// Animation control
anim_frame = 0;  // Track current frame within animation
anim_speed_idle = 0.05;  // How fast to animate (adjust as needed)
anim_speed_walk = 0.15;

elevation_source = noone;
current_elevation = -1;
y_offset = 0;
previous_y_offset = 0;

// Attack system
attack_cooldown = 0;
can_attack = true;

// Shield block system
block_cooldown = 0;              // Frames remaining before can block again
block_cooldown_max = 60;         // Default cooldown after normal block (1 second)
block_cooldown_perfect_max = 30; // Shorter cooldown after perfect block (0.5 seconds)
perfect_block_window = 0;        // Frames when perfect block is active
perfect_block_window_duration = 18;  // Window duration in frames (~0.3s at 60fps)
shield_raise_complete = false;   // Has shield animation finished playing?
shield_facing_dir = "down";      // Direction player is shielding (locked)
shield_anim_frame = 0;           // Current frame of shield animation (for drawing)

// Ranged attack windup system (telegraph/anticipation before projectile spawn)
// Creates visual and audio telegraph by slowing attack animation and delaying projectile spawn
ranged_windup_speed = 0.6;        // Animation speed multiplier during windup (0.1-1.0, default 0.6)
                                  // Lower values = longer telegraph. Can be modified by equipment/traits
ranged_windup_complete = false;   // Tracks if first animation cycle finished (projectile spawns when true)
ranged_windup_active = false;     // Tracks if currently winding up a ranged attack
ranged_windup_direction = "down"; // Stores direction for arrow spawn after windup

// Knockback system
kb_x = 0;
kb_y = 0;

// Status effects system
init_status_effects();

// Trait system
traits = [];

// Add this function to your scripts or at the bottom of Create Event:
function start_dash(_direction, _preserve_facing) {
    if (argument_count < 2) _preserve_facing = false;
    dash_timer = dash_duration;
    last_dash_direction = _direction;
    dash_attack_window = 0;
    dash_cooldown = dash_cooldown_time;
    dash_override_direction = "";

    if (_preserve_facing) {
        dash_override_direction = _direction;
    } else {
        facing_dir = _direction;
    }

    player_dash_begin();
    play_sfx(snd_dash, 1, false);
    companion_on_player_dash(id);
}

// Check if player is in active combat (for companion evading behavior)
function is_in_combat() {
    return combat_timer < combat_cooldown;
}

// Trigger invulnerability frames (prevents multi-hit from collision damage)
function trigger_invulnerability(duration) {
    invulnerable = true;
    invulnerability_timer = duration;
}


// Torch lighting properties (functions moved to scr_lighting)
torch_active = false;
torch_time_remaining = 0;

var _torch_stats = global.item_database.torch.stats;
var _torch_burn_seconds = 60;
if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "burn_time_seconds")) {
    _torch_burn_seconds = max(1, _torch_stats[$ "burn_time_seconds"]);
}
torch_duration = max(1, floor(_torch_burn_seconds * game_get_speed(gamespeed_fps)));
torch_looping = false; // Track if torch loop sound is playing


/// @function player_build_equipped_entry_from_save
/// @description Convert saved equipment entry into runtime struct with definition/count/durability
function player_build_equipped_entry_from_save(_source_value) {
	if (_source_value == undefined) return undefined;

	var _item_key = undefined;
	var _count = 1;
	var _durability = 100;

	if (is_string(_source_value)) {
		_item_key = _source_value;
	} else if (is_struct(_source_value)) {
		if (variable_struct_exists(_source_value, "item_key")) {
			_item_key = _source_value.item_key;
		}
		if (variable_struct_exists(_source_value, "count")) {
			_count = max(1, _source_value.count);
		}
		if (variable_struct_exists(_source_value, "durability")) {
			_durability = _source_value.durability;
		}
		if (_item_key == undefined && variable_struct_exists(_source_value, "definition")) {
			var _saved_def = _source_value.definition;
			if (is_struct(_saved_def)) {
				if (variable_struct_exists(_saved_def, "item_id")) {
					_item_key = _saved_def.item_id;
				} else if (variable_struct_exists(_saved_def, "item_key")) {
					_item_key = _saved_def.item_key;
				}
			}
		}
	}

	if (_item_key == undefined) return undefined;
	if (!variable_struct_exists(global.item_database, _item_key)) return undefined;

	var _def = global.item_database[$ _item_key];

	return {
		definition: _def,
		count: max(1, _count),
		durability: _durability
	};
}

function serialize() {
	// Helper to get item key/id from inventory or equipped items
	var _get_item_key = function(_item) {
		if (_item == undefined) return undefined;
		if (!is_struct(_item)) return undefined;

		// Check if this is an equipped item (has item_key/item_id directly)
		if (variable_struct_exists(_item, "item_key")) {
			return _item.item_key;
		}
		if (variable_struct_exists(_item, "item_id")) {
			return _item.item_id;
		}

		// Check if this is an inventory item (has definition with item_key/item_id)
		if (variable_struct_exists(_item, "definition")) {
			var _def = _item.definition;
			if (is_struct(_def)) {
				if (variable_struct_exists(_def, "item_key")) {
					return _def.item_key;
				}
				if (variable_struct_exists(_def, "item_id")) {
					return _def.item_id;
				}
			}
		}

		return undefined;
	};

	// Serialize inventory items (with counts)
	var _inventory_serialized = [];
	for (var i = 0; i < array_length(inventory); i++) {
		var _inv_item = inventory[i];
		if (is_struct(_inv_item)) {
			var _item_key = _get_item_key(_inv_item);
			if (_item_key != undefined) {
				array_push(_inventory_serialized, {
					item_key: _item_key,
					count: variable_struct_exists(_inv_item, "count") ? _inv_item.count : 1
				});
			}
		}
	}

	// Serialize equipped items
	var _equipped_serialized = {
		right_hand: _get_item_key(equipped.right_hand),
		left_hand: _get_item_key(equipped.left_hand),
		head: _get_item_key(equipped.head),
		torso: _get_item_key(equipped.torso),
		legs: _get_item_key(equipped.legs)
	};

	return {
		object_type: "obj_player",
		x: x,
		y: y,
		hp: hp,
		hp_total: hp_total,
		xp: xp,
		level: level,
		torch_active: torch_active,
		torch_time_remaining: torch_time_remaining,
		inventory: _inventory_serialized,
		equipped: _equipped_serialized,
		loadouts: loadouts
	};
}

function deserialize(_data) {
	show_debug_message(">>> PLAYER DESERIALIZE CALLED <<<");
	show_debug_message("Data received - X: " + string(_data.x) + " Y: " + string(_data.y));

	// Set position FIRST
	x = _data.x;
	y = _data.y;

	show_debug_message("Position set - Current X: " + string(x) + " Y: " + string(y));

	// Zero out velocity
	hspd = 0;
	vspd = 0;

	// Force idle state
	state = PlayerState.idle;

	// Restore stats
	hp = _data.hp;
	hp_total = _data.hp_total;
	xp = _data.xp;
	level = _data.level;

	// Restore torch
	torch_active = _data.torch_active;
	torch_time_remaining = _data.torch_time_remaining;

	if (torch_active && torch_time_remaining > 0) {
		player_start_torch_loop();
	} else {
		player_stop_torch_loop();
	}

	// Restore inventory
	if (variable_struct_exists(_data, "inventory") && is_array(_data.inventory)) {
		inventory = [];
		var _inv_array = _data.inventory;
		for (var i = 0; i < array_length(_inv_array); i++) {
			var _inv_entry = _inv_array[i];
			var _item_key = undefined;
			var _item_count = 1;

			if (is_struct(_inv_entry)) {
				if (variable_struct_exists(_inv_entry, "item_key")) {
					_item_key = _inv_entry.item_key;
				}
				if (variable_struct_exists(_inv_entry, "count")) {
					_item_count = _inv_entry.count;
				}
			}

			if (_item_key != undefined && variable_struct_exists(global.item_database, _item_key)) {
				var _item_def = global.item_database[$ _item_key];
				inventory_add_item(_item_def, _item_count);
			}
		}
		show_debug_message("Restored " + string(array_length(inventory)) + " inventory items");
	}

	var _assign_equipped_slot = function(_slot_name, _value) {
		var _entry = player_build_equipped_entry_from_save(_value);
		if (_entry != undefined) {
			equipped[$ _slot_name] = _entry;
			if (variable_struct_exists(_entry.definition, "stats")) {
				apply_wielder_effects(_entry.definition.stats);
			}
		}
	};

	// Restore equipped items
	if (variable_struct_exists(_data, "equipped") && is_struct(_data.equipped)) {
		var _equipped_data = _data.equipped;

		var _remove_existing_effects = function(_entry) {
			if (_entry != undefined && is_struct(_entry) && variable_struct_exists(_entry, "definition")) {
				var _def = _entry.definition;
				if (is_struct(_def) && variable_struct_exists(_def, "stats")) {
					remove_wielder_effects(_def.stats);
				}
			}
		};

		_remove_existing_effects(equipped.right_hand);
		_remove_existing_effects(equipped.left_hand);
		_remove_existing_effects(equipped.head);
		_remove_existing_effects(equipped.torso);
		_remove_existing_effects(equipped.legs);

		equipped.right_hand = undefined;
		equipped.left_hand = undefined;
		equipped.head = undefined;
		equipped.torso = undefined;
		equipped.legs = undefined;

		if (variable_struct_exists(_equipped_data, "right_hand") && _equipped_data.right_hand != undefined) {
			_assign_equipped_slot("right_hand", _equipped_data.right_hand);
		}
		if (variable_struct_exists(_equipped_data, "left_hand") && _equipped_data.left_hand != undefined) {
			_assign_equipped_slot("left_hand", _equipped_data.left_hand);
		}
		if (variable_struct_exists(_equipped_data, "head") && _equipped_data.head != undefined) {
			_assign_equipped_slot("head", _equipped_data.head);
		}
		if (variable_struct_exists(_equipped_data, "torso") && _equipped_data.torso != undefined) {
			_assign_equipped_slot("torso", _equipped_data.torso);
		}
		if (variable_struct_exists(_equipped_data, "legs") && _equipped_data.legs != undefined) {
			_assign_equipped_slot("legs", _equipped_data.legs);
		}
		show_debug_message("Equipment restored");
	}

	// Restore loadouts
	if (variable_struct_exists(_data, "loadouts")) {
		var _saved_loadouts = _data.loadouts;

		loadouts = {
			active: "melee",
			melee: { right_hand: undefined, left_hand: undefined },
			ranged: { right_hand: undefined, left_hand: undefined }
		};

		var _hydrate_loadout_slot = function(_value) {
			return player_build_equipped_entry_from_save(_value);
		};

		if (is_struct(_saved_loadouts)) {
			loadouts.active = _saved_loadouts[$ "active"] ?? loadouts.active;

			if (variable_struct_exists(_saved_loadouts, "melee") && is_struct(_saved_loadouts.melee)) {
				loadouts.melee.right_hand = _hydrate_loadout_slot(_saved_loadouts.melee[$ "right_hand"]);
				loadouts.melee.left_hand = _hydrate_loadout_slot(_saved_loadouts.melee[$ "left_hand"]);
			}

			if (variable_struct_exists(_saved_loadouts, "ranged") && is_struct(_saved_loadouts.ranged)) {
				loadouts.ranged.right_hand = _hydrate_loadout_slot(_saved_loadouts.ranged[$ "right_hand"]);
				loadouts.ranged.left_hand = _hydrate_loadout_slot(_saved_loadouts.ranged[$ "left_hand"]);
			}
		}

		var _active_key = loadouts.active;
		if (is_string(_active_key) && variable_struct_exists(loadouts, _active_key)) {
			if (equipped.right_hand != undefined) {
				loadouts[$ _active_key].right_hand = equipped.right_hand;
			}
			if (equipped.left_hand != undefined) {
				loadouts[$ _active_key].left_hand = equipped.left_hand;
			}
		}

	}

	show_debug_message("Player deserialized at (" + string(x) + ", " + string(y) + ")");
}

// If a save file queued player restore data before this instance existed,
// apply it now that the player has been created.
apply_pending_player_restore();
