/// @function test_death_event_broadcasting()
/// @description Test suite for enemy death event broadcasting and perception
function test_death_event_broadcasting() {
    show_debug_message("=== DEATH EVENT BROADCASTING TEST SUITE ===");

    var _tests_passed = 0;
    var _tests_failed = 0;

    // Test 1: Death event broadcast structure
    show_debug_message("Test 1: Death event broadcast structure...");
    ds_list_clear(global.ai_event_bus);

    // Manually simulate death broadcast
    var _test_x = 100;
    var _test_y = 200;
    scr_broadcast_ai_event("EnemyDeath", _test_x, _test_y);

    if (ds_list_size(global.ai_event_bus) == 1) {
        var _event = global.ai_event_bus[| 0];
        if (_event.type == "EnemyDeath" && _event.x == _test_x && _event.y == _test_y) {
            show_debug_message("✓ PASS: Death event broadcast with correct structure");
            _tests_passed++;
        } else {
            show_debug_message("✗ FAIL: Death event structure incorrect");
            _tests_failed++;
        }
    } else {
        show_debug_message("✗ FAIL: Death event not broadcast");
        _tests_failed++;
    }

    // Test 2: Nearby enemy perceives death event
    show_debug_message("Test 2: Nearby enemy perception...");
    ds_list_clear(global.ai_event_bus);

    var _dying_enemy = instance_create_depth(150, 150, 0, obj_enemy_parent);
    var _nearby_enemy = instance_create_depth(180, 180, 0, obj_enemy_parent); // ~42 pixels away
    _nearby_enemy.my_memories = []; // Clear memories

    // Broadcast death at dying enemy's position
    scr_broadcast_ai_event("EnemyDeath", _dying_enemy.x, _dying_enemy.y);

    // Manually trigger perception for nearby enemy (simulating Step event)
    var _bus_size = ds_list_size(global.ai_event_bus);
    for (var i = 0; i < _bus_size; i++) {
        var _event = global.ai_event_bus[| i];
        var _dist = point_distance(_nearby_enemy.x, _nearby_enemy.y, _event.x, _event.y);
        if (_dist <= _nearby_enemy.perception_radius) {
            var _memory = {
                type: _event.type,
                x: _event.x,
                y: _event.y,
                timestamp: current_time
            };
            array_push(_nearby_enemy.my_memories, _memory);
        }
    }

    if (array_length(_nearby_enemy.my_memories) == 1 &&
        _nearby_enemy.my_memories[0].type == "EnemyDeath") {
        show_debug_message("✓ PASS: Nearby enemy perceived death event");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Nearby enemy did not perceive death (memories: " +
                          string(array_length(_nearby_enemy.my_memories)) + ")");
        _tests_failed++;
    }

    // Test 3: Distant enemy ignores death event
    show_debug_message("Test 3: Distant enemy perception...");
    var _distant_enemy = instance_create_depth(500, 500, 0, obj_enemy_parent); // ~400+ pixels away
    _distant_enemy.my_memories = [];

    // Use same death event from bus
    for (var i = 0; i < _bus_size; i++) {
        var _event = global.ai_event_bus[| i];
        var _dist = point_distance(_distant_enemy.x, _distant_enemy.y, _event.x, _event.y);
        if (_dist <= _distant_enemy.perception_radius) {
            var _memory = {
                type: _event.type,
                x: _event.x,
                y: _event.y,
                timestamp: current_time
            };
            array_push(_distant_enemy.my_memories, _memory);
        }
    }

    if (array_length(_distant_enemy.my_memories) == 0) {
        show_debug_message("✓ PASS: Distant enemy ignored death event");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Distant enemy incorrectly perceived death");
        _tests_failed++;
    }

    // Test 4: Party controller perceives death event
    show_debug_message("Test 4: Party controller perception...");
    ds_list_clear(global.ai_event_bus);

    var _test_party = instance_create_depth(160, 160, 0, obj_enemy_party_controller);
    _test_party.my_memories = [];

    // Broadcast death near party controller
    scr_broadcast_ai_event("EnemyDeath", 170, 170);

    // Manually trigger perception for party controller
    _bus_size = ds_list_size(global.ai_event_bus);
    for (var i = 0; i < _bus_size; i++) {
        var _event = global.ai_event_bus[| i];
        var _dist = point_distance(_test_party.x, _test_party.y, _event.x, _event.y);
        if (_dist <= _test_party.perception_radius) {
            var _memory = {
                type: _event.type,
                x: _event.x,
                y: _event.y,
                timestamp: current_time
            };
            array_push(_test_party.my_memories, _memory);
        }
    }

    if (array_length(_test_party.my_memories) == 1 &&
        _test_party.my_memories[0].type == "EnemyDeath") {
        show_debug_message("✓ PASS: Party controller perceived death event");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Party controller did not perceive death");
        _tests_failed++;
    }

    // Test 5: Multiple enemies perceive same death
    show_debug_message("Test 5: Multiple witnesses...");
    ds_list_clear(global.ai_event_bus);

    var _witness1 = instance_create_depth(200, 200, 0, obj_enemy_parent);
    var _witness2 = instance_create_depth(220, 220, 0, obj_enemy_parent);
    var _witness3 = instance_create_depth(240, 240, 0, obj_enemy_parent);
    _witness1.my_memories = [];
    _witness2.my_memories = [];
    _witness3.my_memories = [];

    // Broadcast death in center of witnesses
    scr_broadcast_ai_event("EnemyDeath", 220, 220);

    // All three should perceive it
    var _witnesses = [_witness1, _witness2, _witness3];
    for (var w = 0; w < array_length(_witnesses); w++) {
        var _witness = _witnesses[w];
        _bus_size = ds_list_size(global.ai_event_bus);
        for (var i = 0; i < _bus_size; i++) {
            var _event = global.ai_event_bus[| i];
            var _dist = point_distance(_witness.x, _witness.y, _event.x, _event.y);
            if (_dist <= _witness.perception_radius) {
                var _memory = {
                    type: _event.type,
                    x: _event.x,
                    y: _event.y,
                    timestamp: current_time
                };
                array_push(_witness.my_memories, _memory);
            }
        }
    }

    var _all_witnessed = (array_length(_witness1.my_memories) == 1 &&
                          array_length(_witness2.my_memories) == 1 &&
                          array_length(_witness3.my_memories) == 1);

    if (_all_witnessed) {
        show_debug_message("✓ PASS: Multiple enemies witnessed same death");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Not all enemies witnessed death");
        _tests_failed++;
    }

    // Cleanup
    instance_destroy(_dying_enemy);
    instance_destroy(_nearby_enemy);
    instance_destroy(_distant_enemy);
    instance_destroy(_test_party);
    instance_destroy(_witness1);
    instance_destroy(_witness2);
    instance_destroy(_witness3);
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
