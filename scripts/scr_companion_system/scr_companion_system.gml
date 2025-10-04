// ============================================
// COMPANION SYSTEM - Helper functions for companion management
// ============================================

/// @function get_active_companions()
/// @description Returns array of active companion instances
function get_active_companions() {
    var companions = [];
    with (obj_companion_parent) {
        if (is_recruited && state == CompanionState.following) {
            array_push(companions, id);
        }
    }
    // show_debug_message("get_active_companions returned " + string(array_length(companions)) + " companions");
    return companions;
}

/// @function get_companion_melee_dr_bonus()
/// @description Calculate total melee DR bonus from all active companions
function get_companion_melee_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check all auras for melee DR bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // General DR applies to melee
                if (variable_struct_exists(_aura, "damage_reduction")) {
                    total_dr += _aura.damage_reduction;
                }
                // Melee-specific DR
                if (variable_struct_exists(_aura, "melee_damage_reduction")) {
                    total_dr += _aura.melee_damage_reduction;
                }
            }
        }

        // Check triggers for melee DR bonuses
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger_name = _trigger_names[j];
            var _trigger = companion.triggers[$ _trigger_name];

            if (_trigger.active) {
                if (variable_struct_exists(_trigger, "damage_reduction")) {
                    total_dr += _trigger.damage_reduction;
                }
                if (variable_struct_exists(_trigger, "melee_damage_reduction")) {
                    total_dr += _trigger.melee_damage_reduction;
                }
            }
        }
    }

    return total_dr;
}

/// @function get_companion_ranged_dr_bonus()
/// @description Calculate total ranged DR bonus from all active companions
function get_companion_ranged_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check all auras for ranged DR bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // General DR applies to ranged
                if (variable_struct_exists(_aura, "damage_reduction")) {
                    total_dr += _aura.damage_reduction;
                }
                // Ranged-specific DR (Hola's wind_ward uses this)
                if (variable_struct_exists(_aura, "ranged_damage_reduction")) {
                    total_dr += _aura.ranged_damage_reduction;
                }
            }
        }

        // Check triggers for ranged DR bonuses
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger_name = _trigger_names[j];
            var _trigger = companion.triggers[$ _trigger_name];

            if (_trigger.active) {
                if (variable_struct_exists(_trigger, "damage_reduction")) {
                    total_dr += _trigger.damage_reduction;
                }
                if (variable_struct_exists(_trigger, "ranged_damage_reduction")) {
                    total_dr += _trigger.ranged_damage_reduction;
                }
            }
        }
    }

    return total_dr;
}

/// @function apply_companion_regeneration_auras(player_instance)
/// @description Apply HP regeneration from companion auras
/// @param {instance} player_instance The player to heal
function apply_companion_regeneration_auras(player_instance) {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Apply regeneration aura (only if companion has this aura)
        if (variable_struct_exists(companion.auras, "regeneration") && companion.auras.regeneration.active) {
            if (!variable_instance_exists(player_instance, "companion_regen_timer")) {
                player_instance.companion_regen_timer = 0;
            }

            player_instance.companion_regen_timer++;

            if (player_instance.companion_regen_timer >= companion.auras.regeneration.tick_interval) {
                player_instance.hp = min(
                    player_instance.hp + companion.auras.regeneration.hp_per_tick,
                    player_instance.hp_total
                );
                player_instance.companion_regen_timer = 0;
            }
        }
    }
}

