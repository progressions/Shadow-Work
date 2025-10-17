// Test sage interaction

if (!instance_exists(obj_player)) exit;

var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

// Trigger dialogue when player presses SPACE nearby
if (_dist_to_player < 64 && keyboard_check_pressed(vk_space) && !global.vn_active) {
    start_vn_dialogue(id, "test_affinity_functions.yarn", "Start");
}
