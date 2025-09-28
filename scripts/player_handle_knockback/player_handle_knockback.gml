function player_handle_knockback(){
    // ============================================
    // KNOCKBACK SYSTEM
    // ============================================
    if (kb_x != 0 || kb_y != 0) {
        // Apply knockback movement
        move_and_collide(kb_x, kb_y, tilemap);

        // Reduce knockback over time
        kb_x *= 0.8;
        kb_y *= 0.8;

        // Stop knockback when it's very small
        if (abs(kb_x) < 0.1) kb_x = 0;
        if (abs(kb_y) < 0.1) kb_y = 0;
    }
}