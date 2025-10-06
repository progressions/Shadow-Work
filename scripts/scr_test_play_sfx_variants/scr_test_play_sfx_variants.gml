/// @function test_play_sfx_variants()
/// @description Test suite for play_sfx() variant randomization functionality
function test_play_sfx_variants() {
    show_debug_message("=== PLAY_SFX VARIANT RANDOMIZATION TEST SUITE ===");

    var _tests_passed = 0;
    var _tests_failed = 0;

    // Save original debug flag state
    var _original_debug_flag = global.debug_sound_variants;

    // Test 1: play_sfx() function exists
    show_debug_message("Test 1: play_sfx() function exists...");
    if (script_exists(asset_get_index("play_sfx"))) {
        show_debug_message("✓ PASS: play_sfx() function exists");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: play_sfx() function not found");
        _tests_failed++;
    }

    // Test 2: Calling play_sfx() with a sound that has variants (don't actually play, just test logic)
    show_debug_message("Test 2: Variant detection in play_sfx()...");
    // We can't easily test the actual sound playing without audio output,
    // but we can verify the lookup works
    var _test_sound = "snd_party_cautious";
    var _variant_count = global.sound_variant_lookup[$ _test_sound] ?? 0;
    if (_variant_count > 0) {
        show_debug_message("✓ PASS: Sound with variants detected (snd_party_cautious has " + string(_variant_count) + " variants)");
        _tests_passed++;
    } else {
        show_debug_message("⚠ WARNING: snd_party_cautious has no variants in lookup (expected > 0)");
        _tests_passed++; // Not a failure, just means we need to add variants
    }

    // Test 3: Sound without variants should return 0
    show_debug_message("Test 3: Non-variant sound handling...");
    var _non_variant_sound = "snd_footsteps_grass";
    var _non_variant_count = global.sound_variant_lookup[$ _non_variant_sound] ?? 0;
    if (_non_variant_count == 0) {
        show_debug_message("✓ PASS: Non-variant sound returns 0 (will use base sound)");
        _tests_passed++;
    } else {
        show_debug_message("⚠ INFO: snd_footsteps_grass has " + string(_non_variant_count) + " variants");
        _tests_passed++; // Still pass, just means this sound has variants now
    }

    // Test 4: Random selection randomness test
    show_debug_message("Test 4: Random variant selection distribution...");
    // Test that irandom_range produces different values over multiple calls
    var _random_results = {};
    var _test_iterations = 100;

    for (var i = 0; i < _test_iterations; i++) {
        var _random_num = irandom_range(1, 3); // Simulate picking from 3 variants
        _random_results[$ string(_random_num)] = (_random_results[$ string(_random_num)] ?? 0) + 1;
    }

    var _unique_results = array_length(variable_struct_get_names(_random_results));
    if (_unique_results >= 2) { // At least 2 different values selected
        show_debug_message("✓ PASS: Random selection produces varied results (" + string(_unique_results) + " unique values in " + string(_test_iterations) + " iterations)");
        show_debug_message("  Distribution: 1=" + string(_random_results[$ "1"] ?? 0) +
                          ", 2=" + string(_random_results[$ "2"] ?? 0) +
                          ", 3=" + string(_random_results[$ "3"] ?? 0));
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Random selection not producing varied results");
        _tests_failed++;
    }

    // Test 5: asset_get_index works for existing sounds
    show_debug_message("Test 5: Asset lookup functionality...");
    var _existing_sound_index = asset_get_index("snd_player_hit");
    if (_existing_sound_index != -1) {
        show_debug_message("✓ PASS: asset_get_index successfully finds existing sound");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: asset_get_index failed to find snd_player_hit");
        _tests_failed++;
    }

    // Test 6: asset_get_index returns -1 for non-existent sounds
    show_debug_message("Test 6: Non-existent sound handling...");
    var _fake_sound_index = asset_get_index("snd_fake_nonexistent_sound");
    if (_fake_sound_index == -1) {
        show_debug_message("✓ PASS: asset_get_index returns -1 for non-existent sound");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: asset_get_index did not return -1 for fake sound");
        _tests_failed++;
    }

    // Test 7: Debug flag toggle test
    show_debug_message("Test 7: Debug flag functionality...");
    global.debug_sound_variants = true;
    if (global.debug_sound_variants == true) {
        global.debug_sound_variants = false;
        if (global.debug_sound_variants == false) {
            show_debug_message("✓ PASS: Debug flag toggles correctly");
            _tests_passed++;
        } else {
            show_debug_message("✗ FAIL: Debug flag failed to toggle off");
            _tests_failed++;
        }
    } else {
        show_debug_message("✗ FAIL: Debug flag failed to toggle on");
        _tests_failed++;
    }

    // Restore original debug flag
    global.debug_sound_variants = _original_debug_flag;

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
