/// Quest Marker Create Event
/// Initialize marker properties for onboarding quest tracking

// Quest identification
quest_id = "";                         // Set by spawner - which quest this marker belongs to
marker_sprite = spr_quest_marker;      // Animated sprite (10 fps, 4 frames)

// Target tracking (supports static positions OR moving targets)
tracked_instance = noone;              // Instance to track (e.g., obj_canopy, obj_enemy)
target_offset_x = 0;                   // Offset from target center
target_offset_y = -24;                 // Offset above target by default

// Animation properties
image_index = 0;                       // Current frame (0-3)
image_speed = 0.1;                     // Animation speed (10 fps equivalent)
// Note: image_number is a built-in read-only variable (auto-set by GameMaker)

// Marker display options
show_offscreen_arrow = true;           // Show arrow when marker is off-screen
offscreen_arrow_distance = 3;          // How far from screen edge to show arrow
offscreen_arrow_color = c_white;       // Arrow color
offscreen_arrow_alpha = 0.8;           // Arrow transparency

// Depth
depth = -100;                          // Draw above most game elements
