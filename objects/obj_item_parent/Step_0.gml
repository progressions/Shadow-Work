
// ============================================
// OBJ_ITEM_PARENT - Step Event
// ============================================
// Items use the exact same global timer
if (global.game_paused) exit;
if (floor(global.idle_bob_timer) % 2 == 0) {
    y = base_y + 2;
} else {
    y = base_y;
}
