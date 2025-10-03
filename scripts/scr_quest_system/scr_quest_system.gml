// ============================================
// QUEST SYSTEM - Quest database and helper functions
// ============================================

/// @function init_quest_database()
/// @description Initialize the global quest database (call in obj_game_controller Create event)
function init_quest_database() {
    if (!variable_global_exists("quest_database")) {
        global.quest_database = {};

        // ============================================
        // HOLA QUEST 1: Find Yorna
        // ============================================
        global.quest_database.hola_find_yorna = {
            quest_id: "hola_find_yorna",
            quest_name: "Find Yorna",
            quest_giver: "obj_hola",
            objectives: [
                {
                    type: "recruit_companion",
                    target: "yorna",
                    count: 1,
                    current: 0,
                    description: "Find and recruit Yorna"
                }
            ],
            rewards: {
                affinity_rewards: [
                    { companion_id: "hola", amount: 2.0 }
                ],
                item_rewards: [],
                gold_reward: 0
            },
            prerequisites: [],
            completion_flag: "quest_hola_find_yorna_complete",
            requires_turnin: false,
            turnin_npc: undefined,
            chain_next: undefined
        };

        show_debug_message("Quest database initialized with " + string(variable_struct_names_count(global.quest_database)) + " quests");
    }
}

/// @function quest_accept(quest_id)
/// @description Add a quest to the player's active quests
/// @param {string} quest_id The ID of the quest to accept
function quest_accept(quest_id) {
    if (!variable_struct_exists(global.quest_database, quest_id)) {
        show_debug_message("ERROR: Quest '" + quest_id + "' does not exist in quest database");
        return false;
    }

    // Check if quest can be accepted
    if (!quest_can_accept(quest_id)) {
        show_debug_message("Quest '" + quest_id + "' cannot be accepted (prerequisites not met)");
        return false;
    }

    // Check if quest already active
    if (quest_is_active(quest_id)) {
        show_debug_message("Quest '" + quest_id + "' is already active");
        return false;
    }

    // Check if quest already completed
    if (quest_is_complete(quest_id)) {
        show_debug_message("Quest '" + quest_id + "' is already completed");
        return false;
    }

    // Deep copy quest data to player's active quests
    var quest_def = global.quest_database[$ quest_id];
    var quest_copy = {
        quest_id: quest_def.quest_id,
        quest_name: quest_def.quest_name,
        quest_giver: quest_def.quest_giver,
        objectives: [],
        rewards: quest_def.rewards,
        prerequisites: quest_def.prerequisites,
        completion_flag: quest_def.completion_flag,
        requires_turnin: quest_def.requires_turnin,
        turnin_npc: quest_def.turnin_npc,
        chain_next: quest_def.chain_next
    };

    // Deep copy objectives
    for (var i = 0; i < array_length(quest_def.objectives); i++) {
        var obj_def = quest_def.objectives[i];
        var obj_copy = {
            type: obj_def.type,
            target: obj_def.target,
            count: obj_def.count,
            current: 0,
            description: obj_def.description
        };

        // Copy optional fields
        if (variable_struct_exists(obj_def, "use_trait")) obj_copy.use_trait = obj_def.use_trait;
        if (variable_struct_exists(obj_def, "spawn_locations")) obj_copy.spawn_locations = obj_def.spawn_locations;
        if (variable_struct_exists(obj_def, "delivery_target")) obj_copy.delivery_target = obj_def.delivery_target;

        array_push(quest_copy.objectives, obj_copy);
    }

    // Add to player's active quests
    with (obj_player) {
        active_quests[$ quest_id] = quest_copy;
    }

    show_debug_message("✓ Quest accepted: " + quest_def.quest_name);

    // TODO: Trigger visual/audio feedback (will be implemented in task 6)
    // show_quest_notification("accept", quest_def.quest_name);

    return true;
}

