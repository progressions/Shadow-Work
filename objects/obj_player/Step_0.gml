/// obj_player : Step

if (global.game_paused) exit;

// Don't process player logic while loading from save
if (global.loading_from_save) exit;

// Update stun/stagger timers
update_stun_stagger_timers(self);

// Update invulnerability timer
if (invulnerability_timer > 0) {
    invulnerability_timer--;
    if (invulnerability_timer <= 0) {
        invulnerable = false;
        invulnerability_timer = 0;
    }
}

// Update shield block cooldown
if (block_cooldown > 0) {
    block_cooldown--;
}

// Maintain stun/stagger color overlays
if (is_stunned) {
    image_blend = c_yellow;
} else if (is_staggered) {
    image_blend = make_color_rgb(160, 32, 240); // Purple for stagger
}

// Make pillars slightly behind player at same position
depth = -bbox_bottom;

// show_debug_message("depth " + string(depth));

var _hor = 0;
var _ver = 0;

// Update elevation and offset
if (elevation_source != noone) {
    y_offset = elevation_source.y_offset;
    current_elevation = elevation_source.height;
} else {
    y_offset = 0;
    current_elevation = -1;
}

if (instance_exists(obj_grid_controller)) {
    if (!variable_instance_exists(self, "GRID_Y_OFFSET")) GRID_Y_OFFSET = 0;
    GRID_Y_OFFSET = obj_grid_controller.GRID_Y_OFFSET;
}

// Update focus input state before processing movement/attacks
player_focus_update(self);

// Update combat timer for companion evading behavior
combat_timer += delta_time / 1000000; // Convert microseconds to seconds

// Apply terrain effects (traits and speed modifier)
apply_terrain_effects();

#region Movement

// State machine for player movement
switch (state) {
    case PlayerState.idle:
        player_state_idle();
        break;

    case PlayerState.walking:
        player_state_walking();
        break;

    case PlayerState.dashing:
        player_state_dashing();
        break;

    case PlayerState.attacking:
        player_state_attacking();
        break;

    case PlayerState.shielding:
        player_state_shielding();
        break;

    case PlayerState.on_grid:
        if (!obj_grid_controller.hop.active) {
            player_on_grid();
        }
        break;

    case PlayerState.dead:
        player_state_dead();
        break;

    default:
        // Fallback to idle for any unexpected state
        state = PlayerState.idle;
        break;
}


#endregion Movement

// Tick trait-driven status effects (runs even when dead)
tick_status_effects();


tilemap = layer_tilemap_get_id("Tiles_Col");

