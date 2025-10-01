// obj_persistent_parent Create Event
// Base object for all objects that need room state persistence

// Generate unique persistent ID based on object type and position
persistent_id = object_get_name(object_index) + "_" + string(x) + "_" + string(y);

// Base serialize method - override in child objects to add more data
function serialize() {
    return {
        object_type: object_get_name(object_index),
        x: x,
        y: y,
        persistent_id: persistent_id
    };
}

// Base deserialize method - override in child objects to restore more data
function deserialize(data) {
    x = data.x;
    y = data.y;
}
