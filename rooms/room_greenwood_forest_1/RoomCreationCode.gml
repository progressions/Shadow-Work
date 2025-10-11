var _controller = instance_find(obj_lighting_controller, 0);

if (_controller == noone) {
    var _layer = layer_exists("Instances") ? "Instances" : layer_get_name(layer_get_id(0));
    _controller = instance_create_layer(0, 0, _layer, obj_lighting_controller);
}

if (_controller != noone) {
    _controller.room_darkness_level = 0.8; // 0 = fully lit, 1 = pitch black
    _controller.surface_dirty = true;
}
