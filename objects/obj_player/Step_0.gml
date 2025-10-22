/// obj_player : Step

if (global.game_paused) exit;

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
    // ============================================
    // PLAYER STEP EVENT - PICKUP CODE
    // ============================================

    #region Pickup items
    // Auto-pickup disabled - items now use spacebar interaction system
    // player_handle_pickup();
    #endregion


    #region Animation
    player_handle_animation();
    #endregion Animation

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

    #region Companion System
/*
    // Check for nearby recruitable companions
    var _nearest_companion = instance_nearest(x, y, obj_companion_parent);
    if (_nearest_companion != noone &&
        !_nearest_companion.is_recruited &&
        point_distance(x, y, _nearest_companion.x, _nearest_companion.y) < 32) {

        // Show recruitment prompt (Space key)
        if (keyboard_check_pressed(vk_space)) {
            recruit_companion(_nearest_companion, self);
            show_debug_message("Recruited " + _nearest_companion.companion_name);
        }
    }
*/
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

// DEBUG: Stagger player (4 key)
if (keyboard_check_pressed(ord("4"))) {
    apply_stagger(self, 2.0, noone); // 2 second stagger
    show_debug_message("Applied 2 second stagger to player");
}

// DEBUG: Stun nearest enemy (7 key)
if (keyboard_check_pressed(ord("7"))) {
    var nearest_enemy = instance_nearest(x, y, obj_enemy_parent);
    if (nearest_enemy != noone && point_distance(x, y, nearest_enemy.x, nearest_enemy.y) < 200) {
        apply_stun(nearest_enemy, 3.0, self); // 3 second stun
        show_debug_message("Applied 3 second stun to enemy at distance: " + string(point_distance(x, y, nearest_enemy.x, nearest_enemy.y)));
    } else {
        show_debug_message("No enemy within 200 pixels to stun");
    }
}

// Debug key for adding arrows
if (keyboard_check_pressed(ord("9"))) {
    inventory_add_item(global.item_database.arrows, 10);
    show_debug_message("Added 10 arrows via debug key");
}

// Debug keys for testing trait system v2.0
if (keyboard_check_pressed(ord("T"))) {
    // Add fire_resistance trait (3 stacks)
    add_temporary_trait("fire_resistance", 3);
    show_debug_message("Added 3 stacks of fire_resistance to player");
}

if (keyboard_check_pressed(ord("Y"))) {
    // Add fire_vulnerability trait (2 stacks)
    add_temporary_trait("fire_vulnerability", 2);
    show_debug_message("Added 2 stacks of fire_vulnerability to player (should cancel 2 resistance stacks)");
}

if (keyboard_check_pressed(ord("U"))) {
    // Clear all temporary traits
    temporary_traits = {};
    show_debug_message("Cleared all temporary traits from player");
}

if (keyboard_check_pressed(ord("P"))) {
    // Clear all tags and permanent traits
    tags = [];
    permanent_traits = {};
    show_debug_message("Cleared all tags and permanent traits from player");
}

