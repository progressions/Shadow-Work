// ============================================
// SAVE SYSTEM
// ============================================

/// @function serialize_player()
/// @description Serialize player data to a struct for saving
function serialize_player() {
    var player = obj_player;

    // Serialize traits with stacks
    var traits_array = [];
    var trait_keys = variable_struct_get_names(player.permanent_traits);
    for (var i = 0; i < array_length(trait_keys); i++) {
        var trait_name = trait_keys[i];
        var stacks = player.permanent_traits[$ trait_name];
        array_push(traits_array, {
            trait_name: trait_name,
            stacks: stacks
        });
    }

    // Add temporary traits
    var temp_trait_keys = variable_struct_get_names(player.temporary_traits);
    for (var i = 0; i < array_length(temp_trait_keys); i++) {
        var trait_name = temp_trait_keys[i];
        var stacks = player.temporary_traits[$ trait_name];
        array_push(traits_array, {
            trait_name: trait_name,
            stacks: stacks,
            is_temporary: true
        });
    }

    // Serialize timed traits (status-style effects)
    var timed_traits_array = [];
    if (variable_instance_exists(player, "timed_traits")) {
        for (var i = 0; i < array_length(player.timed_traits); i++) {
            var timed_entry = player.timed_traits[i];
            array_push(timed_traits_array, {
                trait: timed_entry.trait,
                remaining_seconds: (timed_entry.timer ?? 0) / game_get_speed(gamespeed_fps),
                total_seconds: (timed_entry.total_duration ?? timed_entry.timer ?? 0) / game_get_speed(gamespeed_fps),
                stacks: timed_entry.stacks_applied
            });
        }
    }

    return {
        x: player.x,
        y: player.y,
        hp: player.hp,
        hp_total: player.hp_total,
        xp: player.xp,
        level: player.level,
        facing_dir: player.facing_dir,
        state: player.state,
        dash_cooldown: player.dash_cooldown,
        torch_active: player.torch_active,
        torch_time_remaining: player.torch_time_remaining,
        traits: traits_array,
        tags: player.tags,
        timed_traits: timed_traits_array
    };
}

/// @function serialize_companions()
/// @description Serialize all companion data to array for saving
function serialize_companions() {
    var companions_array = [];

    with (obj_companion_parent) {
        // Serialize triggers
        var triggers_data = {};
        var trigger_names = variable_struct_get_names(triggers);
        for (var i = 0; i < array_length(trigger_names); i++) {
            var trigger_name = trigger_names[i];
            var trigger = triggers[$ trigger_name];
            triggers_data[$ trigger_name] = {
                unlocked: trigger.unlocked,
                cooldown: trigger.cooldown,
                active: trigger.active
            };
        }

        // Serialize auras
        var auras_data = {};
        var aura_names = variable_struct_get_names(auras);
        for (var i = 0; i < array_length(aura_names); i++) {
            var aura_name = aura_names[i];
            var aura = auras[$ aura_name];
            auras_data[$ aura_name] = {
                active: aura.active
            };
        }

        array_push(companions_array, {
            companion_id: companion_id,
            x: x,
            y: y,
            is_recruited: is_recruited,
            state: state,
            affinity: affinity,
            quest_flags: quest_flags,
            dialogue_history: dialogue_history,
            relationship_stage: relationship_stage,
            carrying_torch: carrying_torch,
            torch_time_remaining: torch_time_remaining,
            torch_light_radius: torch_light_radius,
            triggers: triggers_data,
            auras: auras_data
        });
    }

    return companions_array;
}

/// @function serialize_inventory()
/// @description Serialize inventory and equipped items
function serialize_inventory() {
    var player = obj_player;

    // Serialize inventory array - store item IDs and counts
    var inventory_array = [];
    for (var i = 0; i < array_length(player.inventory); i++) {
        var item = player.inventory[i];
        array_push(inventory_array, {
            item_id: item.definition.item_id,
            count: item.count,
            durability: item.durability
        });
    }

    // Serialize equipped items - store item IDs or undefined
    var equipped_data = {
        right_hand: (player.equipped.right_hand != undefined) ? player.equipped.right_hand.definition.item_id : undefined,
        left_hand: (player.equipped.left_hand != undefined) ? player.equipped.left_hand.definition.item_id : undefined,
        head: (player.equipped.head != undefined) ? player.equipped.head.definition.item_id : undefined,
        torso: (player.equipped.torso != undefined) ? player.equipped.torso.definition.item_id : undefined,
        legs: (player.equipped.legs != undefined) ? player.equipped.legs.definition.item_id : undefined
    };

    return {
        inventory: inventory_array,
        equipped: equipped_data
    };
}