// Don't run other systems when dead
if (state != PlayerState.dead) {
    player_handle_animation();

    #region Attack System

    // Handle attack input and cooldown (applies to all states)
    player_handle_attack_input();

    // Handle dash cooldown
    player_handle_dash_cooldown();

    // Handle dash attack window
    if (dash_attack_window > 0) {
        // Check for direction change (cancels dash attack window)
        var _input_dir = "";
        if (keyboard_check(ord("W"))) _input_dir = "up";
        else if (keyboard_check(ord("S"))) _input_dir = "down";
        else if (keyboard_check(ord("A"))) _input_dir = "left";
        else if (keyboard_check(ord("D"))) _input_dir = "right";

        if (_input_dir != "" && _input_dir != last_dash_direction) {
            dash_attack_window = 0; // Cancel window on direction change
            show_debug_message("Dash attack window CANCELLED - direction changed from " + last_dash_direction + " to " + _input_dir);
        } else {
            dash_attack_window -= 1 / game_get_speed(gamespeed_fps); // Decrement by delta time

            if (dash_attack_window <= 0) {
                dash_attack_window = 0;
                show_debug_message("Dash attack window EXPIRED");
            }
        }
    }

    if (keyboard_check_pressed(ord("Q"))) {
        var _swap_method = method(self, swap_active_loadout);
        if (_swap_method != undefined && _swap_method()) {
            var _active_key_fn = method(self, loadouts_get_active_key);
            if (_active_key_fn != undefined) {
                var _active_key = _active_key_fn();
                show_debug_message("[Q] Swapped active loadout to " + string(_active_key));
            }
        }
        // Action tracker: loadout swapped
        action_tracker_log("loadout_swapped");
    }

    // Open companion talk menu with C key
    if (keyboard_check_pressed(ord("C"))) {
        var companions = get_active_companions();
        if (array_length(companions) > 0) {
            open_companion_talk_menu();
        } else {
            show_debug_message("No recruited companions to talk to");
        }
    }

    // Process pending focus retreat dash (melee focus sequence)
    var _focus_retreat = player_focus_peek_pending_retreat(self);
    if (_focus_retreat != undefined) {
        if (state != PlayerState.attacking && state != PlayerState.dashing && dash_cooldown <= 0) {
            var _retreat_info = player_focus_consume_pending_retreat(self);
            if (_retreat_info != undefined) {
                start_dash(_retreat_info.direction, true);
                state = PlayerState.dashing;
            }
        }
    }

    #endregion Attack System

    // Apply companion regeneration auras
    apply_companion_regeneration_auras(self);

    // Evaluate and activate companion triggers
    evaluate_companion_triggers(self);

    // Torch transfer to companions (L key)
    if (keyboard_check_pressed(ord("L"))) {
        // Check if player has an active torch OR a torch in inventory/equipped
        var _has_active_torch = torch_active;
        var _has_torch_available = player_has_torch_in_inventory() || player_has_equipped_torch();

        if (_has_active_torch || _has_torch_available) {
            var _companions = get_active_companions();
            if (array_length(_companions) > 0) {
                var _target = _companions[0];
                if (!_target.carrying_torch) {
                    var _remaining = 0;
                    var _radius = player_get_torch_light_radius();

                    // If torch is active, transfer the burning torch with remaining time
                    if (_has_active_torch) {
                        _remaining = torch_time_remaining;
                        if (companion_receive_torch(_target, _remaining, _radius)) {
                            player_play_torch_sfx("snd_companion_torch_receive");
                            player_stop_torch_loop();
                            player_remove_torch_from_loadouts();
                            torch_active = false;
                            torch_time_remaining = 0;
                            // Action tracker: torch given to companion
                            action_tracker_log("torch_given");
                        }
                    }
                    // Otherwise, consume a torch from inventory and give a fresh one
                    else if (_has_torch_available) {
                        if (player_supply_companion_torch()) {
                            _remaining = torch_duration; // Give full duration torch
                            if (companion_receive_torch(_target, _remaining, _radius)) {
                                player_play_torch_sfx("snd_companion_torch_receive");
                                // Action tracker: torch given to companion
                                action_tracker_log("torch_given");
                            }
                        }
                    }
                }
            }
        }
    }

    #region Torch Lighting
    player_update_torch_state();
    #endregion Torch Lighting

    #endregion Companion System
}

// Debug key for adding arrows
if (keyboard_check_pressed(ord("9"))) {
    inventory_add_item(global.item_database.arrows, 10);
    show_debug_message("Added 10 arrows via debug key");
}


// F9 - Debug: Add test items to inventory
if (keyboard_check_pressed(vk_f9)) {
    show_debug_message("=== ADDING TEST ITEMS TO INVENTORY ===");

    // Clear inventory first
    inventory = [];

    // Add variety of items to test scaling
    inventory_add_item(global.item_database.short_sword, 1);      // Normal weapon (2x)
    inventory_add_item(global.item_database.greatsword, 1);       // Large weapon (1x)
    inventory_add_item(global.item_database.health_potion, 5);    // Stackable (2x, count: 5)
    inventory_add_item(global.item_database.leather_helmet, 1);   // Armor (2x)
    inventory_add_item(global.item_database.shield, 1);           // Shield (2x)
    inventory_add_item(global.item_database.longbow, 1);          // Large weapon (1x)
    inventory_add_item(global.item_database.crossbow, 1);         // Large weapon (1x)
    inventory_add_item(global.item_database.chain_armor, 1);      // Armor (2x)
    inventory_add_item(global.item_database.water, 3);            // Stackable (2x, count: 3)

    show_debug_message("Added " + string(array_length(inventory)) + " test items to inventory");
}
