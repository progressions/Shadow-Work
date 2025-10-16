/// Explosion Step Event
// Animate and destroy when animation completes

// Check if animation has completed (reached last frame)
if (image_index >= image_number - 1) {
    instance_destroy();
}
