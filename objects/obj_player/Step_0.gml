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
