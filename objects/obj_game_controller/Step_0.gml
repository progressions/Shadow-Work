// Top of obj_player Step Event - BEFORE everything else:
if (global.game_paused) return;

global.idle_bob_timer += 0.05;
if (global.idle_bob_timer >= 2) {
    global.idle_bob_timer -= 2;
}