if (keyboard_check_pressed(ord("T"))) {
    show_debug_message("=== PLAYER TRAIT STATUS ===");
    show_debug_message("Tags: " + json_stringify(tags));
    show_debug_message("Permanent Traits: " + json_stringify(permanent_traits));
    show_debug_message("Temporary Traits: " + json_stringify(temporary_traits));
    show_debug_message("Fire Resistance Stacks: " + string(get_total_trait_stacks("fire_resistance")));
    show_debug_message("Fire Vulnerability Stacks: " + string(get_total_trait_stacks("fire_vulnerability")));
    show_debug_message("Fire Damage Modifier: " + string(get_damage_modifier_for_type(DamageType.fire)));

    // Check for Hola-specific aura debug output
    var companions = get_active_companions();
    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];
        if (companion.companion_id == "hola") {
            show_debug_message("=== HOLA AURA STATUS ===");
            show_debug_message("Affinity: " + string(companion.affinity) + "/10.0");
            var multiplier = get_affinity_aura_multiplier(companion.affinity);
            show_debug_message("Aura Multiplier: " + string(multiplier) + "x");

            // Slowing aura
            if (variable_struct_exists(companion.auras, "slowing") && companion.auras.slowing.active) {
                var base_slow = companion.auras.slowing.slow_percent;
                var scaled_slow = base_slow * multiplier;
                show_debug_message("Slowing Aura: " + string(base_slow * 100) + "% → " + string(scaled_slow * 100) + "% (radius: " + string(companion.auras.slowing.radius) + "px)");
                show_debug_message("  Enemy Speed Multiplier: " + string(get_companion_enemy_slow(x, y)));
            }

            // Slipstream passive aura
            if (variable_struct_exists(companion.auras, "slipstream") && companion.auras.slipstream.active) {
                var base_cd = companion.auras.slipstream.dash_cd_reduction;
                var scaled_cd = base_cd * multiplier;
                show_debug_message("Slipstream Passive: " + string(base_cd * 100) + "% → " + string(scaled_cd * 100) + "% dash CD reduction");
            }

            // Wind deflection aura
            if (variable_struct_exists(companion.auras, "wind_deflection") && companion.auras.wind_deflection.active) {
                var base_deflect = companion.auras.wind_deflection.deflect_chance;
                var scaled_deflect = base_deflect * multiplier;
                show_debug_message("Wind Deflection: " + string(base_deflect * 100) + "% → " + string(scaled_deflect * 100) + "% (radius: " + string(companion.auras.wind_deflection.radius) + "px)");
            }

            // Total dash CD reduction (passive + active trigger)
            var total_dash_cd = get_companion_dash_cd_reduction();
            show_debug_message("Total Dash CD Reduction: " + string(total_dash_cd * 100) + "%");

            // Maelstrom deflect timer
            if (variable_instance_exists(companion, "maelstrom_deflect_timer") && companion.maelstrom_deflect_timer > 0) {
                var seconds_left = companion.maelstrom_deflect_timer / 60;
                show_debug_message("Maelstrom Deflection Bonus: +25% (active for " + string(seconds_left) + "s)");
                var deflect_bonus = get_companion_deflection_bonus("hola");
                show_debug_message("  Total Deflection Bonus: " + string(deflect_bonus * 100) + "%");
            }
        }
    }

    // Show nearest enemy traits too
    var nearest_enemy = instance_nearest(x, y, obj_enemy_parent);
    if (nearest_enemy != noone && point_distance(x, y, nearest_enemy.x, nearest_enemy.y) < 200) {
        with (nearest_enemy) {
            show_debug_message("=== NEAREST ENEMY TRAIT STATUS ===");
            show_debug_message("Tags: " + json_stringify(tags));
            show_debug_message("Permanent Traits: " + json_stringify(permanent_traits));
            show_debug_message("Temporary Traits: " + json_stringify(temporary_traits));
        }
    }
}

// Debug key for combat timer status (for companion evading system)
if (keyboard_check_pressed(ord("P"))) {
    show_debug_message("=== COMBAT TIMER DEBUG ===");
    show_debug_message("Combat Timer: " + string(combat_timer) + "s");
    show_debug_message("Combat Cooldown: " + string(combat_cooldown) + "s");
    show_debug_message("Is In Combat: " + string(is_in_combat()));

    // Show companion states and distances
    var companions = get_active_companions();
    for (var i = 0; i < array_length(companions); i++) {
        var comp = companions[i];
        var state_name = "";
        switch (comp.state) {
            case CompanionState.waiting: state_name = "waiting"; break;
            case CompanionState.following: state_name = "following"; break;
            case CompanionState.casting: state_name = "casting"; break;
            case CompanionState.evading: state_name = "evading"; break;
            default: state_name = "unknown"; break;
        }
        var dist = point_distance(x, y, comp.x, comp.y);
        show_debug_message(comp.companion_name + " state: " + state_name + " | distance: " + string(round(dist)) + "px");
    }
    show_debug_message("==========================");
}

