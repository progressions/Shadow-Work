/// obj_hazard_parent : Collision End (Other)
/// Handle entity exiting hazard - remove from tracking

var entity = other;

// Find and remove entity from tracking list
var index = ds_list_find_index(entities_inside, entity.id);

show_debug_message("[HAZARD EXIT] Object: " + object_get_name(object_index) + " | Entity: " + object_get_name(entity.object_index) + " | Found in list: " + string(index != -1) + " | List size before: " + string(ds_list_size(entities_inside)));

if (index != -1) {
    ds_list_delete(entities_inside, index);

    // Play exit SFX
    if (sfx_exit != undefined) {
        play_sfx(sfx_exit, 1, false);
    }

    show_debug_message("Entity exited hazard: " + object_get_name(entity.object_index) + " | List size after: " + string(ds_list_size(entities_inside)));
}

// Note: We intentionally don't clean up immunity/cooldown timers here
// They will naturally expire over time in the Step event
// This allows the immunity period to persist briefly after exiting