/// @function serialize_enemies()
/// @description Serialize all enemies in current room
function serialize_enemies() {
    var enemies_array = [];

    var enemy_count = instance_number(obj_enemy_parent);
    show_debug_message("Serializing enemies in room " + room_get_name(room) + " - Found " + string(enemy_count) + " enemies");

    with (obj_enemy_parent) {
        // Skip enemies that don't have required properties (probably being destroyed)
        if (!variable_instance_exists(id, "hp") || !variable_instance_exists(id, "hp_max")) {
            show_debug_message("Skipping enemy without hp properties: " + object_get_name(object_index));
            continue;
        }

        show_debug_message("  Serializing enemy: " + object_get_name(object_index) + " at (" + string(x) + ", " + string(y) + ") HP: " + string(hp) + "/" + string(hp_max));

        // Serialize traits with stacks
        var traits_array = [];
        if (variable_instance_exists(id, "permanent_traits")) {
            var _perm_names = variable_struct_get_names(permanent_traits);
            for (var i = 0; i < array_length(_perm_names); i++) {
                var _trait_name = _perm_names[i];
                array_push(traits_array, {
                    trait_name: _trait_name,
                    stacks: permanent_traits[$ _trait_name]
                });
            }
        }
        if (variable_instance_exists(id, "temporary_traits")) {
            var _temp_names = variable_struct_get_names(temporary_traits);
            for (var i = 0; i < array_length(_temp_names); i++) {
                var _trait_name = _temp_names[i];
                array_push(traits_array, {
                    trait_name: _trait_name,
                    stacks: temporary_traits[$ _trait_name],
                    is_temporary: true
                });
            }
        }

        // Serialize timed traits
        var timed_traits_array = [];
        if (variable_instance_exists(id, "timed_traits") && is_array(timed_traits)) {
            for (var i = 0; i < array_length(timed_traits); i++) {
                var timed_entry = timed_traits[i];
                array_push(timed_traits_array, {
                    trait: timed_entry.trait,
                    remaining_seconds: (timed_entry.timer ?? 0) / game_get_speed(gamespeed_fps),
                    total_seconds: (timed_entry.total_duration ?? timed_entry.timer ?? 0) / game_get_speed(gamespeed_fps),
                    stacks: timed_entry.stacks_applied
                });
            }
        }

        // Serialize tags
        var tags_array = [];
        if (variable_instance_exists(id, "tags") && is_array(tags)) {
            tags_array = tags;
        }

        array_push(enemies_array, {
            object_type: object_get_name(object_index),
            x: x,
            y: y,
            hp: hp,
            hp_max: hp_max,
            state: variable_instance_exists(id, "state") ? state : 0,
            facing_dir: variable_instance_exists(id, "facing_dir") ? facing_dir : "down",
            traits: traits_array,
            tags: tags_array,
            timed_traits: timed_traits_array
        });
    }

    return enemies_array;
}

/// @function deserialize_player(data)
/// @description Restore player data from save struct
/// @param {struct} data The player data struct
function deserialize_player(data) {
    var player = obj_player;

    // Restore basic properties
    player.x = data.x;
    player.y = data.y;
    player.hp = data.hp;
    player.hp_total = data.hp_total;
    player.xp = data.xp;
    player.level = data.level;
    player.facing_dir = data.facing_dir;
    player.state = data.state;
    player.dash_cooldown = data.dash_cooldown;

    // Restore torch state (if present in save data)
    if (variable_struct_exists(data, "torch_active")) {
        player.torch_active = data.torch_active;
    } else {
        player.torch_active = false;
    }

    if (variable_struct_exists(data, "torch_time_remaining")) {
        player.torch_time_remaining = clamp(data.torch_time_remaining, 0, player.torch_duration);
    } else {
        player.torch_time_remaining = 0;
    }

    player_stop_torch_loop();

    if (player.torch_active) {
        set_torch_carrier("player");
    } else {
        set_torch_carrier("none");
    }

    if (!player.torch_active) {
        player.torch_time_remaining = 0;
    }

    // Restore tags
    player.tags = data.tags;

    // Restore traits
    player.permanent_traits = {};
    player.temporary_traits = {};
    for (var i = 0; i < array_length(data.traits); i++) {
        var trait_data = data.traits[i];
        var is_temp = trait_data[$ "is_temporary"] ?? false;

        if (is_temp) {
            player.temporary_traits[$ trait_data.trait_name] = trait_data.stacks;
        } else {
            player.permanent_traits[$ trait_data.trait_name] = trait_data.stacks;
        }
    }

    // Restore timed traits
    player.timed_traits = [];
    if (variable_struct_exists(data, "timed_traits")) {
        for (var tt = 0; tt < array_length(data.timed_traits); tt++) {
            var saved_trait = data.timed_traits[tt];
            var trait_key = saved_trait.trait;
            var stacks = saved_trait.stacks ?? 1;
            var total_seconds = saved_trait.total_seconds ?? saved_trait.remaining_seconds ?? 0;
            var remaining_seconds = saved_trait.remaining_seconds ?? total_seconds;

            if (trait_key == undefined || trait_key == "") continue;
            if (total_seconds <= 0) continue;

            apply_timed_trait(trait_key, total_seconds, stacks);

            var _last_idx = array_length(player.timed_traits) - 1;
            if (_last_idx >= 0) {
                player.timed_traits[_last_idx].timer = round(max(0, remaining_seconds) * game_get_speed(gamespeed_fps));
                player.timed_traits[_last_idx].total_duration = round(max(0, total_seconds) * game_get_speed(gamespeed_fps));
            }
        }
    }
}

