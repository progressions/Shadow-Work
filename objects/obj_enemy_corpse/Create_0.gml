// Call parent create event to get serialize/deserialize methods
event_inherited();

// Stop animation on the corpse
image_speed = 0;
image_alpha = 1;

// Fade-and-despawn configuration
fade_duration = 60;              // Frames to fully fade out
fade_step = (fade_duration > 0) ? (1 / fade_duration) : 1;

alarm[0] = fade_duration;        // Destroy corpse after fade completes

// Serialize/deserialize methods removed during save system rebuild
