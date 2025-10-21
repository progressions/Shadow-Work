// Debug: Check if player is overlapping
if (place_meeting(x, y, obj_player)) {
    show_debug_message("Player is overlapping room transition at (" + string(x) + ", " + string(y) + ")");
}
