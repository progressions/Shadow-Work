// AI event bus system removed for performance optimization

if (variable_global_exists("part_leaf")) {
    part_type_destroy(global.part_leaf);
    global.part_leaf = undefined;
}

if (variable_global_exists("part_wood") && !is_undefined(global.part_wood)) {
    part_type_destroy(global.part_wood);
    global.part_wood = undefined;
}

if (variable_global_exists("debris_system")) {
    part_system_destroy(global.debris_system);
    global.debris_system = undefined;
}
