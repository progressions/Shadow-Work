// Round HUD Create Event
// Initialize all HUD state variables

// Onboarding quest text display
onboarding_quest_alpha = 0;              // Current alpha for fade effect
onboarding_quest_target_alpha = 0;       // Target alpha (0 or 1)
onboarding_quest_fade_speed = 0.08;      // How fast to fade in/out
onboarding_last_quest_id = "";           // Track which quest is displayed to detect changes
