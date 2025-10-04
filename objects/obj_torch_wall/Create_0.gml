event_inherited();

sprite_index = spr_wielded_torch;
image_speed = 0.2;
image_xscale = 1;
image_yscale = 1;

var _torch_stats = global.item_database.torch.stats;
if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
    light_radius = _torch_stats[$ "light_radius"];
}
