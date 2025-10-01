// Room Start Event
// Check for pending save data first (from load_game room transition)
check_for_pending_save_restore();

// If no pending save, restore room state if this room has been visited before
if (!variable_global_exists("pending_save_data") || global.pending_save_data == undefined) {
    restore_room_state_if_visited();
}