/// @function deserialize_companions(data)
/// @description Restore or recreate companions from save data
/// @param {array} data Array of companion data structs
function deserialize_companions(data) {
    // First, destroy any existing companions
    with (obj_companion_parent) {
        instance_destroy();
    }

    // Recreate companions from saved data
    for (var i = 0; i < array_length(data); i++) {
        var comp_data = data[i];

        // Determine which companion object to create
        var companion_obj = noone;
        switch (comp_data.companion_id) {
            case "canopy":
                companion_obj = obj_canopy;
                break;
            // Add other companions as they're implemented
            default:
                show_debug_message("Warning: Unknown companion_id: " + comp_data.companion_id);
                continue;
        }

        // Create companion instance
        var companion = instance_create_depth(comp_data.x, comp_data.y, -100, companion_obj);

        // Restore companion properties
        companion.is_recruited = comp_data.is_recruited;
        companion.state = comp_data.state;
        companion.affinity = comp_data.affinity;
        companion.quest_flags = comp_data.quest_flags;
        companion.dialogue_history = comp_data.dialogue_history;
        companion.relationship_stage = comp_data.relationship_stage;

        var _torch_stats = global.item_database.torch.stats;
        if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
            companion.torch_light_radius = _torch_stats[$ "light_radius"];
        }

        // Set follow target if recruited
        if (companion.is_recruited && instance_exists(obj_player)) {
            companion.follow_target = obj_player;
        }

        // Restore triggers
        var trigger_names = variable_struct_get_names(comp_data.triggers);
        for (var j = 0; j < array_length(trigger_names); j++) {
            var trigger_name = trigger_names[j];
            var trigger_data = comp_data.triggers[$ trigger_name];

            if (variable_struct_exists(companion.triggers, trigger_name)) {
                companion.triggers[$ trigger_name].unlocked = trigger_data.unlocked;
                companion.triggers[$ trigger_name].cooldown = trigger_data.cooldown;
                companion.triggers[$ trigger_name].active = trigger_data.active;
            }
        }

        // Restore auras
        var aura_names = variable_struct_get_names(comp_data.auras);
        for (var j = 0; j < array_length(aura_names); j++) {
            var aura_name = aura_names[j];
            var aura_data = comp_data.auras[$ aura_name];

            if (variable_struct_exists(companion.auras, aura_name)) {
                companion.auras[$ aura_name].active = aura_data.active;
            }
        }

        // Restore torch state
        if (variable_struct_exists(comp_data, "carrying_torch") && comp_data.carrying_torch) {
            companion.carrying_torch = true;
            var _torch_time = companion.torch_duration;
            if (variable_struct_exists(comp_data, "torch_time_remaining")) {
                _torch_time = comp_data.torch_time_remaining;
            }
            companion.torch_time_remaining = clamp(_torch_time, 0, companion.torch_duration);

            if (variable_struct_exists(comp_data, "torch_light_radius")) {
                companion.torch_light_radius = comp_data.torch_light_radius;
            }

            with (companion) {
                companion_stop_torch_loop();
                companion_start_torch_loop();
                if (audio_emitter_exists(torch_sound_emitter)) {
                    audio_emitter_position(torch_sound_emitter, x, y, 0);
                }
            }
            set_torch_carrier(companion.companion_id);
        } else {
            companion.carrying_torch = false;
            companion.torch_time_remaining = 0;
            with (companion) {
                companion_stop_torch_loop();
            }
        }
    }
}

