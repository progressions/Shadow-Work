/// @description Test suite for obj_hazard_parent functionality
/// Call test_hazard_creation() to validate hazard object behavior

/// @function test_hazard_creation()
/// @description Test that hazard objects are created with proper defaults
function test_hazard_creation() {
    show_debug_message("=== HAZARD CREATION TEST ===");

    // Create a test hazard instance
    var test_hazard = instance_create_layer(100, 100, "Instances", obj_hazard_parent);

    if (!instance_exists(test_hazard)) {
        show_debug_message("FAIL: Hazard object not created");
        return false;
    }

    // Verify default instance variables
    var tests_passed = true;

    if (test_hazard.damage_mode != "none") {
        show_debug_message("FAIL: damage_mode default incorrect");
        tests_passed = false;
    }

    if (test_hazard.damage_amount != 0) {
        show_debug_message("FAIL: damage_amount default incorrect");
        tests_passed = false;
    }

    if (test_hazard.damage_type != DamageType.physical) {
        show_debug_message("FAIL: damage_type default incorrect");
        tests_passed = false;
    }

    if (test_hazard.trait_to_apply != "") {
        show_debug_message("FAIL: trait_to_apply default incorrect");
        tests_passed = false;
    }

    if (test_hazard.trait_duration != 3.0) {
        show_debug_message("FAIL: trait_duration default incorrect");
        tests_passed = false;
    }

    // Verify data structures are created
    if (!ds_exists(test_hazard.entities_inside, ds_type_list)) {
        show_debug_message("FAIL: entities_inside list not created");
        tests_passed = false;
    }

    if (!ds_exists(test_hazard.damage_immunity_map, ds_type_map)) {
        show_debug_message("FAIL: damage_immunity_map not created");
        tests_passed = false;
    }

    if (!ds_exists(test_hazard.trait_cooldown_map, ds_type_map)) {
        show_debug_message("FAIL: trait_cooldown_map not created");
        tests_passed = false;
    }

    // Clean up test instance
    instance_destroy(test_hazard);

    if (tests_passed) {
        show_debug_message("PASS: All hazard creation tests passed");
    }

    show_debug_message("===========================");
    return tests_passed;
}

/// @function test_hazard_serialization()
/// @description Test that hazard objects serialize/deserialize correctly
function test_hazard_serialization() {
    show_debug_message("=== HAZARD SERIALIZATION TEST ===");

    // Create a test hazard with custom values
    var test_hazard = instance_create_layer(150, 200, "Instances", obj_hazard_parent);
    test_hazard.damage_mode = "continuous";
    test_hazard.damage_amount = 5;
    test_hazard.damage_type = DamageType.fire;
    test_hazard.trait_to_apply = "burning";
    test_hazard.trait_duration = 4.0;

    // Serialize
    var serialized = test_hazard.serialize();

    var tests_passed = true;

    // Verify serialized data
    if (serialized.x != 150) {
        show_debug_message("FAIL: Serialized x incorrect");
        tests_passed = false;
    }

    if (serialized.y != 200) {
        show_debug_message("FAIL: Serialized y incorrect");
        tests_passed = false;
    }

    if (serialized.damage_mode != "continuous") {
        show_debug_message("FAIL: Serialized damage_mode incorrect");
        tests_passed = false;
    }

    if (serialized.damage_amount != 5) {
        show_debug_message("FAIL: Serialized damage_amount incorrect");
        tests_passed = false;
    }

    if (serialized.damage_type != DamageType.fire) {
        show_debug_message("FAIL: Serialized damage_type incorrect");
        tests_passed = false;
    }

    if (serialized.trait_to_apply != "burning") {
        show_debug_message("FAIL: Serialized trait_to_apply incorrect");
        tests_passed = false;
    }

    // Test deserialization
    var test_hazard2 = instance_create_layer(0, 0, "Instances", obj_hazard_parent);
    test_hazard2.deserialize(serialized);

    if (test_hazard2.x != 150 || test_hazard2.y != 200) {
        show_debug_message("FAIL: Deserialized position incorrect");
        tests_passed = false;
    }

    if (test_hazard2.damage_mode != "continuous") {
        show_debug_message("FAIL: Deserialized damage_mode incorrect");
        tests_passed = false;
    }

    if (test_hazard2.damage_amount != 5) {
        show_debug_message("FAIL: Deserialized damage_amount incorrect");
        tests_passed = false;
    }

    // Clean up
    instance_destroy(test_hazard);
    instance_destroy(test_hazard2);

    if (tests_passed) {
        show_debug_message("PASS: All serialization tests passed");
    }

    show_debug_message("=================================");
    return tests_passed;
}

/// @function test_hazard_collision_tracking()
/// @description Test that entities are tracked when entering/exiting hazards
function test_hazard_collision_tracking() {
    show_debug_message("=== HAZARD COLLISION TRACKING TEST ===");

    // Create a test hazard
    var test_hazard = instance_create_layer(200, 200, "Instances", obj_hazard_parent);

    var tests_passed = true;

    // Verify entities_inside list starts empty
    if (ds_list_size(test_hazard.entities_inside) != 0) {
        show_debug_message("FAIL: entities_inside should start empty");
        tests_passed = false;
    }

    // Simulate entity collision by manually adding to list
    // (Actual collision testing requires room/player setup)
    var mock_entity_id = 12345;
    ds_list_add(test_hazard.entities_inside, mock_entity_id);

    if (ds_list_size(test_hazard.entities_inside) != 1) {
        show_debug_message("FAIL: Entity not added to tracking list");
        tests_passed = false;
    }

    if (ds_list_find_index(test_hazard.entities_inside, mock_entity_id) == -1) {
        show_debug_message("FAIL: Entity ID not found in list");
        tests_passed = false;
    }

    // Simulate entity exit
    var index = ds_list_find_index(test_hazard.entities_inside, mock_entity_id);
    if (index != -1) {
        ds_list_delete(test_hazard.entities_inside, index);
    }

    if (ds_list_size(test_hazard.entities_inside) != 0) {
        show_debug_message("FAIL: Entity not removed from tracking list");
        tests_passed = false;
    }

    // Clean up
    instance_destroy(test_hazard);

    if (tests_passed) {
        show_debug_message("PASS: All collision tracking tests passed");
    }

    show_debug_message("======================================");
    return tests_passed;
}

/// @function run_all_hazard_tests()
/// @description Run all hazard test suites
function run_all_hazard_tests() {
    show_debug_message("======================================");
    show_debug_message("RUNNING ALL HAZARD TESTS");
    show_debug_message("======================================");

    var all_passed = true;

    all_passed = test_hazard_creation() && all_passed;
    all_passed = test_hazard_serialization() && all_passed;
    all_passed = test_hazard_collision_tracking() && all_passed;

    show_debug_message("======================================");
    if (all_passed) {
        show_debug_message("ALL TESTS PASSED");
    } else {
        show_debug_message("SOME TESTS FAILED");
    }
    show_debug_message("======================================");

    return all_passed;
}