/// @function evaluate_companion_triggers(player_instance)
/// @description Check and activate companion triggers based on game state
/// @param {instance} player_instance The player to check conditions for
function evaluate_companion_triggers(player_instance) {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // CANOPY: Shield Trigger - Activate when player HP is low
        if (variable_struct_exists(companion.triggers, "shield")) {
            if (companion.triggers.shield.unlocked &&
                !companion.triggers.shield.active &&
                companion.triggers.shield.cooldown == 0) {

                var hp_percent = player_instance.hp / player_instance.hp_total;

                if (hp_percent <= companion.triggers.shield.hp_threshold) {
                    companion.triggers.shield.active = true;
                    companion.triggers.shield.cooldown = companion.triggers.shield.cooldown_max;
                    companion.shield_timer = companion.triggers.shield.duration;
                    spawn_floating_text(player_instance.x, player_instance.bbox_top - 10, "Shield!", c_aqua, player_instance);
                }
            }

            // Update shield duration
            if (companion.triggers.shield.active) {
                if (!variable_instance_exists(companion, "shield_timer")) companion.shield_timer = 0;
                companion.shield_timer--;
                if (companion.shield_timer <= 0) companion.triggers.shield.active = false;
            }
        }

        // CANOPY: Guardian Veil - Activate when surrounded
        if (variable_struct_exists(companion.triggers, "guardian_veil")) {
            if (companion.triggers.guardian_veil.unlocked &&
                !companion.triggers.guardian_veil.active &&
                companion.triggers.guardian_veil.cooldown == 0) {

                var nearby_enemies = 0;
                with (obj_enemy_parent) {
                    if (state != EnemyState.dead &&
                        point_distance(x, y, player_instance.x, player_instance.y) < 64) {
                        nearby_enemies++;
                    }
                }

                if (nearby_enemies >= companion.triggers.guardian_veil.enemy_threshold) {
                    companion.triggers.guardian_veil.active = true;
                    companion.triggers.guardian_veil.cooldown = companion.triggers.guardian_veil.cooldown_max;
                    companion.guardian_veil_timer = companion.triggers.guardian_veil.duration;
                }
            }

            // Update guardian veil duration
            if (companion.triggers.guardian_veil.active) {
                if (!variable_instance_exists(companion, "guardian_veil_timer")) companion.guardian_veil_timer = 0;
                companion.guardian_veil_timer--;
                if (companion.guardian_veil_timer <= 0) companion.triggers.guardian_veil.active = false;
            }
        }

        // HOLA: Gust - Push back nearby enemies
        if (variable_struct_exists(companion.triggers, "gust")) {
            if (companion.triggers.gust.unlocked &&
                !companion.triggers.gust.active &&
                companion.triggers.gust.cooldown == 0) {

                var nearby_enemies = 0;
                with (obj_enemy_parent) {
                    if (state != EnemyState.dead &&
                        point_distance(x, y, player_instance.x, player_instance.y) < companion.triggers.gust.trigger_distance) {
                        nearby_enemies++;
                    }
                }

                if (nearby_enemies >= companion.triggers.gust.enemy_threshold) {
                    companion.triggers.gust.active = true;
                    companion.triggers.gust.cooldown = companion.triggers.gust.cooldown_max;

                    // Push back enemies
                    with (obj_enemy_parent) {
                        if (state != EnemyState.dead &&
                            point_distance(x, y, player_instance.x, player_instance.y) < companion.triggers.gust.trigger_distance) {
                            var push_dir = point_direction(player_instance.x, player_instance.y, x, y);
                            x += lengthdir_x(companion.triggers.gust.knockback_distance, push_dir);
                            y += lengthdir_y(companion.triggers.gust.knockback_distance, push_dir);
                        }
                    }
                    spawn_floating_text(player_instance.x, player_instance.bbox_top - 10, "Gust!", c_white, player_instance);
                }
            }
        }
    }
}

/// @function recruit_companion(companion_instance, player_instance)
/// @description Recruit a companion to the party
/// @param {instance} companion_instance The companion to recruit
/// @param {instance} player_instance The player recruiting
function recruit_companion(companion_instance, player_instance) {
    with (companion_instance) {
        is_recruited = true;
        state = CompanionState.following;
        follow_target = player_instance;

        // Mark first meeting
        quest_flags.met_player = true;

        // Activate all auras (companions have different aura sets)
        var _aura_names = variable_struct_get_names(auras);
        for (var i = 0; i < array_length(_aura_names); i++) {
            var _aura_name = _aura_names[i];
            auras[$ _aura_name].active = true;
        }

        // Play recruitment sound effect
        play_sfx(snd_companion_recruited, 1, 8, false);

        // Visual feedback
        show_debug_message("✓ " + companion_name + " has joined your party!");
        show_debug_message("  - Activated " + string(array_length(_aura_names)) + " auras");
        show_debug_message("  - is_recruited: " + string(is_recruited));
        show_debug_message("  - state: " + string(state) + " (following=" + string(CompanionState.following) + ")");
        show_debug_message("  - follow_target: " + string(follow_target));

        // Check quest objectives for companion recruitment
        quest_check_companion_recruitment(companion_id);
    }
}

