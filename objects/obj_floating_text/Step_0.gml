// Follow parent instance if it exists
if (instance_exists(parent_instance)) {
    x = parent_instance.x + offset_x;
    y = parent_instance.y + offset_y;
}

// Float upward
y_offset += float_speed;

// Decrease lifetime
lifetime--;

// Start fading after lifetime expires
if (lifetime <= 0) {
    alpha -= fade_speed;

    // Destroy when fully faded
    if (alpha <= 0) {
        instance_destroy();
    }
}
