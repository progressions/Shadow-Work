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

    default:
        // Fallback to idle for any unexpected state
        state = PlayerState.idle;
        break;
}

// Handle common systems that apply to all states (except on_grid)
if (state != PlayerState.on_grid) {
    // ============================================
    // KNOCKBACK SYSTEM
    // ============================================
    if (kb_x != 0 || kb_y != 0) {
        // Apply knockback movement
        move_and_collide(kb_x, kb_y, tilemap);

        // Reduce knockback over time
        kb_x *= 0.8;
        kb_y *= 0.8;

        // Stop knockback when it's very small
        if (abs(kb_x) < 0.1) kb_x = 0;
        if (abs(kb_y) < 0.1) kb_y = 0;
    }

    
}

#endregion Movement

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
