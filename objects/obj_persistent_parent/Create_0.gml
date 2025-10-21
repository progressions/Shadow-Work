// obj_persistent_parent Create Event
// Base object for all objects that need room state persistence

// Generate unique persistent ID based on object type and position
persistent_id = object_get_name(object_index) + "_" + string(x) + "_" + string(y);

// Serialize/deserialize methods removed during save system rebuild

// overwrite this function in each child to define all the specific variables we need. 
function serialize() {
	
    var _struct = {
        // Identity & Location
        object_type: object_get_name(object_index),  // What object to recreate
        persistent_id: persistent_id,                 // Unique identifier
        x: x,
        y: y,
        room_name: room_get_name(room),               // Which room this object is in

        sprite_index: sprite_get_name(sprite_index),  // If sprite changes
        image_index: image_index,                      // If animation frame matters
        image_xscale: image_xscale,                    // If flipped/scaled
        image_yscale: image_yscale,
    }
	  
	return _struct;
}