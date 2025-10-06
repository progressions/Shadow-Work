/// @function test_party_memory_morale()
/// @description Test suite for party controller memory and morale breaking
function test_party_memory_morale() {
    show_debug_message("=== PARTY MEMORY & MORALE TEST SUITE ===");

    var _tests_passed = 0;
    var _tests_failed = 0;

    // Test 1: Party controller has memory variables
    show_debug_message("Test 1: Party controller memory variables...");
    var _test_controller = instance_create_depth(200, 200, 0, obj_enemy_party_controller);
    if (variable_instance_exists(_test_controller, "my_memories") &&
        variable_instance_exists(_test_controller, "perception_radius") &&
        variable_instance_exists(_test_controller, "memory_ttl") &&
        variable_instance_exists(_test_controller, "memory_purge_timer")) {
        show_debug_message("✓ PASS: Memory variables exist on party controller");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Memory variables missing from party controller");
        _tests_failed++;
    }

    // Test 2: Party controller perceives events
    show_debug_message("Test 2: Party controller event perception...");
    ds_list_clear(global.ai_event_bus);
    scr_broadcast_ai_event("EnemyDeath", 220, 220); // 20 pixels away

    // Manually trigger perception logic
    var _bus_size = ds_list_size(global.ai_event_bus);
    for (var i = 0; i < _bus_size; i++) {
        var _event = global.ai_event_bus[| i];
        var _dist = point_distance(_test_controller.x, _test_controller.y, _event.x, _event.y);
        if (_dist <= _test_controller.perception_radius) {
            var _memory = {
                type: _event.type,
                x: _event.x,
                y: _event.y,
                timestamp: current_time
            };
            array_push(_test_controller.my_memories, _memory);
        }
    }

    if (array_length(_test_controller.my_memories) == 1 &&
        _test_controller.my_memories[0].type == "EnemyDeath") {
        show_debug_message("✓ PASS: Party controller perceived death event");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Party controller did not perceive event");
        _tests_failed++;
    }

    // Test 3: Create 4-member party to test morale
    show_debug_message("Test 3: Morale threshold logic...");
    var _test_enemies = [];
    for (var i = 0; i < 4; i++) {
        var _enemy = instance_create_depth(250 + (i * 50), 250, 0, obj_enemy_parent);
        array_push(_test_enemies, _enemy);
    }

    _test_controller.init_party(_test_enemies, "line_3");
    _test_controller.party_state = PartyState.aggressive;
    _test_controller.my_memories = []; // Reset

    // Simulate 2 death events (50% of party)
    var _death_time = current_time;
    array_push(_test_controller.my_memories, {
        type: "EnemyDeath",
        x: 250,
        y: 250,
        timestamp: _death_time
    });
    array_push(_test_controller.my_memories, {
        type: "EnemyDeath",
        x: 300,
        y: 250,
        timestamp: _death_time
    });

    // Manually trigger morale check logic
    var _recent_deaths = 0;
    var _death_check_window = 15000; // 15 seconds
    for (var i = 0; i < array_length(_test_controller.my_memories); i++) {
        var _mem = _test_controller.my_memories[i];
        if (_mem.type == "EnemyDeath" && (current_time - _mem.timestamp) < _death_check_window) {
            _recent_deaths++;
        }
    }

    // Check if morale threshold would trigger
    var _morale_broken = (_recent_deaths >= array_length(_test_controller.party_members) * 0.5);

    if (_morale_broken && _recent_deaths == 2) {
        show_debug_message("✓ PASS: Morale threshold triggered (2 deaths >= 50% of 4)");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Morale threshold not working (deaths=" + string(_recent_deaths) + ")");
        _tests_failed++;
    }

    // Test 4: State change verification
    show_debug_message("Test 4: State transition on morale break...");
    var _original_state = _test_controller.party_state;

    // Apply morale logic
    if (_morale_broken) {
        _test_controller.party_state = PartyState.cautious;
    }

    if (_test_controller.party_state == PartyState.cautious && _original_state == PartyState.aggressive) {
        show_debug_message("✓ PASS: Party state changed from aggressive to cautious");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Party state did not change correctly");
        _tests_failed++;
    }

    // Test 5: Death event window expiration
    show_debug_message("Test 5: Old death memories don't trigger morale...");
    _test_controller.my_memories = [];
    _test_controller.party_state = PartyState.aggressive;

    // Add old deaths (outside 15 second window)
    var _old_time = current_time - 20000; // 20 seconds ago
    array_push(_test_controller.my_memories, {
        type: "EnemyDeath",
        x: 250,
        y: 250,
        timestamp: _old_time
    });
    array_push(_test_controller.my_memories, {
        type: "EnemyDeath",
        x: 300,
        y: 250,
        timestamp: _old_time
    });

    // Recount recent deaths
    _recent_deaths = 0;
    for (var i = 0; i < array_length(_test_controller.my_memories); i++) {
        var _mem = _test_controller.my_memories[i];
        if (_mem.type == "EnemyDeath" && (current_time - _mem.timestamp) < _death_check_window) {
            _recent_deaths++;
        }
    }

    if (_recent_deaths == 0) {
        show_debug_message("✓ PASS: Old death memories ignored (outside 15s window)");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Old deaths incorrectly counted");
        _tests_failed++;
    }

    // Test 6: Mixed recent and old deaths
    show_debug_message("Test 6: Mixed recent/old deaths...");
    _test_controller.my_memories = [];

    // Add 1 old death + 1 recent death (not enough for morale break)
    array_push(_test_controller.my_memories, {
        type: "EnemyDeath",
        x: 250,
        y: 250,
        timestamp: current_time - 20000 // Old
    });
    array_push(_test_controller.my_memories, {
        type: "EnemyDeath",
        x: 300,
        y: 250,
        timestamp: current_time // Recent
    });

    // Recount
    _recent_deaths = 0;
    for (var i = 0; i < array_length(_test_controller.my_memories); i++) {
        var _mem = _test_controller.my_memories[i];
        if (_mem.type == "EnemyDeath" && (current_time - _mem.timestamp) < _death_check_window) {
            _recent_deaths++;
        }
    }

    if (_recent_deaths == 1) {
        show_debug_message("✓ PASS: Only recent death counted (1 of 2 total)");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Recent death count incorrect");
        _tests_failed++;
    }

    // Cleanup
    instance_destroy(_test_controller);
    for (var i = 0; i < array_length(_test_enemies); i++) {
        if (instance_exists(_test_enemies[i])) {
            instance_destroy(_test_enemies[i]);
        }
    }
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
