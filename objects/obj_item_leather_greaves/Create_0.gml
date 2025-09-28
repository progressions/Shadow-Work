
// Parent: obj_item_parent
// CREATE EVENT:
event_inherited();  // Calls parent's create event
item_def = global.item_database.leather_greaves;
image_index = item_def.world_sprite_frame;  // Sets to frame 0