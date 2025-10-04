// Ensure fade variables exist (handles legacy instances)
if (!variable_instance_exists(id, "fade_duration")) {
    fade_duration = 60;
}
if (!variable_instance_exists(id, "fade_step")) {
    fade_step = (fade_duration > 0) ? (1 / fade_duration) : 1;
}

// Gradually fade out corpse over configured duration
if (fade_duration > 0) {
    image_alpha = max(0, image_alpha - fade_step);

    if (image_alpha <= 0) {
        instance_destroy();
    }
}
