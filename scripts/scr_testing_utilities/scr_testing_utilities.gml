// =============================================================================
// Testing Utilities
// =============================================================================
// Functions for quickly setting up test scenarios without manual gameplay
//
// Created: 2025-10-05
// Spec: @.agent-os/specs/2025-10-05-companion-testing-utility/spec.md
// =============================================================================

/// @function quick_recruit_all_companions()
/// @description Instantly recruits Hola, Yorna, and Canopy for testing purposes
///
/// This function will:
/// - Spawn companions near player if they don't exist in the room
/// - Call recruit_companion() to properly recruit them
/// - Skip their VN intro sequences
/// - Set default affinity values (3.0 for each)
///
/// Usage: Call this in a Room Start event for testing
/// Example:
///   quick_recruit_all_companions();
function quick_recruit_all_companions() {
    quick_recruit_companions_with_affinity(3.0);
}

/// @function quick_recruit_companions_with_affinity(affinity_value)
/// @description Recruits all companions with specified affinity value
/// @param {real} affinity_value - Starting affinity for all companions (0.0 to 10.0)
///
/// This function will:
/// - Spawn companions near player if they don't exist in the room
/// - Call recruit_companion() to properly recruit them
/// - Skip their VN intro sequences
/// - Set custom affinity values
///
/// Usage: Call this in a Room Start event for testing
/// Example:
///   quick_recruit_companions_with_affinity(5.0);  // Start with affinity 5.0
function quick_recruit_companions_with_affinity(affinity_value) {
    // Clamp affinity to valid range (0.0 to 10.0)
    affinity_value = clamp(affinity_value, 0.0, 10.0);

    // Find player instance
    var _player = instance_find(obj_player, 0);
    if (!instance_exists(_player)) {
        show_debug_message("ERROR: Cannot recruit companions - obj_player not found");
        return;
    }

    // Define companions to recruit
    var _companions = [
        { obj: obj_hola, vn_id: "hola_intro", name: "Hola" },
        { obj: obj_yorna, vn_id: "yorna_intro", name: "Yorna" },
        { obj: obj_canopy, vn_id: "canopy_intro", name: "Canopy" }
    ];

    show_debug_message("=== QUICK RECRUIT COMPANIONS (Testing Utility) ===");
    show_debug_message("Target affinity: " + string(affinity_value));

    for (var i = 0; i < array_length(_companions); i++) {
        var _comp_data = _companions[i];
        var _comp_obj = _comp_data.obj;
        var _comp_name = _comp_data.name;
        var _vn_id = _comp_data.vn_id;

        // Find existing companion instance
        var _comp = instance_find(_comp_obj, 0);

        // If companion doesn't exist in room, spawn them near player
        if (!instance_exists(_comp)) {
            // Calculate spawn position offset to prevent overlap
            var _offset_x = (i - 1) * 32; // -32, 0, +32 for 3 companions
            var _offset_y = -16; // Slightly above player

            _comp = instance_create_layer(
                _player.x + _offset_x,
                _player.y + _offset_y,
                "Instances",
                _comp_obj
            );

            show_debug_message("  Spawned " + _comp_name + " at (" + string(_comp.x) + ", " + string(_comp.y) + ")");
        } else {
            show_debug_message("  Found existing " + _comp_name + " instance");
        }

        // Skip VN intro before recruitment (prevent intro from triggering)
        if (variable_global_exists("vn_intro_seen")) {
            global.vn_intro_seen[$ _vn_id] = true;
            show_debug_message("  Marked VN intro as seen: " + _vn_id);
        }

        // Recruit companion using existing system
        recruit_companion(_comp, _player);

        // Set custom affinity value
        if (instance_exists(_comp)) {
            _comp.affinity = affinity_value;
            show_debug_message("  Set affinity: " + string(_comp.affinity));
        }

        show_debug_message("  ✓ " + _comp_name + " recruited successfully");
    }

    show_debug_message("=== Quick recruit complete: 3 companions recruited ===");
}
