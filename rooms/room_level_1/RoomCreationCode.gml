/// Room Creation Code - room_level_1 (Tutorial Room)
/// Initialize onboarding quest sequence for this room

onboarding_initialize_for_room([
    // Quest 1: Find and pick up a torch
    {
        quest_id: "onboarding_find_torch",
        display_text: "It's dark! Press SPACE/E to open a chest and pick up the torch!",
        check_completion: function() {
            return action_tracker_has("item_pickup_torch");
        },
        xp_reward: 5,
        completed: false,
        marker_location: {x: 331, y: 245}
    },

    // Quest 3: Pick up a weapon
    {
        quest_id: "onboarding_pick_up_weapon",
        display_text: "Pick up the weapon on the ground.",
        check_completion: function() {
            return action_tracker_has("item_pickup_rusty_dagger");
        },
        xp_reward: 5,
        completed: false
    },

    // Quest 4: Talk to Canopy
    {
        quest_id: "onboarding_talk_to_canopy",
        display_text: "Talk to Canopy to recruit her.",
        check_completion: function() {
            return action_tracker_has("npc_interaction_canopy");
        },
        xp_reward: 5,
        completed: false,
        marker_location: {target: instance_find(obj_canopy, 0), offset_x: -8, offset_y: -32}
    },

    // Quest 5: Give torch to Canopy
    {
        quest_id: "onboarding_give_torch_to_canopy",
        display_text: "Press L to give Canopy the torch.",
        check_completion: function() {
            return action_tracker_has("torch_given");
        },
        xp_reward: 5,
        completed: false
    },

    // Quest 6: Perform a dash attack
    {
        quest_id: "onboarding_dash_attack",
        display_text: "Double-tap a direction, then press J for a dash attack.",
        check_completion: function() {
            return action_tracker_has("dash_attack");
        },
        xp_reward: 5,
        completed: false
    },

    // Quest 7: Open inventory
    {
        quest_id: "onboarding_open_inventory",
        display_text: "Press I to open your inventory.",
        check_completion: function() {
            return action_tracker_has("inventory_opened");
        },
        xp_reward: 5,
        completed: false
    },

    // Quest 8: Swap weapon loadouts
    {
        quest_id: "onboarding_swap_loadout",
        display_text: "Press Q to swap your weapon loadout.",
        check_completion: function() {
            return action_tracker_has("loadout_swapped");
        },
        xp_reward: 5,
        completed: false
    }
]);

show_debug_message("=== Room Creation Code Executed: room_level_1 ===");

var _controller = instance_find(obj_lighting_controller, 0);

if (_controller == noone) {
    var _layer = layer_exists("Instances") ? "Instances" : layer_get_name(layer_get_id(0));
    _controller = instance_create_layer(0, 0, _layer, obj_lighting_controller);
}

if (_controller != noone) {
    _controller.room_darkness_level = 0.8; // 0 = fully lit, 1 = pitch black
    _controller.surface_dirty = true;
}
