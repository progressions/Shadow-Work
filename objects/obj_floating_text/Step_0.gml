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
