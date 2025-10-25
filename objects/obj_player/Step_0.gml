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
        var _hor = InputX(INPUT_CLUSTER.NAVIGATION);
        var _ver = InputY(INPUT_CLUSTER.NAVIGATION);

        // Determine direction from analog input
        if (abs(_ver) > abs(_hor)) {
            if (_ver > 0) _input_dir = "down";
            else if (_ver < 0) _input_dir = "up";
        } else {
            if (_hor > 0) _input_dir = "right";
            else if (_hor < 0) _input_dir = "left";
        }

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

    if (InputPressed(INPUT_VERB.SWAP_LOADOUT)) {
        var _swap_method = method(self, swap_active_loadout);
        if (_swap_method != undefined && _swap_method()) {
            var _active_key_fn = method(self, loadouts_get_active_key);
            if (_active_key_fn != undefined) {
                var _active_key = _active_key_fn();
                show_debug_message("[SWAP_LOADOUT] Swapped active loadout to " + string(_active_key));
            }
        }
        // Action tracker: loadout swapped
        action_tracker_log("loadout_swapped");
    }

    // Open companion talk menu with Circle button (context-aware)
    // Circle works in gameplay, cancels in menus (handled by menu controllers)
    if (InputPressed(INPUT_VERB.UI_CANCEL) && global.state == GameState.gameplay && global.input_debounce_frames == 0) {
        var companions = get_active_companions();
        if (array_length(companions) > 0) {
            open_companion_talk_menu();
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

    #region Torch Lighting
    player_update_torch_state();
    #endregion Torch Lighting

    #endregion Companion System
}
