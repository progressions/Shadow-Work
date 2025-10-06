/// @function test_ai_event_bus()
/// @description Test suite for AI event bus system - validates creation, broadcasting, and clearing
function test_ai_event_bus() {
    show_debug_message("=== AI EVENT BUS TEST SUITE ===");

    var _tests_passed = 0;
    var _tests_failed = 0;

    // Test 1: Event bus exists and is a ds_list
    show_debug_message("Test 1: Event bus initialization...");
    if (variable_global_exists("ai_event_bus")) {
        if (ds_exists(global.ai_event_bus, ds_type_list)) {
            show_debug_message("✓ PASS: Event bus exists and is a ds_list");
            _tests_passed++;
        } else {
            show_debug_message("✗ FAIL: Event bus exists but is not a ds_list");
            _tests_failed++;
        }
    } else {
        show_debug_message("✗ FAIL: Event bus does not exist");
        _tests_failed++;
    }

    // Test 2: Event bus starts empty
    show_debug_message("Test 2: Event bus initial state...");
    var _initial_size = ds_list_size(global.ai_event_bus);
    if (_initial_size == 0) {
        show_debug_message("✓ PASS: Event bus starts empty (size = 0)");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Event bus not empty (size = " + string(_initial_size) + ")");
        _tests_failed++;
    }

    // Test 3: Broadcasting adds events to bus
    show_debug_message("Test 3: Event broadcasting...");
    scr_broadcast_ai_event("EnemyDeath", 100, 200);
    scr_broadcast_ai_event("Noise", 300, 400, {loudness: 5});
    var _after_broadcast = ds_list_size(global.ai_event_bus);
    if (_after_broadcast == 2) {
        show_debug_message("✓ PASS: Broadcasting adds events (size = 2)");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Broadcasting failed (expected 2, got " + string(_after_broadcast) + ")");
        _tests_failed++;
    }

    // Test 4: Event structure is correct
    show_debug_message("Test 4: Event structure validation...");
    if (_after_broadcast > 0) {
        var _event = global.ai_event_bus[| 0];
        var _valid_structure = true;

        if (!struct_exists(_event, "type")) _valid_structure = false;
        if (!struct_exists(_event, "x")) _valid_structure = false;
        if (!struct_exists(_event, "y")) _valid_structure = false;
        if (!struct_exists(_event, "data")) _valid_structure = false;

        if (_valid_structure && _event.type == "EnemyDeath" && _event.x == 100 && _event.y == 200) {
            show_debug_message("✓ PASS: Event structure is valid");
            _tests_passed++;
        } else {
            show_debug_message("✗ FAIL: Event structure invalid or values incorrect");
            _tests_failed++;
        }
    } else {
        show_debug_message("✗ FAIL: No events to validate");
        _tests_failed++;
    }

    // Test 5: Optional data parameter works
    show_debug_message("Test 5: Optional data parameter...");
    if (_after_broadcast > 1) {
        var _event = global.ai_event_bus[| 1];
        if (struct_exists(_event.data, "loudness") && _event.data.loudness == 5) {
            show_debug_message("✓ PASS: Optional data parameter stored correctly");
            _tests_passed++;
        } else {
            show_debug_message("✗ FAIL: Optional data not stored correctly");
            _tests_failed++;
        }
    } else {
        show_debug_message("✗ FAIL: Second event not found");
        _tests_failed++;
    }

    // Test 6: Event bus clearing
    show_debug_message("Test 6: Event bus clearing...");
    ds_list_clear(global.ai_event_bus);
    var _after_clear = ds_list_size(global.ai_event_bus);
    if (_after_clear == 0) {
        show_debug_message("✓ PASS: Event bus cleared successfully");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Event bus not empty after clear (size = " + string(_after_clear) + ")");
        _tests_failed++;
    }

    // Test 7: Multiple broadcasts after clear
    show_debug_message("Test 7: Post-clear broadcasting...");
    scr_broadcast_ai_event("MajorThreat", 500, 600);
    var _after_rebroadcast = ds_list_size(global.ai_event_bus);
    if (_after_rebroadcast == 1) {
        show_debug_message("✓ PASS: Broadcasting works after clear");
        _tests_passed++;
        ds_list_clear(global.ai_event_bus); // Clean up
    } else {
        show_debug_message("✗ FAIL: Broadcasting failed after clear");
        _tests_failed++;
    }

    // Summary
    show_debug_message("=== TEST SUMMARY ===");
    show_debug_message("Passed: " + string(_tests_passed) + " / " + string(_tests_passed + _tests_failed));
    show_debug_message("Failed: " + string(_tests_failed));

    if (_tests_failed == 0) {
        show_debug_message("✓ ALL TESTS PASSED");
    } else {
        show_debug_message("✗ SOME TESTS FAILED");
    }
    show_debug_message("=== END TEST SUITE ===");

    return _tests_failed == 0;
}