/// @function quest_update_progress(quest_id, objective_index, amount)
/// @description Update quest objective progress
/// @param {string} quest_id The ID of the quest
/// @param {real} objective_index Index of the objective to update
/// @param {real} amount Amount to increment (default 1)
function quest_update_progress(quest_id, objective_index, amount = 1) {
    if (!quest_is_active(quest_id)) {
        return false;
    }

    with (obj_player) {
        var quest = active_quests[$ quest_id];

        if (objective_index >= 0 && objective_index < array_length(quest.objectives)) {
            var objective = quest.objectives[objective_index];
            objective.current = min(objective.current + amount, objective.count);

            show_debug_message("Quest progress: " + quest.quest_name + " - " + objective.description + " (" + string(objective.current) + "/" + string(objective.count) + ")");

            // TODO: Trigger visual/audio feedback (will be implemented in task 6)
            // show_quest_notification("progress", objective.description + " (" + string(objective.current) + "/" + string(objective.count) + ")");

            // Check if quest is complete
            if (quest_check_objectives(quest_id)) {
                // If quest doesn't require turn-in, complete it immediately
                if (!quest.requires_turnin) {
                    quest_complete(quest_id);
                } else {
                    show_debug_message("Quest objectives complete! Return to " + quest.turnin_npc);
                }
            }

            return true;
        }
    }

    return false;
}

/// @function quest_check_objectives(quest_id)
/// @description Check if all objectives for a quest are complete
/// @param {string} quest_id The ID of the quest
/// @return {bool} True if all objectives are met
function quest_check_objectives(quest_id) {
    if (!quest_is_active(quest_id)) {
        return false;
    }

    with (obj_player) {
        var quest = active_quests[$ quest_id];

        for (var i = 0; i < array_length(quest.objectives); i++) {
            var objective = quest.objectives[i];
            if (objective.current < objective.count) {
                return false;
            }
        }

        return true;
    }

    return false;
}

/// @function quest_complete(quest_id)
/// @description Complete a quest and grant rewards
/// @param {string} quest_id The ID of the quest to complete
function quest_complete(quest_id) {
    if (!quest_is_active(quest_id)) {
        show_debug_message("ERROR: Cannot complete quest '" + quest_id + "' - not active");
        return false;
    }

    with (obj_player) {
        var quest = active_quests[$ quest_id];

        // Grant affinity rewards
        for (var i = 0; i < array_length(quest.rewards.affinity_rewards); i++) {
            var affinity_reward = quest.rewards.affinity_rewards[i];

            // Find companion by companion_id
            with (obj_companion_parent) {
                if (companion_id == affinity_reward.companion_id) {
                    affinity = min(affinity + affinity_reward.amount, affinity_max);
                    show_debug_message("  + Affinity with " + companion_name + ": +" + string(affinity_reward.amount) + " (now " + string(affinity) + ")");
                }
            }
        }

        // Grant item rewards
        for (var i = 0; i < array_length(quest.rewards.item_rewards); i++) {
            var item_key = quest.rewards.item_rewards[i];
            inventory_add_item(item_key);
            show_debug_message("  + Received item: " + item_key);
        }

        // TODO: Grant gold reward (when currency system exists)
        // if (quest.rewards.gold_reward > 0) {
        //     gold += quest.rewards.gold_reward;
        // }

        // Remove quest items from inventory (unless they're reward items)
        var reward_item_ids = [];
        for (var i = 0; i < array_length(quest.rewards.item_rewards); i++) {
            array_push(reward_item_ids, quest.rewards.item_rewards[i]);
        }

        for (var i = array_length(inventory) - 1; i >= 0; i--) {
            var inv_item = inventory[i];
            if (inv_item.definition.type == ItemType.quest_item &&
                variable_struct_exists(inv_item.definition, "quest_id") &&
                inv_item.definition.quest_id == quest_id) {

                // Don't remove if it's a reward item
                var is_reward = false;
                for (var j = 0; j < array_length(reward_item_ids); j++) {
                    if (inv_item.definition.item_id == reward_item_ids[j]) {
                        is_reward = true;
                        break;
                    }
                }

                if (!is_reward) {
                    array_delete(inventory, i, 1);
                    show_debug_message("  - Removed quest item: " + inv_item.definition.name);
                }
            }
        }

        // Set completion flag
        variable_global_set(quest.completion_flag, true);
        show_debug_message("  + Set flag: " + quest.completion_flag);

        // Remove from active quests
        variable_struct_remove(active_quests, quest_id);

        show_debug_message("✓ Quest completed: " + quest.quest_name);

        // TODO: Trigger visual/audio feedback (will be implemented in task 6)
        // show_quest_notification("complete", quest.quest_name + " Complete!");

        // Unlock chain quest if exists
        if (quest.chain_next != undefined && variable_struct_exists(global.quest_database, quest.chain_next)) {
            show_debug_message("  → Next quest in chain available: " + global.quest_database[$ quest.chain_next].quest_name);
        }

        return true;
    }

    return false;
}

