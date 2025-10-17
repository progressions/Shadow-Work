/// Quest Marker Step Event
/// Handle animation looping and quest completion detection

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