/// @function init_companion_global_data()
/// @description Initialize global companion tracking (call in obj_game_controller)
function init_companion_global_data() {
    if (!variable_global_exists("companion_database")) {
        global.companion_database = {
            canopy: {
                name: "Canopy",
                sprite: spr_canopy,
                description: "A calm, protective healer"
            }
            // More companions added later
        };
    }

    if (!variable_global_exists("active_companions")) {
        global.active_companions = [];
    }
}

/// @function serialize_companion_data(companion_instance)
/// @description Serialize a companion's state for saving
/// @param {instance} companion_instance The companion to serialize
/// @return {struct} Companion data struct
function serialize_companion_data(companion_instance) {
    with (companion_instance) {
        return {
            companion_id: companion_id,
            is_recruited: is_recruited,
            affinity: affinity,
            quest_flags: quest_flags,
            dialogue_history: dialogue_history,
            relationship_stage: relationship_stage,
            spawn_x: x,
            spawn_y: y
        };
    }
}

/// @function serialize_all_companions()
/// @description Serialize all companions in the game for saving
/// @return {struct} All companion data indexed by companion_id
function serialize_all_companions() {
    var companions_data = {};

    with (obj_companion_parent) {
        companions_data[$ companion_id] = serialize_companion_data(id);
    }

    return companions_data;
}

/// @function deserialize_companion_data(companion_instance, data)
/// @description Restore a companion's state from save data (FULLY MODULAR)
/// @param {instance} companion_instance The companion to restore
/// @param {struct} data The saved companion data
function deserialize_companion_data(companion_instance, data) {
    with (companion_instance) {
        is_recruited = data.is_recruited;
        affinity = data.affinity;
        quest_flags = data.quest_flags;
        dialogue_history = data.dialogue_history;
        relationship_stage = data.relationship_stage;
        x = data.spawn_x;
        y = data.spawn_y;

        // If recruited, set up following state and activate all auras
        if (is_recruited) {
            state = CompanionState.following;
            follow_target = obj_player;

            // MODULAR: Activate all auras (companions have different aura sets)
            var _aura_names = variable_struct_get_names(auras);
            for (var i = 0; i < array_length(_aura_names); i++) {
                var _aura_name = _aura_names[i];
                auras[$ _aura_name].active = true;
            }
        }
    }
}

/// @function restore_all_companions(companions_data)
/// @description Restore all companion states from save data
/// @param {struct} companions_data All saved companion data
function restore_all_companions(companions_data) {
    with (obj_companion_parent) {
        if (variable_struct_exists(companions_data, companion_id)) {
            var data = companions_data[$ companion_id];
            deserialize_companion_data(id, data);
        }
    }
}

/// @function companion_receive_torch(companion_instance, time_remaining, light_radius)
/// @description Transfer a lit torch to the given companion instance
/// @param {instance} companion_instance Companion receiving torch
/// @param {real} time_remaining Remaining burn time to inherit
/// @return {bool} True if transfer succeeded
function companion_receive_torch(companion_instance, time_remaining, light_radius) {
    if (companion_instance == undefined) return false;

    with (companion_instance) {
        if (!variable_instance_exists(id, "companion_take_torch_from_player")) {
            return false;
        }
        companion_take_torch_from_player(time_remaining, light_radius);
    }

    return true;
}