// Debug key to boost affinity for all recruited companions
if (keyboard_check_pressed(ord("K"))) {
    var companions = get_active_companions();
    show_debug_message("=== AFFINITY DEBUG (K) ===");

    if (array_length(companions) == 0) {
        show_debug_message("No companions recruited");
    } else {
        for (var i = 0; i < array_length(companions); i++) {
            var companion = companions[i];
            companion.affinity = min(companion.affinity + 1, companion.affinity_max);

            show_debug_message(companion.companion_name + " affinity: " + string(companion.affinity) + "/" + string(companion.affinity_max));
            spawn_floating_text(companion.x, companion.bbox_top - 16,
                "Affinity: " + string(companion.affinity), c_yellow, companion);
        }
    }

    show_debug_message("=======================");
}

// Debug key to show affinity aura multipliers for all companions
if (keyboard_check_pressed(ord("H"))) {
    show_debug_message("=== AFFINITY AURA SCALING ===");
    with (obj_companion_parent) {
        if (is_recruited) {
            var multiplier = get_affinity_aura_multiplier(affinity);
            show_debug_message(companion_name + " (Affinity " + string(affinity) + "):");
            show_debug_message("  Multiplier: " + string(multiplier) + "x");

            // Show scaled aura values
            if (variable_struct_exists(auras, "regeneration") && auras.regeneration.active) {
                var base_regen = auras.regeneration.hp_per_tick;
                show_debug_message("  Regen: " + string(base_regen) + " -> " + string(base_regen * multiplier) + " HP/tick");
            }
            if (variable_struct_exists(auras, "protective") && auras.protective.active) {
                var base_dr = auras.protective.dr_bonus;
                show_debug_message("  Protective DR: " + string(base_dr) + " -> " + string(base_dr * multiplier));
            }
            if (variable_struct_exists(auras, "wind_ward") && auras.wind_ward.active) {
                var base_ranged_dr = auras.wind_ward.ranged_damage_reduction;
                show_debug_message("  Wind Ward DR: " + string(base_ranged_dr) + " -> " + string(base_ranged_dr * multiplier));
            }
            if (variable_struct_exists(auras, "warriors_presence") && auras.warriors_presence.active) {
                var base_attack = auras.warriors_presence.attack_bonus;
                show_debug_message("  Warriors Presence Attack: " + string(base_attack) + " -> " + string(base_attack * multiplier));

                // Show multi-target info based on affinity
                var _affinity = affinity;
                if (_affinity >= 10.0) {
                    show_debug_message("  Multi-Target: 5 targets (100% chance)");
                } else if (_affinity >= 8.0) {
                    show_debug_message("  Multi-Target: 4 targets (100% chance)");
                } else if (_affinity >= 5.0) {
                    show_debug_message("  Multi-Target: 3 targets (25% chance)");
                } else if (_affinity >= 3.0) {
                    show_debug_message("  Multi-Target: 2 targets (10% chance)");
                }
            }
        }
    }
    show_debug_message("============================");
}

// ============================================
// DEBUG SAVE/LOAD KEYS
// ============================================

// F5 - Save to slot 1
if (keyboard_check_pressed(vk_f5)) {
    save_game(1);
    show_debug_message("=== MANUAL SAVE TO SLOT 1 ===");
}

// F9 - Load from slot 1
if (keyboard_check_pressed(vk_f9)) {
    load_game(1);
    show_debug_message("=== MANUAL LOAD FROM SLOT 1 ===");
}

// F6 - Save to slot 2
if (keyboard_check_pressed(vk_f6)) {
    save_game(2);
    show_debug_message("=== MANUAL SAVE TO SLOT 2 ===");
}

// F10 - Load from slot 2
if (keyboard_check_pressed(vk_f10)) {
    load_game(2);
    show_debug_message("=== MANUAL LOAD FROM SLOT 2 ===");
}

// F8 - Load from autosave
if (keyboard_check_pressed(vk_f8)) {
    load_game("autosave");
    show_debug_message("=== LOAD FROM AUTOSAVE ===");
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

// Debug key to run hazard tests
if (keyboard_check_pressed(vk_f11)) {
    run_all_hazard_tests();
}
