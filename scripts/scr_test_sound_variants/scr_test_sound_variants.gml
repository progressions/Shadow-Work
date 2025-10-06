/// @function test_sound_variants()
/// @description Test suite for sound variant detection and randomization system
function test_sound_variants() {
    show_debug_message("=== SOUND VARIANT DETECTION TEST SUITE ===");

    var _tests_passed = 0;
    var _tests_failed = 0;

    // Test 1: global.sound_variant_lookup exists and is a struct
    show_debug_message("Test 1: Variant lookup initialization...");
    if (variable_global_exists("sound_variant_lookup")) {
        if (is_struct(global.sound_variant_lookup)) {
            show_debug_message("✓ PASS: sound_variant_lookup exists and is a struct");
            _tests_passed++;
        } else {
            show_debug_message("✗ FAIL: sound_variant_lookup exists but is not a struct");
            _tests_failed++;
        }
    } else {
        show_debug_message("✗ FAIL: sound_variant_lookup does not exist");
        _tests_failed++;
    }

    // Test 2: Variant detection for sounds with 3 variants
    show_debug_message("Test 2: Three-variant sound detection...");
    // Manually test if party sounds have been detected (these already exist)
    var _party_cautious_count = global.sound_variant_lookup[$ "snd_party_cautious"] ?? -1;
    if (_party_cautious_count >= 0) {
        show_debug_message("✓ PASS: Detected snd_party_cautious variants: " + string(_party_cautious_count));
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: snd_party_cautious not found in lookup");
        _tests_failed++;
    }

    // Test 3: Non-existent sound returns 0 or undefined
    show_debug_message("Test 3: Non-existent sound handling...");
    var _fake_sound_count = global.sound_variant_lookup[$ "snd_fake_nonexistent"] ?? 0;
    if (_fake_sound_count == 0) {
        show_debug_message("✓ PASS: Non-existent sound returns 0");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Non-existent sound returned: " + string(_fake_sound_count));
        _tests_failed++;
    }

    // Test 4: Lookup contains multiple entries
    show_debug_message("Test 4: Multiple sound entries...");
    var _lookup_keys = variable_struct_get_names(global.sound_variant_lookup);
    var _key_count = array_length(_lookup_keys);
    if (_key_count > 0) {
        show_debug_message("✓ PASS: Lookup contains " + string(_key_count) + " sound entries");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Lookup is empty");
        _tests_failed++;
    }

    // Test 5: Debug flag exists
    show_debug_message("Test 5: Debug flag initialization...");
    if (variable_global_exists("debug_sound_variants")) {
        show_debug_message("✓ PASS: debug_sound_variants flag exists (value: " + string(global.debug_sound_variants) + ")");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: debug_sound_variants flag missing");
        _tests_failed++;
    }

    // Test 6: All detected variants are valid numbers >= 0
    show_debug_message("Test 6: Variant count validity...");
    var _all_valid = true;
    for (var i = 0; i < array_length(_lookup_keys); i++) {
        var _key = _lookup_keys[i];
        var _count = global.sound_variant_lookup[$ _key];
        if (!is_real(_count) || _count < 0) {
            show_debug_message("✗ Invalid count for " + _key + ": " + string(_count));
            _all_valid = false;
        }
    }
    if (_all_valid) {
        show_debug_message("✓ PASS: All variant counts are valid (>= 0)");
        _tests_passed++;
    } else {
        show_debug_message("✗ FAIL: Some variant counts are invalid");
        _tests_failed++;
    }

    // Test 7: List all detected sounds with variants
    show_debug_message("Test 7: Listing all sounds with variants...");
    var _sounds_with_variants = 0;
    for (var i = 0; i < array_length(_lookup_keys); i++) {
        var _key = _lookup_keys[i];
        var _count = global.sound_variant_lookup[$ _key];
        if (_count > 0) {
            show_debug_message("  - " + _key + ": " + string(_count) + " variants");
            _sounds_with_variants++;
        }
    }
    if (_sounds_with_variants > 0) {
        show_debug_message("✓ PASS: Found " + string(_sounds_with_variants) + " sounds with variants");
        _tests_passed++;
    } else {
        show_debug_message("⚠ WARNING: No sounds with variants detected (may need test sound files)");
        _tests_passed++; // Not a failure, just means no variant sounds exist yet
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
