// Room End Event
// Auto-save when leaving room (state already saved in room transition)
if (instance_exists(obj_player)) {
    auto_save();
}
