/// @description Follow parent instance and check if still valid

// Follow parent instance position
if (parent_instance != noone && instance_exists(parent_instance)) {
    x = parent_instance.x;
    y = parent_instance.y + offset_y;
} else {
    // Parent destroyed, destroy prompt
    instance_destroy();
}
