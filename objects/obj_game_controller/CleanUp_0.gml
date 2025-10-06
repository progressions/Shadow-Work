// Clean up AI event bus to prevent memory leaks
// This event fires when the object is destroyed or when the game ends
if (ds_exists(global.ai_event_bus, ds_type_list)) {
    ds_list_destroy(global.ai_event_bus);
}
