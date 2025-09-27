// Trigger when player is overlapping the pad; re-arm when they step off
var player_is_on_pad = place_meeting(x, y, obj_player);

if (player_is_on_pad && !has_triggered_this_overlap) {
    obj_grid_controller.reset_all_pillars_to_original();
    has_triggered_this_overlap = true;
}

if (!player_is_on_pad) {
    has_triggered_this_overlap = false; // re-arm once player leaves
}
