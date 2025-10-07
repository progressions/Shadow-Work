/// obj_hazard_parent : Destroy Event
/// Clean up data structures and stop audio

// ==============================
// DATA STRUCTURE CLEANUP
// ==============================

// Destroy entity tracking list
if (ds_exists(entities_inside, ds_type_list)) {
    ds_list_destroy(entities_inside);
}

// Destroy damage immunity tracking map
if (ds_exists(damage_immunity_map, ds_type_map)) {
    ds_map_destroy(damage_immunity_map);
}

// ==============================
// AUDIO CLEANUP
// ==============================

// Stop looping SFX to prevent audio leaks
if (sfx_loop != undefined) {
    stop_looped_sfx(sfx_loop);
}
