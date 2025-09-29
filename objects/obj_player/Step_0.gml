/// obj_player : Step

if (global.game_paused) exit;

// Make pillars slightly behind player at same position
depth = -bbox_bottom;

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

GRID_Y_OFFSET = obj_grid_controller.GRID_Y_OFFSET;


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

// Tick status effects (runs even when dead)
tick_status_effects();

// Don't run other systems when dead
if (state != PlayerState.dead) {
    // ============================================
    // PLAYER STEP EVENT - PICKUP CODE
    // ============================================

    #region Pickup items
    player_handle_pickup();
    #endregion


    #region Animation
    player_handle_animation();
    #endregion Animation

    #region Attack System

    // Handle attack input and cooldown (applies to all states)
    player_handle_attack_input();

    // Handle dash cooldown
    player_handle_dash_cooldown();

    #endregion Attack System
}

// Debug keys for testing status effects (remove in final version)
if (keyboard_check_pressed(ord("1"))) {
    apply_status_effect(StatusEffectType.burning);
    show_debug_message("Applied burning effect");
}
if (keyboard_check_pressed(ord("2"))) {
    apply_status_effect(StatusEffectType.wet);
    show_debug_message("Applied wet effect");
}
if (keyboard_check_pressed(ord("3"))) {
    apply_status_effect(StatusEffectType.empowered);
    show_debug_message("Applied empowered effect");
}
if (keyboard_check_pressed(ord("4"))) {
    apply_status_effect(StatusEffectType.weakened);
    show_debug_message("Applied weakened effect");
}
if (keyboard_check_pressed(ord("5"))) {
    apply_status_effect(StatusEffectType.swift);
    show_debug_message("Applied swift effect");
}
if (keyboard_check_pressed(ord("6"))) {
    apply_status_effect(StatusEffectType.slowed);
    show_debug_message("Applied slowed effect");
}

// Apply status effects to nearest enemy
if (keyboard_check_pressed(ord("7"))) {
    var nearest_enemy = instance_nearest(x, y, obj_enemy_parent);
    if (nearest_enemy != noone && point_distance(x, y, nearest_enemy.x, nearest_enemy.y) < 50) {
        with (nearest_enemy) {
            apply_status_effect(StatusEffectType.burning);
        }
        show_debug_message("Applied burning to enemy");
    }
}

// Debug key for testing XP gain
if (keyboard_check_pressed(ord("8"))) {
    gain_xp(10);
    show_debug_message("Gained 10 XP via debug key");
}

// Debug keys for testing trait system
if (keyboard_check_pressed(ord("T"))) {
    add_trait("fireborne");
    show_debug_message("Added fireborne trait to player. Current traits: " + json_stringify(traits));
}

if (keyboard_check_pressed(ord("Y"))) {
    var nearest_enemy = instance_nearest(x, y, obj_enemy_parent);
    if (nearest_enemy != noone && point_distance(x, y, nearest_enemy.x, nearest_enemy.y) < 200) {
        with (nearest_enemy) {
            add_trait("arboreal");
            show_debug_message("Added arboreal trait to enemy. Current traits: " + json_stringify(traits));
        }
    } else {
        show_debug_message("No enemy nearby to add trait");
    }
}

if (keyboard_check_pressed(ord("U"))) {
    traits = [];
    show_debug_message("Removed all traits from player");
}

if (keyboard_check_pressed(ord("O"))) {
    show_debug_message("=== PLAYER TRAITS ===");
    show_debug_message("Traits: " + json_stringify(traits));
    show_debug_message("Count: " + string(array_length(traits)));

    // Show nearest enemy traits too
    var nearest_enemy = instance_nearest(x, y, obj_enemy_parent);
    if (nearest_enemy != noone && point_distance(x, y, nearest_enemy.x, nearest_enemy.y) < 200) {
        with (nearest_enemy) {
            show_debug_message("=== NEAREST ENEMY TRAITS ===");
            show_debug_message("Traits: " + json_stringify(traits));
            show_debug_message("Count: " + string(array_length(traits)));
        }
    }
}
