// Call parent create event to get serialize/deserialize methods
event_inherited();

// Stop animation on the corpse
image_speed = 0;
image_alpha = 1;

// Fade-and-despawn configuration
fade_duration = 60;              // Frames to fully fade out
fade_step = (fade_duration > 0) ? (1 / fade_duration) : 1;

alarm[0] = fade_duration;        // Destroy corpse after fade completes

// Override serialize to save sprite frame
function serialize() {
    return {
        object_type: object_get_name(object_index),
        x: x,
        y: y,
        persistent_id: object_get_name(object_index) + "_" + string(x) + "_" + string(y),
        sprite_index: sprite_get_name(sprite_index),
        image_index: image_index
    };
}

// Override deserialize to restore sprite frame
function deserialize(data) {
    x = data.x;
    y = data.y;
    sprite_index = asset_get_index(data.sprite_index);
    image_index = data.image_index;
}
