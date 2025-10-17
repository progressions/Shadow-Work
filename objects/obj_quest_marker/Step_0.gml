/// Quest Marker Step Event
/// Handle animation looping, target tracking, and quest completion detection

// Track moving target if assigned
if (tracked_instance != noone) {
    if (instance_exists(tracked_instance)) {
        // Update position to follow target with offset
        x = tracked_instance.x + target_offset_x;
        y = tracked_instance.y + target_offset_y;
    } else {
        // Target destroyed - destroy marker
        instance_destroy();
        exit;
    }
}

// Update animation frame
image_index += image_speed;

// Loop animation when it reaches the end
if (image_index >= image_number) {
    image_index -= image_number;
}

// Destroy marker when quest completes or is no longer active
if (global.onboarding_quests.current_quest == undefined ||
    global.onboarding_quests.current_quest.quest_id != quest_id) {
    instance_destroy();
}