/// @function quest_is_active(quest_id)
/// @description Check if a quest is currently active
/// @param {string} quest_id The ID of the quest
/// @return {bool} True if quest is active
function quest_is_active(quest_id) {
    with (obj_player) {
        return variable_struct_exists(active_quests, quest_id);
    }
    return false;
}

/// @function quest_is_complete(quest_id)
/// @description Check if a quest has been completed
/// @param {string} quest_id The ID of the quest
/// @return {bool} True if quest is complete
function quest_is_complete(quest_id) {
    if (!variable_struct_exists(global.quest_database, quest_id)) {
        return false;
    }

    var quest = global.quest_database[$ quest_id];

    // Check if completion flag is set
    if (variable_global_exists(quest.completion_flag)) {
        return variable_global_get(quest.completion_flag);
    }

    return false;
}

/// @function quest_can_accept(quest_id)
/// @description Check if a quest can be accepted (prerequisites met)
/// @param {string} quest_id The ID of the quest
/// @return {bool} True if quest can be accepted
function quest_can_accept(quest_id) {
    if (!variable_struct_exists(global.quest_database, quest_id)) {
        return false;
    }

    var quest = global.quest_database[$ quest_id];

    // Check if already completed
    if (quest_is_complete(quest_id)) {
        return false;
    }

    // Check if already active
    if (quest_is_active(quest_id)) {
        return false;
    }

    // Check prerequisites
    for (var i = 0; i < array_length(quest.prerequisites); i++) {
        var prereq_id = quest.prerequisites[i];
        if (!quest_is_complete(prereq_id)) {
            return false;
        }
    }

    return true;
}

/// @function quest_check_companion_recruitment(companion_id)
/// @description Check all active quests for recruit_companion objectives and update them
/// @param {string} companion_id The companion_id that was recruited (e.g., "yorna")
function quest_check_companion_recruitment(companion_id) {
    with (obj_player) {
        var quest_ids = variable_struct_get_names(active_quests);

        for (var i = 0; i < array_length(quest_ids); i++) {
            var quest_id = quest_ids[i];
            var quest = active_quests[$ quest_id];

            // Check each objective
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];

                if (objective.type == "recruit_companion" && objective.target == companion_id) {
                    if (objective.current < objective.count) {
                        quest_update_progress(quest_id, j, 1);
                    }
                }
            }
        }
    }
}

/// @function quest_check_enemy_kill(enemy_object, enemy_tags, is_quest_enemy, quest_enemy_id)
/// @description Check all active quests for kill objectives and update them
/// @param {asset} enemy_object The object_index of the killed enemy
/// @param {array} enemy_tags Array of tag strings (e.g., ["fireborne"])
/// @param {bool} is_quest_enemy Whether this enemy was spawned for a quest (optional)
/// @param {string} quest_enemy_id The quest_id if this is a quest enemy (optional)
function quest_check_enemy_kill(enemy_object, enemy_tags, is_quest_enemy = false, quest_enemy_id = "") {
    with (obj_player) {
        var quest_ids = variable_struct_get_names(active_quests);

        for (var i = 0; i < array_length(quest_ids); i++) {
            var quest_id = quest_ids[i];
            var quest = active_quests[$ quest_id];

            // Check each objective
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];

                if (objective.type == "kill") {
                    var matches = false;

                    if (objective.use_trait) {
                        // Check if enemy has the required trait tag
                        for (var k = 0; k < array_length(enemy_tags); k++) {
                            if (enemy_tags[k] == objective.target) {
                                matches = true;
                                break;
                            }
                        }
                    } else {
                        // Check if enemy object matches
                        if (object_get_name(enemy_object) == objective.target) {
                            matches = true;
                        }
                    }

                    if (matches && objective.current < objective.count) {
                        quest_update_progress(quest_id, j, 1);
                    }
                }
                else if (objective.type == "spawn_kill") {
                    // Check if this is a quest enemy for this specific quest
                    if (is_quest_enemy && quest_enemy_id == quest_id) {
                        if (objective.current < objective.count) {
                            quest_update_progress(quest_id, j, 1);
                        }
                    }
                }
            }
        }
    }
}

