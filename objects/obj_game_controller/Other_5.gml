// Room End Event
// Save current room state before leaving
if (instance_exists(obj_player)) {
    save_current_room_state();

    // Auto-save when leaving room
    auto_save();
}