/// @function deserialize_inventory(data)
/// @description Restore inventory and re-equip items
/// @param {struct} data Inventory data struct
function deserialize_inventory(data) {
    var player = obj_player;

    // Clear current inventory
    player.inventory = [];

    // Restore inventory items
    for (var i = 0; i < array_length(data.inventory); i++) {
        var item_data = data.inventory[i];
        var item_def = global.item_database[$ item_data.item_id];

        if (item_def != undefined) {
            var item_instance = {
                definition: item_def,
                count: item_data.count,
                durability: item_data.durability
            };
            array_push(player.inventory, item_instance);
        } else {
            show_debug_message("Warning: Unknown item_id in save: " + item_data.item_id);
        }
    }

    // Unequip all current items (without removing wielder effects yet)
    player.equipped = {
        right_hand: undefined,
        left_hand: undefined,
        head: undefined,
        torso: undefined,
        legs: undefined
    };

    // Re-equip items from save data
    // NOTE: We don't apply wielder effects here because player status effects
    // are already restored from the save file (including permanent wielder effects)
    var slot_names = ["right_hand", "left_hand", "head", "torso", "legs"];
    for (var i = 0; i < array_length(slot_names); i++) {
        var slot = slot_names[i];
        var item_id = data.equipped[$ slot];

        if (item_id != undefined) {
            var item_def = global.item_database[$ item_id];
            if (item_def != undefined) {
                // Create inventory item instance (matching your inventory structure)
                var item_instance = {
                    definition: item_def,
                    count: 1,
                    durability: 100
                };
                player.equipped[$ slot] = item_instance;

                // DON'T call apply_wielder_effects() here - traits/timed effects already restored!
            }
        }
    }
}

/// @function deserialize_enemies(data)
/// @description Spawn enemies from saved data
/// @param {array} data Array of enemy data structs
function deserialize_enemies(data) {
    show_debug_message("Deserializing enemies. Count: " + string(array_length(data)));

    // First, destroy all existing enemies in room
    with (obj_enemy_parent) {
        show_debug_message("Destroying existing enemy: " + object_get_name(object_index));
        instance_destroy();
    }

    // Spawn enemies from saved data
    for (var i = 0; i < array_length(data); i++) {
        var enemy_data = data[i];

        // Get object index from name
        var obj_index = asset_get_index(enemy_data.object_type);
        if (obj_index == -1) {
            show_debug_message("Warning: Unknown enemy object type: " + enemy_data.object_type);
            continue;
        }

        show_debug_message("Spawning enemy: " + enemy_data.object_type + " at (" + string(enemy_data.x) + ", " + string(enemy_data.y) + ") HP: " + string(enemy_data.hp) + "/" + string(enemy_data.hp_max));

        // Create enemy instance
        var enemy = instance_create_depth(enemy_data.x, enemy_data.y, -50, obj_index);

        // Restore basic properties
        enemy.hp = enemy_data.hp;
        enemy.hp_max = enemy_data.hp_max;
        enemy.state = enemy_data.state;
        enemy.facing_dir = enemy_data.facing_dir;
        enemy.tags = enemy_data.tags;

        // Restore traits
        enemy.permanent_traits = {};
        enemy.temporary_traits = {};
        for (var j = 0; j < array_length(enemy_data.traits); j++) {
            var trait_data = enemy_data.traits[j];
            var is_temp = trait_data[$ "is_temporary"] ?? false;

            if (is_temp) {
                enemy.temporary_traits[$ trait_data.trait_name] = trait_data.stacks;
            } else {
                enemy.permanent_traits[$ trait_data.trait_name] = trait_data.stacks;
            }
        }

        // Restore timed traits
        enemy.timed_traits = [];
        if (variable_struct_exists(enemy_data, "timed_traits")) {
            for (var j = 0; j < array_length(enemy_data.timed_traits); j++) {
                var saved = enemy_data.timed_traits[j];
                var trait_key = saved.trait;
                var stacks = saved.stacks ?? 1;
                var total_seconds = saved.total_seconds ?? saved.remaining_seconds ?? 0;
                var remaining_seconds = saved.remaining_seconds ?? total_seconds;

                if (trait_key == undefined || trait_key == "") continue;
                if (total_seconds <= 0) continue;

                with (enemy) {
                    apply_timed_trait(trait_key, total_seconds, stacks);
                    var _idx = array_length(timed_traits) - 1;
                    if (_idx >= 0) {
                        timed_traits[_idx].timer = round(max(0, remaining_seconds) * game_get_speed(gamespeed_fps));
                        timed_traits[_idx].total_duration = round(max(0, total_seconds) * game_get_speed(gamespeed_fps));
                    }
                }
            }
        }
    }
}

