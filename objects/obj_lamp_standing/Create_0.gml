event_inherited();

sprite_index = spr_items;
image_index = 11; // reuse torch frame
image_speed = 0;

var _torch_stats = global.item_database.torch.stats;
if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
    light_radius = max(light_radius, _torch_stats[$ "light_radius"]);
}
