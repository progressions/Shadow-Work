// Update hop animation
if (hop.active) {
    hop.progress += hop.speed;
    if (hop.progress >= 1) {
        // Hop complete
        hop.progress = 1;
        obj_player.x = hop.target_x;
        obj_player.y = hop.target_y;
        hop.active = false;
    } else {
        // Interpolate position
        obj_player.x = lerp(hop.start_x, hop.target_x, hop.progress);
        obj_player.y = lerp(hop.start_y, hop.target_y, hop.progress);
        
        // Add arc for vertical offset
        var arc = sin(hop.progress * pi) * hop.height;
        obj_player.y -= arc;
    }
}