// ============================================
// QUEST SYSTEM FUNCTIONS
// ============================================

/// @function set_quest_flag(key, value)
/// @description Set a boolean quest flag
/// @param {string} key The quest flag identifier
/// @param {bool} value The flag value (true/false)
function set_quest_flag(key, value) {
    global.quest_flags[$ key] = value;
    show_debug_message("Quest flag set: " + key + " = " + string(value));
}

/// @function get_quest_flag(key)
/// @description Get a boolean quest flag (returns false if not set)
/// @param {string} key The quest flag identifier
/// @return {bool} The flag value
function get_quest_flag(key) {
    if (variable_struct_exists(global.quest_flags, key)) {
        return global.quest_flags[$ key];
    }
    return false;
}

/// @function increment_quest_counter(key, amount)
/// @description Increment a numeric quest counter
/// @param {string} key The quest counter identifier
/// @param {real} amount The amount to increment by (default 1)
function increment_quest_counter(key, amount = 1) {
    if (variable_struct_exists(global.quest_counters, key)) {
        global.quest_counters[$ key] += amount;
    } else {
        global.quest_counters[$ key] = amount;
    }
    show_debug_message("Quest counter updated: " + key + " = " + string(global.quest_counters[$ key]));
}

/// @function get_quest_counter(key)
/// @description Get a numeric quest counter (returns 0 if not set)
/// @param {string} key The quest counter identifier
/// @return {real} The counter value
function get_quest_counter(key) {
    if (variable_struct_exists(global.quest_counters, key)) {
        return global.quest_counters[$ key];
    }
    return 0;
}

/// @function set_quest_counter(key, value)
/// @description Set a numeric quest counter to a specific value
/// @param {string} key The quest counter identifier
/// @param {real} value The value to set
function set_quest_counter(key, value) {
    global.quest_counters[$ key] = value;
    show_debug_message("Quest counter set: " + key + " = " + string(value));
}

/// @function serialize_quest_data()
/// @description Serialize quest flags and counters to structs for JSON saving
/// @return {struct} Struct containing quest_flags and quest_counters
function serialize_quest_data() {
    return {
        quest_flags: global.quest_flags,
        quest_counters: global.quest_counters
    };
}

/// @function deserialize_quest_data(data)
/// @description Restore quest flags and counters from save data
/// @param {struct} data The quest data struct
function deserialize_quest_data(data) {
    global.quest_flags = data.quest_flags;
    global.quest_counters = data.quest_counters;

    show_debug_message("Quest data restored:");
    show_debug_message("  Flags: " + string(variable_struct_names_count(global.quest_flags)));
    show_debug_message("  Counters: " + string(variable_struct_names_count(global.quest_counters)));
}

// ============================================
// ROOM STATE PERSISTENCE FUNCTIONS
// ============================================

/// @function serialize_room_state(room_index)
/// @description Serialize the current room's state for persistence
/// @param {real} room_index The room to serialize (use 'room' for current room)
/// @return {struct} Room state data
function serialize_room_state(room_index) {
    // Serialize ALL persistent objects (enemies, items, etc.)
    var instances_array = [];
    var saved_count = 0;

    with (obj_persistent_parent) {
        // Skip the player - they're handled separately and are already persistent
        if (object_index == obj_player) {
            continue;
        }

        // Skip companions - they're handled by room transition companion spawning
        if (object_index == obj_companion_parent || object_is_ancestor(object_index, obj_companion_parent)) {
            continue;
        }

        array_push(instances_array, serialize());
        saved_count++;
    }

    show_debug_message("Serialized " + string(saved_count) + " persistent objects in room " + room_get_name(room_index));

    // Serialize party controllers
    var party_controllers_array = [];
    with (obj_enemy_party_controller) {
        array_push(party_controllers_array, serialize_party_data());
    }

    if (array_length(party_controllers_array) > 0) {
        show_debug_message("Serialized " + string(array_length(party_controllers_array)) + " party controllers");
    }

    var room_data = {
        room_index: room_index,
        instances: instances_array,
        party_controllers: party_controllers_array
    };

    // TODO: Add puzzle state tracking here when puzzle system is implemented
    // room_data.puzzle_state = serialize_puzzle_state();

    return room_data;
}

