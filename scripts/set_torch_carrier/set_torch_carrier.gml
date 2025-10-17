function set_torch_carrier(_id) {
    _id ??= "none";

    global.torch_carrier_id = _id;

    if (variable_global_exists("ChatterboxVariableSet")) {
        ChatterboxVariableSet("torch_carrier", _id);
    }
}
