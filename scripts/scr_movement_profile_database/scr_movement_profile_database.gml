
// Initialize movement profile database (specialized enemy movement behaviors)
global.movement_profile_database = {
    kiting_swooper: {
        name: "Kiting Swoop Attacker",
        type: "kiting_swooper",
        parameters: {
            kite_min_distance: 75,      // Minimum distance to maintain from target
            kite_max_distance: 150,     // Maximum distance before closing in
            kite_ideal_distance: 110,   // Preferred distance to maintain
            erratic_offset: 16,         // Random position offset for erratic movement (pixels)
            erratic_update_interval: 30, // Frames between erratic position adjustments
            swoop_range: 200,           // Maximum distance to initiate swoop attack
            swoop_speed: 8,             // Speed during dash attack (pixels/frame)
            swoop_cooldown: 120,        // Frames between swoop attacks (2 seconds at 60fps)
            return_speed: 4,            // Speed when returning to anchor position
            anchor_tolerance: 16        // Distance threshold to consider "at anchor"
        },
        update_function: scr_movement_profile_kiting_swooper_update
    }
}