/// @function deserialize_room_state(room_index)
/// @description Restore a room's state from saved data
/// @param {real} room_index The room to restore
function deserialize_room_state(room_index) {
    var room_key = string(room_index);

    if (!variable_struct_exists(global.room_states, room_key)) {
        show_debug_message("No saved state for room " + room_get_name(room_index));
        return false;
    }

    var room_data = global.room_states[$ room_key];

    show_debug_message("Restoring room state for room " + room_get_name(room_index));
    show_debug_message("  Restoring " + string(array_length(room_data.instances)) + " persistent objects");

    // Destroy ALL existing persistent objects (except player)
    with (obj_persistent_parent) {
        if (object_index != obj_player) {
            instance_destroy();
        }
    }

    // Build enemy lookup table for party controller linkage
    var enemy_lookup = {};

    // Recreate all persistent objects from saved data
    for (var i = 0; i < array_length(room_data.instances); i++) {
        var inst_data = room_data.instances[i];
        var obj_index = asset_get_index(inst_data.object_type);

        if (obj_index == -1) {
            show_debug_message("Warning: Unknown object type: " + inst_data.object_type);
            continue;
        }

        show_debug_message("  Spawning: " + inst_data.object_type + " at (" + string(inst_data.x) + ", " + string(inst_data.y) + ")");

        // Create instance
        var inst = instance_create_depth(inst_data.x, inst_data.y, -50, obj_index);

        // Restore its state
        inst.deserialize(inst_data);

        // Add to enemy lookup if it's an enemy
        if (object_is_ancestor(obj_index, obj_enemy_parent) || obj_index == obj_enemy_parent) {
            enemy_lookup[$ inst_data.persistent_id] = inst;
        }
    }

    // Restore party controllers (must happen AFTER enemies are restored)
    if (variable_struct_exists(room_data, "party_controllers")) {
        show_debug_message("  Restoring " + string(array_length(room_data.party_controllers)) + " party controllers");

        for (var i = 0; i < array_length(room_data.party_controllers); i++) {
            var party_data = room_data.party_controllers[i];

            // Create party controller instance
            var controller = instance_create_depth(party_data.controller_x, party_data.controller_y, -50, obj_enemy_party_controller);

            // Restore party state
            controller.deserialize_party_data(party_data, enemy_lookup);

            show_debug_message("  Restored party controller with " + string(array_length(controller.party_members)) + " members");
        }
    }

    // TODO: Restore puzzle state when puzzle system is implemented
    // deserialize_puzzle_state(room_data.puzzle_state);

    show_debug_message("Room state restored successfully");
    return true;
}

/// @function save_current_room_state()
/// @description Save the current room's state before leaving
function save_current_room_state() {
    var room_key = string(room);

    // Add to visited rooms if not already there
    var already_visited = false;
    for (var i = 0; i < array_length(global.visited_rooms); i++) {
        if (global.visited_rooms[i] == room) {
            already_visited = true;
            break;
        }
    }

    if (!already_visited) {
        array_push(global.visited_rooms, room);
    }

    // Save room state
    global.room_states[$ room_key] = serialize_room_state(room);

    show_debug_message("Saved state for room: " + room_get_name(room));
}

/// @function restore_room_state_if_visited()
/// @description Restore room state if this room has been visited before
function restore_room_state_if_visited() {
    var room_key = string(room);

    if (variable_struct_exists(global.room_states, room_key)) {
        deserialize_room_state(room);
        show_debug_message("Restored previously visited room: " + room_get_name(room));
    } else {
        show_debug_message("First visit to room: " + room_get_name(room));
        // Reset tracking arrays for new room
        global.opened_chests = [];
        global.broken_breakables = [];
        global.picked_up_items = [];
    }
}

// ============================================
// SAVE/LOAD CORE FUNCTIONS
// ============================================