/// @function quest_check_item_collection(item_id, quest_id)
/// @description Check if collecting this item progresses any collect objectives
/// @param {string} item_id The item_id that was collected
/// @param {string} quest_id The quest_id associated with this quest item
function quest_check_item_collection(item_id, quest_id) {
    if (!quest_is_active(quest_id)) return;

    with (obj_player) {
        var quest = active_quests[$ quest_id];

        // Check each objective
        for (var i = 0; i < array_length(quest.objectives); i++) {
            var objective = quest.objectives[i];

            if (objective.type == "collect" && objective.target == item_id) {
                if (objective.current < objective.count) {
                    quest_update_progress(quest_id, i, 1);
                }
            }
        }
    }
}

/// @function quest_check_location_reached(marker_quest_id)
/// @description Check if reaching this location completes any location objectives
/// @param {string} marker_quest_id The quest_id associated with this quest marker
function quest_check_location_reached(marker_quest_id) {
    if (!quest_is_active(marker_quest_id)) return;

    with (obj_player) {
        var quest = active_quests[$ marker_quest_id];

        // Check each objective
        for (var i = 0; i < array_length(quest.objectives); i++) {
            var objective = quest.objectives[i];

            if (objective.type == "location") {
                if (objective.current < objective.count) {
                    quest_update_progress(marker_quest_id, i, 1);
                    return true;
                }
            }
        }
    }

    return false;
}

/// @function quest_check_delivery(npc_object_name)
/// @description Check if player has quest items to deliver to this NPC
/// @param {string} npc_object_name The object name of the delivery target
function quest_check_delivery(npc_object_name) {
    with (obj_player) {
        var quest_ids = variable_struct_get_names(active_quests);

        for (var i = 0; i < array_length(quest_ids); i++) {
            var quest_id = quest_ids[i];
            var quest = active_quests[$ quest_id];

            // Check each objective
            for (var j = 0; j < array_length(quest.objectives); j++) {
                var objective = quest.objectives[j];

                if (objective.type == "deliver" && objective.delivery_target == npc_object_name) {
                    // Check if player has the required quest item
                    var has_item = false;
                    for (var k = 0; k < array_length(inventory); k++) {
                        var inv_item = inventory[k];
                        if (inv_item.definition.item_id == objective.target && inv_item.count >= objective.count) {
                            has_item = true;
                            break;
                        }
                    }

                    if (has_item && objective.current < objective.count) {
                        quest_update_progress(quest_id, j, 1);
                        show_debug_message("Quest item delivered to " + npc_object_name);
                        return true;
                    }
                }
            }
        }
    }

    return false;
}

/// @function spawn_quest_enemy(enemy_object, spawn_x, spawn_y, spawn_room, quest_id)
/// @description Spawn a quest-specific enemy at a location
/// @param {asset} enemy_object The enemy object to spawn
/// @param {real} spawn_x X coordinate to spawn at
/// @param {real} spawn_y Y coordinate to spawn at
/// @param {asset} spawn_room Room to spawn in (use room for current room)
/// @param {string} quest_id The quest_id this enemy is associated with
/// @return {instance} The spawned enemy instance
function spawn_quest_enemy(enemy_object, spawn_x, spawn_y, spawn_room, quest_id) {
    var enemy_instance = noone;

    // Spawn in specified room
    if (room == spawn_room) {
        enemy_instance = instance_create_layer(spawn_x, spawn_y, "Instances", enemy_object);
    } else {
        // If not in the same room, we can't spawn yet - this would need room persistence
        show_debug_message("Cannot spawn quest enemy - not in target room");
        return noone;
    }

    // Mark as quest enemy
    with (enemy_instance) {
        quest_enemy = true;
        quest_enemy_id = quest_id;
    }

    show_debug_message("Spawned quest enemy for quest: " + quest_id);
    return enemy_instance;
}
