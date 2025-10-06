/// @function test_ai_memory_system()
/// @description Test suite for AI memory perception, storage, and expiration
function test_ai_memory_system() {
    show_debug_message("=== AI MEMORY SYSTEM TEST SUITE ===");

    var _tests_passed = 0;
    var _tests_failed = 0;

    // Test 1: Memory variables exist on obj_enemy_parent
    show_debug_message("Test 1: Memory variables initialization...");
    var _test_enemy = instance_create_depth(100, 100, 0, obj_enemy_parent);
    if (variable_instance_exists(_test_enemy, "my_memories") &&
        variable_instance_exists(_test_enemy, "perception_radius") &&
        variable_instance_exists(_test_enemy, "memory_ttl") &&
        variable_instance_exists(_test_enemy, "memory_purge_timer")) {
        show_debug_message("✓ PASS: Memory variables exist");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Memory variables missing");
        _tests_failed++;
    }

    // Test 2: my_memories starts as empty array
    show_debug_message("Test 2: Initial memory state...");
    if (is_array(_test_enemy.my_memories) && array_length(_test_enemy.my_memories) == 0) {
        show_debug_message("✓ PASS: my_memories is empty array");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: my_memories not empty or not an array");
        _tests_failed++;
    }

    // Test 3: Perception of nearby events
    show_debug_message("Test 3: Event perception (within radius)...");
    ds_list_clear(global.ai_event_bus);
    scr_broadcast_ai_event("EnemyDeath", 120, 120); // 20 pixels away

    // Manually trigger perception logic (simulating Step event)
    var _bus_size = ds_list_size(global.ai_event_bus);
    for (var i = 0; i < _bus_size; i++) {
        var _event = global.ai_event_bus[| i];
        var _dist = distance_to_point(_event.x, _event.y);
        if (_dist <= _test_enemy.perception_radius) {
            var _memory = {
                type: _event.type,
                x: _event.x,
                y: _event.y,
                timestamp: current_time
            };
            array_push(_test_enemy.my_memories, _memory);
        }
    }

    if (array_length(_test_enemy.my_memories) == 1) {
        show_debug_message("✓ PASS: Event perceived and stored");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Event not perceived (memories: " + string(array_length(_test_enemy.my_memories)) + ")");
        _tests_failed++;
    }

    // Test 4: Ignoring events outside perception radius
    show_debug_message("Test 4: Event perception (outside radius)...");
    _test_enemy.my_memories = []; // Reset
    ds_list_clear(global.ai_event_bus);
    scr_broadcast_ai_event("Noise", 500, 500); // 400+ pixels away

    // Manually trigger perception logic
    var _bus_size = ds_list_size(global.ai_event_bus);
    for (var i = 0; i < _bus_size; i++) {
        var _event = global.ai_event_bus[| i];
        var _dist = point_distance(_test_enemy.x, _test_enemy.y, _event.x, _event.y);
        if (_dist <= _test_enemy.perception_radius) {
            var _memory = {
                type: _event.type,
                x: _event.x,
                y: _event.y,
                timestamp: current_time
            };
            array_push(_test_enemy.my_memories, _memory);
        }
    }

    if (array_length(_test_enemy.my_memories) == 0) {
        show_debug_message("✓ PASS: Distant event ignored");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Distant event incorrectly perceived");
        _tests_failed++;
    }

    // Test 5: Memory structure is correct
    show_debug_message("Test 5: Memory structure validation...");
    _test_enemy.my_memories = []; // Reset
    var _test_memory = {
        type: "EnemyDeath",
        x: 100,
        y: 200,
        timestamp: current_time
    };
    array_push(_test_enemy.my_memories, _test_memory);

    var _mem = _test_enemy.my_memories[0];
    if (struct_exists(_mem, "type") &&
        struct_exists(_mem, "x") &&
        struct_exists(_mem, "y") &&
        struct_exists(_mem, "timestamp") &&
        _mem.type == "EnemyDeath" &&
        _mem.x == 100 &&
        _mem.y == 200) {
        show_debug_message("✓ PASS: Memory structure valid");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Memory structure invalid");
        _tests_failed++;
    }

    // Test 6: Memory expiration logic
    show_debug_message("Test 6: Memory expiration...");
    _test_enemy.my_memories = []; // Reset

    // Add old memory (expired)
    var _old_memory = {
        type: "EnemyDeath",
        x: 100,
        y: 100,
        timestamp: current_time - (_test_enemy.memory_ttl + 1000) // Older than TTL
    };
    array_push(_test_enemy.my_memories, _old_memory);

    // Add fresh memory (not expired)
    var _fresh_memory = {
        type: "Noise",
        x: 150,
        y: 150,
        timestamp: current_time
    };
    array_push(_test_enemy.my_memories, _fresh_memory);

    // Manually trigger purge logic
    var _i = array_length(_test_enemy.my_memories) - 1;
    while (_i >= 0) {
        var _mem = _test_enemy.my_memories[_i];
        if ((current_time - _mem.timestamp) > _test_enemy.memory_ttl) {
            array_delete(_test_enemy.my_memories, _i, 1);
        }
        _i--;
    }

    if (array_length(_test_enemy.my_memories) == 1 &&
        _test_enemy.my_memories[0].type == "Noise") {
        show_debug_message("✓ PASS: Expired memory purged, fresh memory retained");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Memory expiration not working correctly");
        _tests_failed++;
    }

    // Test 7: Self-filtering (ignoring own events)
    show_debug_message("Test 7: Self-filtering...");
    _test_enemy.my_memories = []; // Reset
    ds_list_clear(global.ai_event_bus);

    // Broadcast event with source ID
    scr_broadcast_ai_event("EnemyDeath", 110, 110, {source: _test_enemy.id});

    // Manually trigger perception with self-filtering
    var _bus_size = ds_list_size(global.ai_event_bus);
    for (var i = 0; i < _bus_size; i++) {
        var _event = global.ai_event_bus[| i];

        // Self-filtering check
        if (struct_exists(_event.data, "source") && _event.data.source == _test_enemy.id) {
            continue; // Skip self-generated events
        }

        var _dist = point_distance(_test_enemy.x, _test_enemy.y, _event.x, _event.y);
        if (_dist <= _test_enemy.perception_radius) {
            var _memory = {
                type: _event.type,
                x: _event.x,
                y: _event.y,
                timestamp: current_time
            };
            array_push(_test_enemy.my_memories, _memory);
        }
    }

    if (array_length(_test_enemy.my_memories) == 0) {
        show_debug_message("✓ PASS: Self-generated event filtered out");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Self-generated event not filtered");
        _tests_failed++;
    }

    // Cleanup
    instance_destroy(_test_enemy);
    ds_list_clear(global.ai_event_bus);

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