/// @function save_game(slot)
/// @description Save the complete game state to a JSON file
/// @param {real} slot The save slot number (1-5) or "autosave" for auto-save
function save_game(slot) {
    show_debug_message("=== SAVING GAME TO SLOT " + string(slot) + " ===");

    // Update current room state before saving
    var room_key = string(room);
    show_debug_message("Updating current room state before save: " + room_get_name(room));
    global.room_states[$ room_key] = serialize_room_state(room);

    // Build root save struct
    var save_data = {
        save_version: 1,
        timestamp: current_time,
        current_room: room,

        // Serialize all game state
        player: serialize_player(),
        companions: serialize_companions(),
        inventory: serialize_inventory(),
        quest_data: serialize_quest_data(),
        room_states: global.room_states,
        visited_rooms: global.visited_rooms,

        // VN intro system
        vn_intro_seen: global.vn_intro_seen,

        // Chatterbox dialogue variables
        chatterbox_vars: ChatterboxVariablesExport()
    };

    // Convert to JSON
    var json_string = json_stringify(save_data);

    // Determine filename
    var filename = (slot == "autosave") ? "autosave.json" : ("save_slot_" + string(slot) + ".json");

    // Write to file
    try {
        var file = file_text_open_write(filename);
        file_text_write_string(file, json_string);
        file_text_close(file);

        show_debug_message("Game saved successfully to: " + filename);
        show_debug_message("  Save version: 1");
        show_debug_message("  Current room: " + room_get_name(room));
        show_debug_message("  Player HP: " + string(obj_player.hp) + "/" + string(obj_player.hp_total));
        show_debug_message("  Companions: " + string(array_length(save_data.companions)));
        show_debug_message("  Inventory items: " + string(array_length(save_data.inventory.inventory)));
        show_debug_message("  Visited rooms: " + string(array_length(save_data.visited_rooms)));

        return true;
    } catch (error) {
        show_debug_message("ERROR: Failed to save game to " + filename);
        show_debug_message("Error: " + string(error));
        return false;
    }
}

/// @function load_game(slot)
/// @description Load the complete game state from a JSON file
/// @param {real} slot The save slot number (1-5) or "autosave" for auto-save
function load_game(slot) {
    show_debug_message("=== LOADING GAME FROM SLOT " + string(slot) + " ===");

    // Determine filename
    var filename = (slot == "autosave") ? "autosave.json" : ("save_slot_" + string(slot) + ".json");

    // Check if save file exists
    if (!file_exists(filename)) {
        show_debug_message("ERROR: Save file does not exist: " + filename);
        return false;
    }

    try {
        // Read JSON file
        var file = file_text_open_read(filename);
        var json_string = "";

        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }

        file_text_close(file);

        // Parse JSON
        var save_data = json_parse(json_string);

        // Check save version
        if (save_data.save_version != 1) {
            show_debug_message("WARNING: Save file version mismatch. Expected 1, got " + string(save_data.save_version));
            show_debug_message("Attempting to load anyway...");
        }

        show_debug_message("Save file loaded successfully");
        show_debug_message("  Save version: " + string(save_data.save_version));
        show_debug_message("  Timestamp: " + string(save_data.timestamp));
        show_debug_message("  Saved room: " + room_get_name(save_data.current_room));

        // Set loading flag for visual feedback
        global.is_loading = true;

        // Check if we need to transition to a different room
        if (room != save_data.current_room) {
            show_debug_message("Room transition needed: " + room_get_name(room) + " -> " + room_get_name(save_data.current_room));

            // Store save data globally for restoration after room transition
            global.pending_save_data = save_data;

            // Transition to the saved room with white fade
            transition_start(save_data.current_room, seq_fade_out_white, seq_fade_in_white);

            // Restoration will happen in Room Start event
            return true;
        }

        // If we're already in the correct room, use fade transition
        show_debug_message("Already in correct room - using fade transition");

        // Store save data for restore during transition
        global.pending_save_data = save_data;

        // Use transition system (will restore in transition_change_room)
        transition_start(room, seq_fade_out_white, seq_fade_in_white);

        return true;

    } catch (error) {
        show_debug_message("ERROR: Failed to load game from " + filename);
        show_debug_message("Error: " + string(error));
        return false;
    }
}