/// @function companion_take_torch_function()
/// @description VN dialogue hook: companion takes a torch from player inventory or another companion
function companion_take_torch_function() {
    global.vn_torch_transfer_success = false;
    if (variable_global_exists("ChatterboxVariableSet")) {
        ChatterboxVariableSet("vn_torch_transfer_success", false);
    }

    var _companion = global.vn_companion;
    if (_companion == undefined) return;

    var _player = instance_find(obj_player, 0);
    if (_player == noone) return;

    if (_companion.carrying_torch) {
        global.vn_torch_transfer_success = true;
        if (variable_global_exists("ChatterboxVariableSet")) {
            ChatterboxVariableSet("vn_torch_transfer_success", true);
        }
        return;
    }

    var _carrier = noone;
    with (obj_companion_parent) {
        if (carrying_torch && id != _companion) {
            other._carrier = id;
            exit;
        }
    }

    if (_carrier != noone) {
        with (_carrier) {
            other._torch_transfer_temp = companion_give_torch_to_player();
        }
        var _returned = _torch_transfer_temp;
        _torch_transfer_temp = undefined;

        if (!_returned) {
            return;
        }
    }

    var _has_equipped_torch = false;
    var _inventory_has_torch = false;
    var _remaining = 0;
    var _radius_equipped = 100;

    with (_player) {
        _has_equipped_torch = player_has_equipped_torch() && torch_active;
        _inventory_has_torch = player_has_torch_in_inventory();
        _remaining = torch_time_remaining;
        _radius_equipped = player_get_torch_light_radius();
    }

    if (!_has_equipped_torch && !_inventory_has_torch) return;

    if (_has_equipped_torch) {

        if (companion_receive_torch(_companion, _remaining, _radius_equipped)) {
            with (_player) {
                player_play_torch_sfx("snd_companion_torch_receive");
                player_stop_torch_loop();
                player_remove_torch_from_loadouts();
                torch_active = false;
                torch_time_remaining = 0;
            }
            global.vn_torch_transfer_success = true;
            if (variable_global_exists("ChatterboxVariableSet")) {
                ChatterboxVariableSet("vn_torch_transfer_success", true);
            }
        }
        return;
    }

    var _supplied = false;
    var _torch_duration = 0;

    with (_player) {
        _supplied = player_supply_companion_torch();
        _torch_duration = torch_duration;
    }

    if (!_supplied) return;

    var _torch_stats = global.item_database.torch.stats;
    var _radius = (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius"))
        ? _torch_stats[$ "light_radius"]
        : 100;

    if (companion_receive_torch(_companion, _torch_duration, _radius)) {
        with (_player) {
            player_play_torch_sfx("snd_companion_torch_receive");
        }
        global.vn_torch_transfer_success = true;
        if (variable_global_exists("ChatterboxVariableSet")) {
            ChatterboxVariableSet("vn_torch_transfer_success", true);
        }
    } else {
        // Failed to hand off torch, return it to inventory
        var _torch_def = global.item_database.torch;
        if (_torch_def != undefined) {
            with (_player) {
                inventory_add_item(_torch_def, 1);
            }
        }
    }
}

/// @function companion_stop_carrying_torch_function()
/// @description VN dialogue hook: companion hands torch back to the player
function companion_stop_carrying_torch_function() {
    global.vn_torch_transfer_success = false;
    if (variable_global_exists("ChatterboxVariableSet")) {
        ChatterboxVariableSet("vn_torch_transfer_success", false);
    }

    var _companion = global.vn_companion;
    if (_companion == undefined) return;

    var _player = instance_find(obj_player, 0);
    if (_player == noone) return;

    if (!_companion.carrying_torch) return;

    var _can_receive = false;
    with (_player) {
        _can_receive = player_can_receive_torch();
    }

    if (!_can_receive) return;

    with (_companion) {
        if (companion_give_torch_to_player()) {
            global.vn_torch_transfer_success = true;
            if (variable_global_exists("ChatterboxVariableSet")) {
                ChatterboxVariableSet("vn_torch_transfer_success", true);
            }
        }
    }
}
