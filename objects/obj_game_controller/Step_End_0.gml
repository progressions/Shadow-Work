// Clear the AI event bus at the end of each frame
// This ensures events are only processed once by listeners
ds_list_clear(global.ai_event_bus);
