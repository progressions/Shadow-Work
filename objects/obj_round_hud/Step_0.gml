/// Round HUD Step Event
/// Handle onboarding quest text fade in/out

// Debug output (first frame only)
if (!variable_instance_exists(self, "_debug_printed")) {
    show_debug_message("=== Onboarding HUD Debug ===");
    show_debug_message("Current quest: " + (global.onboarding_quests.current_quest != undefined ? global.onboarding_quests.current_quest.quest_id : "NONE"));
    show_debug_message("Quest text: " + onboarding_get_current_quest_text());
    show_debug_message("Active quest index: " + string(global.onboarding_quests.active_quest_index));
    show_debug_message("Total quests: " + string(array_length(global.onboarding_quests.quest_sequence)));
    _debug_printed = true;
}

// Check if onboarding quest has changed
if (global.onboarding_quests.current_quest != undefined) {
    var _current_quest_id = global.onboarding_quests.current_quest.quest_id;

    // New quest started - fade in
    if (_current_quest_id != onboarding_last_quest_id) {
        onboarding_quest_target_alpha = 1;
        onboarding_last_quest_id = _current_quest_id;
        show_debug_message("Quest changed to: " + _current_quest_id);
    }
} else {
    // No quest active - fade out
    onboarding_quest_target_alpha = 0;
    onboarding_last_quest_id = "";
}

// Smoothly interpolate alpha toward target
if (onboarding_quest_alpha < onboarding_quest_target_alpha) {
    onboarding_quest_alpha = min(onboarding_quest_alpha + onboarding_quest_fade_speed, onboarding_quest_target_alpha);
} else if (onboarding_quest_alpha > onboarding_quest_target_alpha) {
    onboarding_quest_alpha = max(onboarding_quest_alpha - onboarding_quest_fade_speed, onboarding_quest_target_alpha);
}
