// obj_persistent_parent Create Event
// Base object for all objects that need room state persistence

// Generate unique persistent ID based on object type and position
persistent_id = object_get_name(object_index) + "_" + string(x) + "_" + string(y);

// Serialize/deserialize methods removed during save system rebuild
