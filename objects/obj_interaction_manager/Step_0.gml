// Find and select the highest priority interactive object near the player

// Don't process interactions when game is paused
if (global.game_paused) {
	global.active_interactive = noone;
	exit;
}

// Reset active interactive
global.active_interactive = noone;

// Find player
var _player = instance_exists(obj_player) ? obj_player : noone;
if (_player == noone) {
	// show_debug_message("INTERACTION MANAGER: No player found");
	exit;
}

// Create list to store nearby interactable objects
var _interactive_list = ds_list_create();

// Find all interactable objects within query radius
var _found_count = collision_circle_list(
    _player.x,
    _player.y,
    max_query_radius,
    obj_interactable_parent,
    false,
    true,
    _interactive_list,
    false
);

// Debug logging (only when items found)
if (_found_count > 0) {
	// show_debug_message("INTERACTION MANAGER: Found " + string(_found_count) + " interactables near player");
}

if (_found_count == 0) {
    ds_list_destroy(_interactive_list);
    exit;
}

// Find the best candidate based on priority and distance
var _best_candidate = noone;
var _best_score = -999999;

for (var i = 0; i < _found_count; i++) {
    var _obj = _interactive_list[| i];

    // Skip if object is outside its interaction radius
    var _distance = point_distance(_player.x, _player.y, _obj.x, _obj.y);
    if (_distance > _obj.interaction_radius) continue;

    // Skip if object can't be interacted with
    var _can_interact_method = method(_obj, _obj.can_interact);
    if (!_can_interact_method()) continue;

    // Calculate priority score: base_priority + (max_distance - distance)
    // This gives higher priority to objects with higher base priority,
    // with distance as a tiebreaker (closer = better)
    var _score = _obj.interaction_priority + (max_query_radius - _distance);

    if (_score > _best_score) {
        _best_score = _score;
        _best_candidate = _obj;
    }
}

// Store the best candidate
global.active_interactive = _best_candidate;

if (_best_candidate != noone) {
	// show_debug_message("INTERACTION MANAGER: Selected " + object_get_name(_best_candidate.object_index) + " at distance " + string(point_distance(_player.x, _player.y, _best_candidate.x, _best_candidate.y)));
} else {
	// show_debug_message("INTERACTION MANAGER: No valid candidate (all failed can_interact check or out of range)");
}

// Clean up
ds_list_destroy(_interactive_list);
