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
    return companions;
}

/// @function get_companion_dr_bonus()
/// @description Calculate total DR bonus from all active companions
function get_companion_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Add passive aura DR
        if (companion.auras.protective.active) {
            total_dr += companion.auras.protective.dr_bonus;
        }

        // Add active trigger DR
        if (companion.triggers.shield.active) {
            total_dr += companion.triggers.shield.dr_bonus;
        }
        if (companion.triggers.aegis.active) {
            total_dr += companion.triggers.aegis.dr_bonus;
        }
        if (companion.triggers.guardian_veil.active) {
            total_dr += companion.triggers.guardian_veil.dr_bonus;
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

        // Apply regeneration aura
        if (companion.auras.regeneration.active) {
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

        // Shield Trigger: Activate when player HP is low
        if (companion.triggers.shield.unlocked &&
            !companion.triggers.shield.active &&
            companion.triggers.shield.cooldown == 0) {

            var hp_percent = player_instance.hp / player_instance.hp_total;

            if (hp_percent <= companion.triggers.shield.hp_threshold) {
                companion.triggers.shield.active = true;
                companion.triggers.shield.cooldown = companion.triggers.shield.cooldown_max;

                // Set duration timer
                if (!variable_instance_exists(companion, "shield_timer")) {
                    companion.shield_timer = 0;
                }
                companion.shield_timer = companion.triggers.shield.duration;
            }
        }

        // Update active trigger durations
        if (companion.triggers.shield.active) {
            if (!variable_instance_exists(companion, "shield_timer")) {
                companion.shield_timer = 0;
            }

            companion.shield_timer--;
            if (companion.shield_timer <= 0) {
                companion.triggers.shield.active = false;
            }
        }

        // Guardian Veil Trigger: Activate when surrounded by enemies
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

                if (!variable_instance_exists(companion, "guardian_veil_timer")) {
                    companion.guardian_veil_timer = 0;
                }
                companion.guardian_veil_timer = companion.triggers.guardian_veil.duration;
            }
        }

        // Update guardian veil duration
        if (companion.triggers.guardian_veil.active) {
            if (!variable_instance_exists(companion, "guardian_veil_timer")) {
                companion.guardian_veil_timer = 0;
            }

            companion.guardian_veil_timer--;
            if (companion.guardian_veil_timer <= 0) {
                companion.triggers.guardian_veil.active = false;
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

        // Activate default auras
        auras.protective.active = true;
        auras.regeneration.active = true;

        // Visual feedback
        show_debug_message("✓ " + companion_name + " has joined your party!");
        show_debug_message("  - Protective Aura: +" + string(auras.protective.dr_bonus) + " DR");
        show_debug_message("  - Regeneration: " + string(auras.regeneration.hp_per_tick) + " HP/step");
        show_debug_message("  - is_recruited: " + string(is_recruited));
        show_debug_message("  - state: " + string(state) + " (following=" + string(CompanionState.following) + ")");
        show_debug_message("  - follow_target: " + string(follow_target));
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
/// @description Restore a companion's state from save data
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

        // If recruited, set up following state
        if (is_recruited) {
            state = CompanionState.following;
            follow_target = obj_player;
            auras.protective.active = true;
            auras.regeneration.active = true;
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
