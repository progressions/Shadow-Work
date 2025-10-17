/// Quest Marker Create Event
/// Initialize marker properties for onboarding quest tracking

// Quest identification
quest_id = "";                         // Set by spawner - which quest this marker belongs to
marker_sprite = spr_quest_marker;      // Animated sprite (10 fps, 4 frames)

// Animation properties
image_index = 0;                       // Current frame (0-3)
image_speed = 0.1;                     // Animation speed (10 fps equivalent)
image_number = image_get_number(marker_sprite); // Total frames in sprite

// Marker display options
show_offscreen_arrow = true;           // Show arrow when marker is off-screen
offscreen_arrow_distance = 30;         // How far from screen edge to show arrow
offscreen_arrow_color = c_white;       // Arrow color
offscreen_arrow_alpha = 0.8;           // Arrow transparency

// Depth
depth = -100;                          // Draw above most game elements
