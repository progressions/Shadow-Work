// ============================================
// obj_item_parent (PARENT OBJECT - your existing parent)
// ============================================
// CREATE EVENT:

// Call parent create event
event_inherited();

item_def = undefined;
count = 1;
base_y = y;

// Generate unique spawn ID for tracking (must be deterministic based on position)
item_spawn_id = room_get_name(room) + "_item_" + string(x) + "_" + string(y);

sprite_index = spr_items;
image_speed = 0;