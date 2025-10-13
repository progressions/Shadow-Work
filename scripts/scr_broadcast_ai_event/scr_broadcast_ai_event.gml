/// @function scr_broadcast_ai_event(type, x, y, [data_struct])
/// @param {string} _type         The type of event (e.g., "EnemyDeath", "Noise", "MajorThreat")
/// @param {real} _x              The x-coordinate where the event occurred
/// @param {real} _y              The y-coordinate where the event occurred
/// @param {Struct} [data_struct] Optional data associated with the event (default: empty struct)
/// @description Broadcasts an AI event to the global event bus for perception by nearby AI entities
function scr_broadcast_ai_event(_type, _x, _y, _data = {}) {
    // Create event struct with standardized format
    var _event = {
        type: _type,
        x: _x,
        y: _y,
        data: _data
    };

    // Add event to global event bus
    ds_list_add(global.ai_event_bus, _event);
}
