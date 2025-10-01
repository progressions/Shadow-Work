// ============================================
// obj_item_parent (PARENT OBJECT - your existing parent)
// ============================================
// CREATE EVENT:
item_def = undefined;
count = 1;
base_y = y;

// Generate unique spawn ID for tracking
item_spawn_id = string(room) + "_item_" + string(x) + "_" + string(y) + "_" + string(irandom(999999));

sprite_index = spr_items;
image_speed = 0;