/// @function restore_save_data(save_data)
/// @description Restore game state from parsed save data
/// @param {struct} save_data The parsed save data
function restore_save_data(save_data) {
    show_debug_message("=== RESTORING GAME STATE ===");

    // Restore player data
    deserialize_player(save_data.player);
    show_debug_message("Player restored");

    // Restore companions
    deserialize_companions(save_data.companions);
    show_debug_message("Companions restored: " + string(array_length(save_data.companions)));

    // Restore inventory
    deserialize_inventory(save_data.inventory);
    show_debug_message("Inventory restored");

    with (obj_player) {
        if (torch_active) {
            player_stop_torch_loop();
            player_start_torch_loop();
            if (audio_emitter_exists(torch_sound_emitter)) {
                audio_emitter_position(torch_sound_emitter, x, y, 0);
            }
        }
    }

    // Restore quest data
    deserialize_quest_data(save_data.quest_data);
    show_debug_message("Quest data restored");

    // Restore room states
    global.room_states = save_data.room_states;
    global.visited_rooms = save_data.visited_rooms;
    show_debug_message("Room states restored: " + string(variable_struct_names_count(global.room_states)) + " rooms");

    // Restore current room state
    restore_room_state_if_visited();

    // Restore VN intro seen flags
    if (variable_struct_exists(save_data, "vn_intro_seen")) {
        global.vn_intro_seen = save_data.vn_intro_seen;
        var _seen_count = variable_struct_names_count(global.vn_intro_seen);
        show_debug_message("VN intro seen flags restored: " + string(_seen_count) + " intros");
    } else {
        global.vn_intro_seen = {};
        show_debug_message("No VN intro data in save file (older save)");
    }

    // Restore Chatterbox variables
    if (variable_struct_exists(save_data, "chatterbox_vars")) {
        ChatterboxVariablesImport(save_data.chatterbox_vars);
        show_debug_message("Chatterbox variables restored");
    }

    // Clear pending save data
    if (variable_global_exists("pending_save_data")) {
        global.pending_save_data = undefined;
    }

    show_debug_message("=== GAME STATE RESTORED SUCCESSFULLY ===");

    // Clear loading flag
    global.is_loading = false;
}

/// @function check_for_pending_save_restore()
/// @description Check if there's a pending save to restore after room transition
/// Call this in obj_game_controller Room Start event
function check_for_pending_save_restore() {
    if (variable_global_exists("pending_save_data") && global.pending_save_data != undefined) {
        show_debug_message("Pending save data detected - restoring now");
        restore_save_data(global.pending_save_data);
    }
}

// ============================================
// AUTO-SAVE SYSTEM
// ============================================

/// @function auto_save()
/// @description Automatically save the game to the autosave slot
function auto_save() {
    return save_game("autosave");
}

// ============================================
// SAVE/LOAD MENU HELPER FUNCTIONS
// ============================================

/// @function get_save_slot_metadata(slot)
/// @description Extract metadata from a save file without loading the full game
/// @param {real|string} slot Slot number (1-5) or "autosave"
/// @return {struct|undefined} Metadata struct or undefined if file doesn't exist
function get_save_slot_metadata(slot) {
    var filename = (slot == "autosave") ? "autosave.json" : ("save_slot_" + string(slot) + ".json");

    if (!file_exists(filename)) {
        return undefined;
    }

    try {
        // Read JSON file
        var file = file_text_open_read(filename);
        var json_string = "";

        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }

        file_text_close(file);

        // Parse JSON
        var save_data = json_parse(json_string);

        // Extract metadata
        var metadata = {
            exists: true,
            timestamp: save_data.timestamp,
            current_room: save_data.current_room,
            room_name: room_get_name(save_data.current_room),
            player_level: save_data.player.level,
            player_hp: save_data.player.hp,
            player_hp_total: save_data.player.hp_total,
            player_xp: save_data.player.xp,
            save_version: save_data.save_version
        };

        return metadata;

    } catch (error) {
        show_debug_message("Error reading save slot " + string(slot) + ": " + string(error));
        return undefined;
    }
}

/// @function format_time_ago(timestamp)
/// @description Format timestamp into readable "X ago" string
/// @param {real} timestamp GameMaker timestamp value (from current_time)
/// @return {string} Formatted time string
function format_time_ago(timestamp) {
    var diff_ms = current_time - timestamp;
    var diff_seconds = diff_ms / 1000;

    if (diff_seconds < 60) {
        return "Just now";
    } else if (diff_seconds < 3600) {
        var mins = floor(diff_seconds / 60);
        return string(mins) + " min" + (mins == 1 ? "" : "s") + " ago";
    } else if (diff_seconds < 86400) {
        var hours = floor(diff_seconds / 3600);
        return string(hours) + " hour" + (hours == 1 ? "" : "s") + " ago";
    } else {
        var days = floor(diff_seconds / 86400);
        return string(days) + " day" + (days == 1 ? "" : "s") + " ago";
    }
}
