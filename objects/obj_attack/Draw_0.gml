// Draw the slash animation (static angle, animated frames)
draw_sprite_ext(spr_slash, 
    floor(swing_progress / 34), // 0-33 = frame 0, 34-67 = frame 1, 68-100 = frame 2
    x, y, 
    image_xscale, -image_yscale, 
    base_angle, // Slash stays at fixed angle
    c_white, image_alpha);

// Draw the rotating sword
draw_self();